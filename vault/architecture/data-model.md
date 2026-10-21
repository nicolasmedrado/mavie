---
title: Data model
status: planned
last_review: 2026-10-21
---

# Data model

Postgres on Supabase. Migrations live in `supabase/migrations/`, applied through the Supabase CLI.

> Status: **specified, not yet created.** Issues BE-01 through BE-05. Treat this document as the spec the migrations must match, and update it in the same session the migrations change.

Extensions: `pgcrypto` (`gen_random_uuid`), `citext` (usernames), `pg_trgm` (title search).

## Shape

```
auth.users ──1:1── profiles
                     │
       ┌─────────────┼──────────────┐
       │             │              │
  user_movies    list_members    lists ──< list_items
       │             │                          │
       └──────┬──────┘                          │
              ▼                                 ▼
          movies_cache ◄────────────────────────┘
```

Two different things are deliberately **not** unified:

- `user_movies` — the two system lists *plus* the rating. One row per person per film.
- `lists` / `list_items` — user-created, shareable, playlist-shaped collections.

Why they are separate: [[architecture/decisions/0005-system-lists-as-status]]. The cost — two shapes behind one UI — is paid once in the domain layer by a sealed `CollectionRef` type, so there is one collection screen, not two.

## Enums

```sql
create type public.movie_status  as enum ('want_to_watch', 'watched');
create type public.list_role     as enum ('owner', 'member');
create type public.member_status as enum ('invited', 'accepted');
```

`movie_status` must never grow a `'favorite'` value. Favourite is orthogonal to watched — you can favourite something you have watched. If it is ever wanted it is a `boolean` column, not a third enum value. Writing it down here is the point.

## `profiles`

Mirrors `auth.users`, which is not client-readable. Without this table the shared-list screen cannot render a member's name or avatar.

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` PK | `references auth.users(id) on delete cascade` |
| `username` | `citext` | unique, `check (username ~ '^[a-z0-9_]{3,24}$')` — the invite handle |
| `display_name` | `text` | 1–60 chars |
| `avatar_path` | `text` | object path in the `avatars` bucket |
| `locale` | `text` | `'pt-BR'` or `'en'`, default `'pt-BR'`. **The per-user language setting** — [[architecture/decisions/0011-l10n-per-user-locale]] |
| `created_at` / `updated_at` | `timestamptz` | `updated_at` maintained by trigger |

Trigger `handle_new_user()` — `after insert on auth.users`, `security definer` — creates the row with a provisional username derived from the email local part, de-duplicated with a numeric suffix.

Clients never insert or delete: the trigger owns creation, the cascade owns deletion.

## `movies_cache`

TMDb metadata mirrored server-side so list queries return titles and posters without N round trips. This is not a performance nicety — it is what makes the single-RPC list screen possible at all. Reasoning: [[architecture/decisions/0006-mirror-tmdb-metadata]].

| Column | Type | Notes |
|---|---|---|
| `tmdb_id` | `integer` PK | |
| `title`, `original_title`, `overview` | `text` | `title` not null |
| `poster_path`, `backdrop_path` | `text` | TMDb relative paths |
| `release_date` | `date` | |
| `runtime_minutes` | `integer` | `> 0` when present |
| `genres` | `text[]` | default `'{}'` |
| `tmdb_vote_average` | `numeric(3,1)` | 0–10 |
| `trailer_youtube_key` | `text` | resolved from `/movie/{id}/videos` |
| `fetched_at` | `timestamptz` | staleness marker |

```sql
create index movies_cache_title_trgm_idx on public.movies_cache using gin (title gin_trgm_ops);
create index movies_cache_stale_idx on public.movies_cache (fetched_at);
```

Refreshed in the background when the details screen opens a film whose row is older than 30 days. The details screen always hits TMDb live anyway — the cache only backs list rendering.

## `user_movies`

The two system lists and the canonical rating, in one table.

| Column | Type | Notes |
|---|---|---|
| `user_id` | `uuid` | → `profiles(id)` on delete cascade |
| `tmdb_id` | `integer` | → `movies_cache(tmdb_id)` **on delete restrict** |
| `status` | `movie_status` | **nullable** — see below |
| `rating` | `numeric(3,1)` | null = unrated |
| `watched_at` | `timestamptz` | |
| `created_at` / `updated_at` | `timestamptz` | |

PK `(user_id, tmdb_id)` — one row per person per film, so a film cannot be in both system lists. The exclusivity is structural, not app-enforced.

```sql
-- 0-10 in half-point steps: 0, 0.5, 1.0 … 10.0
constraint rating_scale check (
  rating is null or (rating >= 0 and rating <= 10 and (rating * 10)::int % 5 = 0)
),
-- a rating cannot coexist with "want to watch"
constraint rating_not_unwatched check (
  rating is null or status is distinct from 'want_to_watch'
),
constraint watched_at_not_unwatched check (
  watched_at is null or status is distinct from 'want_to_watch'
),
-- the row has to justify its existence
constraint row_has_meaning check (
  status is not null or rating is not null or watched_at is not null
)
```

**Why `status` is nullable.** Removing a film from *Watched* keeps your rating — including where other members can already see it. The row survives with `status = null`, meaning "not in a system list, but I have watched and judged this". Dropping the rating as well is a separate, explicit action. Removing from *Want to watch* with nothing else on the row deletes it outright.

**`rating = 0` is a real score** ("it's terrible"); unrated is `NULL`. The rating control therefore needs an explicit *clear* affordance — dragging to zero must not read as unrated.

```sql
create index user_movies_user_status_idx on public.user_movies (user_id, status, created_at desc);
create index user_movies_tmdb_idx on public.user_movies (tmdb_id);              -- cross-member rating join
create index user_movies_top_rated_idx on public.user_movies (user_id, rating desc) where rating is not null;
```

The partial index is the recommendation-seed index — `get_recommendation_seeds` reads nothing else.

**The FK to `movies_cache` is `on delete restrict`**, so a library row can never exist for a film we have no metadata about. That is what guarantees list screens always render. It imposes a write order (cache first, entry second), handled atomically inside `set_library_entry` — never by a direct client insert.

## `lists`, `list_members`, `list_items`

### `lists`

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` PK | `default gen_random_uuid()` |
| `owner_id` | `uuid` | → `profiles(id)` on delete cascade |
| `name` | `text` | 1–60 chars |
| `description` | `text` | ≤ 500 chars |
| `cover_path` | `text` | object path in `list-covers` |
| `created_at` / `updated_at` | `timestamptz` | |

### `list_members`

| Column | Type | Notes |
|---|---|---|
| `list_id`, `user_id` | | composite PK |
| `role` | `list_role` | default `'member'` |
| `status` | `member_status` | default `'invited'` |
| `invited_by` | `uuid` | → `profiles(id)` on delete set null |
| `created_at`, `joined_at` | `timestamptz` | |

```sql
constraint joined_at_matches_status check ((status = 'accepted') = (joined_at is not null))
create unique index lists_single_owner_idx on public.list_members (list_id) where role = 'owner';
```

Trigger `lists_add_owner_as_member()` — `after insert on lists` — inserts the owner as an `accepted` member with role `owner`. This makes *owner ⊂ member* true by construction, so every policy and function uses one predicate (`is_list_member`) instead of repeating `owner_id = auth.uid() or exists (...)`. High leverage, one trigger.

**`status` is not ceremony.** Until someone accepts, they are not a member and their ratings are not exposed. Without it anyone could add you to a list and read your score for every film they put in it.

### `list_items`

| Column | Type | Notes |
|---|---|---|
| `list_id`, `tmdb_id` | | composite PK — a film cannot appear twice in a list. Free de-duplication |
| `added_by` | `uuid` | → `profiles(id)` on delete set null; UI falls back to "removed user" |
| `sort_order` | `integer` | manual ordering. Named `sort_order`, not `position` — `position` is a SQL function name |
| `note` | `text` | ≤ 280 chars, "why I added this" |
| `added_at` | `timestamptz` | |

Ordering within a list is `sort_order`, **not** a per-list rating — [[architecture/decisions/0004-global-ratings]].

## Storage buckets

| Bucket | Public read | Write |
|---|---|---|
| `avatars` | yes | path's first folder must equal `auth.uid()` |
| `list-covers` | yes | path's first folder must be a list the caller owns |

Public read is deliberate: covers and avatars are not sensitive, paths are UUID-scoped and unguessable, and public URLs are stable and CDN-cacheable — signed URLs would churn and defeat image caching. Writes stay policy-gated.

## RPCs

Full signatures and reasoning in [[architecture/security-model]].

| Function | Purpose |
|---|---|
| `is_list_member`, `is_list_owner`, `shares_list_with` | predicates used inside RLS policies |
| `get_list_items(p_list_id)` | list items + every accepted member's rating. The only cross-user read path |
| `set_library_entry(p_movie, p_status, p_rating)` | upsert cache then library entry, atomically |
| `clear_library_entry(p_tmdb_id)` | remove the row |
| `add_to_list(p_list_id, p_movie, p_note)` | upsert cache then insert the item |
| `refresh_movie_cache(p_movie)` | re-upsert stale metadata |
| `find_profile_by_username(p_username)` | exact match only, for invites |
| `invite_to_list`, `accept_list_invite` | membership transitions |
| `get_excluded_tmdb_ids()` | everything already in my library or my lists |
| `get_recommendation_seeds(p_limit)` | my top-rated films, best first |

## Known traps

| Trap | Consequence | Mitigation |
|---|---|---|
| Direct client insert into `user_movies` or `list_items` | foreign-key violation — the cache row does not exist yet | All writes go through `set_library_entry` / `add_to_list`. Never add a "quick" direct insert |
| `numeric(3,1)` over PostgREST | surfaces as `String` or `num` depending on driver version — a silent `type 'String' is not a subtype of type 'double'` crash on the rating field | Parse defensively in **one** helper (`num.parse(value.toString())`), not at nine call sites. Most likely runtime bug in this plan |
| Adding `'favorite'` to `movie_status` | silently breaks the watched/unwatched exclusivity | It is a boolean column, see above |
| Policy recursion on `list_members` | `infinite recursion detected in policy` | `security definer` helpers, and never `force row level security` — [[architecture/security-model]] |

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Schema specified for the MVP; no migrations written yet |
