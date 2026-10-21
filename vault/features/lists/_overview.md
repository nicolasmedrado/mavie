---
title: Custom and shared lists
status: planned
stack: flutter + supabase
last_review: 2026-10-21
---

# Custom and shared lists

User-created lists that behave like playlists — renameable, with a cover image, a description, members and films. Sharing one means both members see each other's scores on the films inside it.

**This is the headline feature of the product.** Everything else exists to support it.

> **Not built.** Sprint LST, issues LST-01 … LST-08.

## Scope

- Create, rename, describe a list; upload a cover image
- Add films from search; remove; reorder
- Invite a member by username; the invited person accepts
- Per film, show **every accepted member's score** once watched
- Leave a list; the owner removes a member; the owner deletes the list
- An optional short note per film ("why I added this")

## Design

Three tables — `lists`, `list_members`, `list_items` — detailed in [[architecture/data-model]].

**The owner is a member.** A trigger inserts the owner into `list_members` as an `accepted` member with role `owner` when the list is created. That makes *owner ⊂ member* true by construction, so every policy and function uses one predicate, `is_list_member`, instead of repeating `owner_id = auth.uid() or exists (...)`.

**Membership requires acceptance.** The owner invites, the invited person accepts. This is not ceremony — it is what makes the rating-visibility rule honest. Without it, anyone could add you to a list and start reading your score for every film they put in it.

**A film cannot appear twice** in the same list: `primary key (list_id, tmdb_id)`. Free de-duplication.

**Ordering is `sort_order`, not a rating.** A list can be ranked; that is ordering. Scores stay global — [[architecture/decisions/0004-global-ratings]].

### The hard part: reading other members' scores

Scores live in `user_movies`, which is private. The entire list screen is rendered by one RPC, `get_list_items(p_list_id)`, which authorizes once and returns each item joined to its metadata and to the ratings of accepted members, aggregated as `jsonb`.

There is no cross-user `select` policy on `user_movies`, deliberately — a policy keyed on "film co-present in a shared list" would make a *read* permission depend on a *write* either member can perform, and a thousand added films would mean a thousand harvested ratings. Full reasoning: [[architecture/security-model]] and [[architecture/decisions/0007-cross-member-reads-via-rpc]].

**BE-12 proves the policies before any of this UI is built.** With two trusted users an RLS bug never surfaces on its own.

### Consequences for the UI

- A member who has not watched a film has no `user_movies` row for it, so the ratings array simply omits them. The tile needs a "not watched yet" state per member, not a zero.
- Scores do not arrive live — Realtime cannot deliver another member's rating ([[architecture/decisions/0013-no-realtime-in-mvp]]). Refresh on focus and on pull.
- Cover uploads need client-side resize and compression, or the bucket fills with 4 MB phone photos.
- `added_by` is nullable (`on delete set null`), so the UI falls back to "removed user".

## Dependencies

- **Blocked by** BE-05, BE-06, **BE-12**, BE-08, BE-09, BE-11 (covers bucket) and AUTH-07 (usernames exist to invite)
- Reuses the `CollectionRef` abstraction and the rating widgets from [[features/library/_overview]]

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Specified as part of the MVP |
