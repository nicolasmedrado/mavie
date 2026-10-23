---
title: Security model
status: in_progress
last_review: 2026-10-21
---

# Security model

How Row Level Security is arranged, and how one member of a shared list reads another member's rating **without** being able to read that person's library.

This is the hardest design problem in the app. Read it before writing any policy.

> Status: **`profiles` and `movies_cache` RLS implemented (BE-02/03).** The cross-member read gateway (`get_list_items`, BE-08) and the rest of the lists schema's policies are still specified, not yet implemented — issues BE-05 … BE-12.

## The question

A shared list shows, per film, what each member scored it. The data lives in `user_movies`, which is private. So some cross-user read has to be allowed — the whole question is **how narrow** it can be made.

## The answer in one line

`user_movies` stays strictly private (`user_id = auth.uid()`, nothing else), and *all* cross-user reads go through a single `security definer` function, `get_list_items(p_list_id)`, that takes no user and no film as a parameter.

## Why not the obvious policy

The tempting approach is a cross-user `select` policy on `user_movies`:

```sql
-- DO NOT DO THIS
create policy "members read members' ratings" on public.user_movies for select
using (user_id = auth.uid() or exists (
  select 1 from public.list_items li
  join public.list_members me    on me.list_id = li.list_id and me.user_id = auth.uid()
  join public.list_members other on other.list_id = li.list_id and other.user_id = user_movies.user_id
  where li.tmdb_id = user_movies.tmdb_id
    and me.status = 'accepted' and other.status = 'accepted'));
```

It is correctly *scoped* and still the wrong shape, for three reasons:

**1. It is a push-based leak.** The readable surface is "any film co-present in a shared list" — and that set is controlled by a **write** either party can perform. Add a thousand `tmdb_id`s to a list you both belong to, and you can now run `select * from user_movies where user_id = <them>` and harvest a thousand of their ratings, for films they never meant to surface. A read permission granted by someone else's write is not a permission model.

**2. The table stops being locally auditable.** Reading the policy no longer tells you who can see a row — you also have to reason about `list_items` and `list_members`. That is the kind of thing that is wrong in production for a year and nobody notices.

**3. It runs on every row of every query** against `user_movies`, including your own library screen, which never needs it.

## The design

```
                    ┌──────────────────────────────────────┐
  client ──RPC──►   │ get_list_items(p_list_id)            │
                    │   security definer                   │
                    │   1. is_list_member(p_list_id)?      │ ◄── authorizes ONCE
                    │      no → raise 42501                │
                    │   2. items × accepted members'       │
                    │      ratings, aggregated to jsonb    │
                    └──────────────────────────────────────┘
                                   │ reads past RLS
                                   ▼
  client ──SQL──►  user_movies   RLS: user_id = auth.uid()   ◄── one line, always
```

- **`user_movies` RLS is one predicate for all four commands: `user_id = auth.uid()`.** No joins, no exceptions, obviously correct at a glance.
- **`get_list_items` is the only cross-user read.** It authorizes once, then returns, per item, the ratings of *accepted* members of *that one list*. There is no `user_id` parameter and no `tmdb_id` parameter — the client cannot ask a different question or enumerate.
- Exposure is bounded **by construction**, not by predicate: the most any member can learn is the ratings for films they already see in a list they already belong to, delivered as one aggregated response rather than as a queryable relation.

**Why a function and not a view.** A view cannot take `p_list_id` as a parameter, so a `security definer` view over `user_movies` would have to derive its scope from `auth.uid()` alone and would then be queryable with arbitrary `where` clauses — straight back to problem (1). A function with a parameter and a guard clause is the narrower primitive. It is also the single place to add per-rating visibility later, and the single place to audit.

## Policies

`alter table ... enable row level security` on every table. **Never `force row level security`** — see the recursion trap.

| Table | SELECT | INSERT | UPDATE | DELETE |
|---|---|---|---|---|
| `profiles` | `id = auth.uid() or shares_list_with(id)` | — (trigger) | `id = auth.uid()` | — (cascade) |
| `movies_cache` | `auth.role() = 'authenticated'` | — | — | — |
| `user_movies` | `user_id = auth.uid()` | `user_id = auth.uid()` | `user_id = auth.uid()` | `user_id = auth.uid()` |
| `lists` | `is_list_member(id)` | `owner_id = auth.uid()` | `is_list_owner(id)` | `is_list_owner(id)` |
| `list_members` | `is_list_member(list_id)` | `is_list_owner(list_id)` | — (RPC) | `is_list_owner(list_id) or user_id = auth.uid()` |
| `list_items` | `is_list_member(list_id)` | `is_list_member(list_id) and added_by = auth.uid()` | `is_list_member(list_id)` | `added_by = auth.uid() or is_list_owner(list_id)` |

Notes on the non-obvious rows:

- **`profiles` is not `using (true)`.** A blanket read policy would hand every username and avatar to anyone holding the anon key. Invite lookup goes through `find_profile_by_username`, which matches exactly and returns three columns.
- **`movies_cache` has no write policies at all.** It is a shared global cache: a bad client write would corrupt titles and posters for both users. Writes happen only inside definer RPCs that validate the payload.
- **`list_members` has no UPDATE policy.** Accepting an invite is a column-scoped transition (`status`, `joined_at` only). An RLS `with check` cannot express "you may change these two columns but not `role`" without also letting a member promote themselves. `accept_list_invite` enforces it instead.
- **`list_items` DELETE** lets you remove what you added, and lets the owner remove anything.

## The recursion trap

`list_members`'s SELECT policy calls `is_list_member`, which queries `list_members`, which evaluates the policy, which calls `is_list_member`…

```
ERROR:  infinite recursion detected in policy for relation "list_members"
```

The only fix is making the helper `security definer`, which bypasses RLS inside the function body.

**Corollary: do not `force row level security` on these tables.** FORCE applies RLS even to the table owner — which is exactly who definer functions run as — and reintroduces the recursion.

## Rules for every `security definer` function

Non-negotiable, all four:

1. `set search_path = ''` and schema-qualify every identifier. Omitting this is a privilege-escalation vector; Supabase's database linter flags it. **Treat that warning as a build failure, not a suggestion.**
2. `stable` when it only reads.
3. `revoke execute on function ... from public; grant execute ... to authenticated;`
4. Its own authorization check as the **first statement** in the body. The function bypasses RLS — it has to re-impose the rule itself.

## `get_list_items` shape

```sql
get_list_items(p_list_id uuid) returns table (
  tmdb_id integer, sort_order integer, added_by uuid, added_at timestamptz, note text,
  title text, poster_path text, release_date date, tmdb_vote_average numeric,
  ratings jsonb   -- [{user_id, display_name, avatar_path, rating, watched_at}]
)
```

1. `if not public.is_list_member(p_list_id) then raise exception 'not a member' using errcode = '42501'; end if;`
2. `list_items li join movies_cache mc on mc.tmdb_id = li.tmdb_id`
3. `left join lateral` aggregating, for that `li.tmdb_id`, every `list_members` row of this list with `status = 'accepted'`, joined to `profiles` and to `user_movies` where `rating is not null`.

One round trip renders the whole list screen — the reason `movies_cache` exists.

## Accepted consequence: no Realtime

Supabase Realtime respects table RLS, and `user_movies` RLS is own-rows-only. **You will not receive an event when the other person rates something.** For two users, refresh-on-focus plus pull-to-refresh is indistinguishable from live — [[architecture/decisions/0013-no-realtime-in-mvp]].

If live updates are ever wanted, the right mechanism is a `list_activity` table written by an `after update` trigger on `user_movies` for each shared list containing that film, with `select using (is_list_member(list_id))`. It doubles as an activity feed and leaks nothing the list screen does not already show.

## Proving it works — BE-12

With two real users, **an RLS bug never surfaces on its own.** There is no adversarial user to find it. `supabase/tests/rls_test.sql` is the only control, and it runs before any list UI is built.

As user B, assert:

| Attempt | Expected |
|---|---|
| `select * from user_movies where user_id = <A>` | 0 rows |
| `get_list_items(<list B was only invited to>)` | raises `42501` |
| `get_list_items(<list B accepted>)` | A's rating, for exactly the items in that list, and nothing else |
| `select * from profiles` | only B and users B shares a list with |
| `insert into movies_cache ...` | denied |
| `update list_members set role = 'owner' where user_id = <B>` | denied |

This is also a genuinely good artifact to have in a portfolio repository.

## Related

- [[architecture/data-model]] — the tables these policies cover
- [[architecture/decisions/0007-cross-member-reads-via-rpc]]
- [[architecture/decisions/0004-global-ratings]]

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Security model designed; definer-RPC gateway chosen over cross-user RLS policies |
| 2026-10-22 | `profiles`/`movies_cache` RLS and grants implemented and verified (BE-02/03). Confirmed in practice: `auto_expose_new_tables = false` means RLS policies alone are not enough — an explicit `grant` is also required per table, or every query fails with `permission denied` regardless of policy correctness |
