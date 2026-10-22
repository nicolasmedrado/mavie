---
title: Post-MVP
status: active
last_review: 2026-10-21
---

# Post-MVP

Ideas deliberately left out of [[product/mvp]], each with the reason and what it would cost. Kept so the same debate is not reopened from memory every few weeks.

## Considered and deferred

| Idea | Why not now | What it would take |
|---|---|---|
| **Rewatch diary** | A `watch_log` of dated entries with per-viewing scores is the Letterboxd model and genuinely nice, but it changes what "your rating" means and the MVP needs one unambiguous number to seed recommendations | New `watch_log` table; `user_movies.rating` stays canonical as the latest or the average |
| **Public lists by link** | High demo value — a recruiter could see a shared list without signing up — but it opens an anonymous read path through exactly the tightest part of [[architecture/security-model]] | A `public_slug` column plus a dedicated definer function returning items **without** ratings |
| **Realtime updates** | Table RLS on `user_movies` is own-rows-only, so Realtime cannot deliver another member's rating. For two people, refresh-on-focus is indistinguishable | A `list_activity` table written by a trigger, readable by list members — doubles as an activity feed. [[architecture/decisions/0013-no-realtime-in-mvp]] |
| **Offline mode** | Supabase is the source of truth and the app is useless offline anyway (no cached posters, no search) | `drift` mirroring the Postgres model, plus a sync strategy. [[architecture/decisions/0008-drop-hive]] |
| **Favorites** | Orthogonal to watched/unwatched, so it must **not** become a third value of the `movie_status` enum — that would be a bug, not a feature | A `user_movies.is_favorite boolean` column |
| **Per-rating visibility** | Hiding a score from one list but not another is speculative. The design keeps it cheap: the "who may see whose rating" predicate lives in exactly one function | One column plus one `AND` in `get_list_items`. [[architecture/decisions/0007-cross-member-reads-via-rpc]] |
| **Comments / reactions on films** | Fun for a couple's app, but it is a whole content-moderation-shaped surface and the MVP already has `list_items.note` as a lightweight outlet | New table, notifications, read state |
| **TV series** | Doubles the TMDb integration (different endpoints, seasons, episodes) and makes "watched" a much harder concept | Separate media type throughout the schema |
| **Streaming availability** | TMDb `/watch/providers` is region-locked and its data is patchy; it would be a visible quality problem | One endpoint, plus region handling |
| **Push notifications** | Nothing in the MVP is time-sensitive | FCM, device tokens, an Edge Function |
| **Collaborative "what do we watch tonight"** | The most interesting idea here — a shortlist both vote on. Depends on shared lists existing first | Voting session entity; worth revisiting right after the MVP |

## Technical debt accepted for the MVP

| Debt | Risk | Repayment path |
|---|---|---|
| TMDb key ships inside the app bundle | Read-only key; worst case is rate-limit abuse of one account | Route TMDb through a Supabase Edge Function with a server-held key. [[architecture/decisions/0012-tmdb-key-in-client]] |
| Supabase free tier pauses a project after 7 days idle | A recruiter opens the app and nothing works | A scheduled ping, or an explicit cold-start state in the UI |
| Recommendation fan-out is N requests per refresh | Fine within TMDb limits, wasteful on every scroll | In-memory TTL cache, HOME-04 |
| No rate limiting on RPCs | Two trusted users | Supabase rate limits if it ever opens up |
| TMDb film metadata (titles, synopses) is not localized — only the UI chrome is | A user whose UI is in Portuguese still reads an English synopsis | Send `language` per request (no schema change, the details screen already hits TMDb live); per-locale caching only if that alone isn't enough. [[architecture/decisions/0015-tmdb-metadata-not-localized]] |

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Created alongside the MVP spec, to record what was excluded and why |
| 2026-10-21 | FND-08: TMDb metadata localization added as accepted debt, decision recorded in ADR-0015 |
