---
title: Mirror TMDb metadata in `movies_cache`
status: accepted
date: 2026-10-21
---

# 0006 — Mirror TMDb metadata in `movies_cache`

## Context

Lists store `tmdb_id`s. Rendering a list needs titles, posters and years, which live at TMDb. Either the server keeps a copy, or the client fetches each film by id.

## Decision

Mirror the metadata we display into a `movies_cache` table in Postgres. Clients never write it directly — writes happen inside definer RPCs.

## Alternatives considered

**Client-side fetch per id.** No extra table, never stale. Rejected for four reasons, in order of force:

1. **It makes the single-RPC list screen impossible.** Without a server-side copy, `get_list_items` can only return integers — and then the cross-member rating design in [[architecture/security-model]] collapses into a second cross-user query path plus N metadata calls.
2. **TMDb has no bulk-fetch-by-ids endpoint.** A 40-item list is 40 mobile round trips with 40 independent failure modes.
3. **Searching or sorting your own library** by title needs titles server-side.
4. **Recommendation exclusion** belongs next to the data it excludes.

## Consequences

- One round trip renders a whole list screen.
- Metadata can go stale. Mitigated by `fetched_at` plus a background refresh when the details screen opens a row older than 30 days. The details screen hits TMDb live anyway — the cache only backs list rendering.
- `user_movies` and `list_items` both have a foreign key into `movies_cache`, so writes are ordered: cache first, then the row. Handled atomically inside `set_library_entry` and `add_to_list`. **A direct client insert will fail with a foreign-key violation** — never add one as a shortcut.
- `movies_cache` has **no write policies at all**. It is shared by both users; a bad client write would corrupt metadata for both.
- `MovieModel` needs a `toJson`, which it does not have today (FND-04).
- TMDb's terms permit caching and require attribution — DOC-06.
- Hardening path: a Supabase Edge Function that fetches TMDb server-side, which also resolves [[architecture/decisions/0012-tmdb-key-in-client]].
