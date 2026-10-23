---
title: movies_cache table
sprint: backend
feature: —
milestone: mvp
status: done
started_at: 2026-10-22
finished_at: 2026-10-22
---

# BE-03 · `movies_cache` table

## Goal

TMDb metadata can be mirrored server-side, readable by any authenticated user, so list queries return titles and posters without N round trips to TMDb — see [[architecture/decisions/0006-mirror-tmdb-metadata]].

## Scope

- Layers: `supabase`
- Files: `supabase/migrations/20261022223451_create_movies_cache.sql`
- Data: `public.movies_cache`, trigram index on `title`, `fetched_at` staleness index, policy `movies_cache_select_authenticated`

## Checklist

- [x] `movies_cache` table keyed by `tmdb_id`: title fields, `poster_path`/`backdrop_path`, `release_date`, `runtime_minutes`, `genres text[]`, `tmdb_vote_average`, `trailer_youtube_key`, `fetched_at`
- [x] Constraints: `runtime_minutes_positive`, `tmdb_vote_average_range` (0–10)
- [x] `gin (title gin_trgm_ops)` index for title search; plain index on `fetched_at` for staleness queries
- [x] RLS enabled; single `select` policy, `using (auth.role() = 'authenticated')` — no per-row ownership, since this is one shared global cache
- [x] No write policy at all: a bad client write would corrupt titles/posters for every user. All writes happen inside `security definer` RPCs (`set_library_entry`, `add_to_list`, `refresh_movie_cache` — BE-07), which validate the payload shape and run as the function owner, bypassing grants entirely
- [x] `grant select on public.movies_cache to authenticated` — required because `auto_expose_new_tables = false`

## Test scenario

No manual device/UI step — verified against the local Dockerized Postgres via direct `psql`.

1. Select from `movies_cache` as `authenticated`
   - **Expected:** succeeds, returns rows
   - **Result:** confirmed
2. Select as `anon`
   - **Expected:** `permission denied`
   - **Result:** confirmed
3. Insert/update/delete directly as `authenticated` (not through an RPC)
   - **Expected:** `permission denied` — no write grant exists
   - **Result:** confirmed

## Dependencies

- **Blocked by:** BE-01
- **Blocks:** BE-07 (the definer RPCs that write to this table), MOV-03 (cache write-through)

## Notes

- Deliberately no write path at all yet — not even for the table owner's own convenience. Keeping it fully gated behind BE-07's RPCs from day one avoids ever having a client-writable window to retrofit security onto later.

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-22 | issue created and closed together with BE-01/BE-02 (execution slot E09). Table, index and RLS verified by direct SQL: authenticated read, anon denial, direct write denial. No manual step |
