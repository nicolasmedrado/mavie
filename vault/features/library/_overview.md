---
title: Personal library
status: planned
stack: flutter + supabase
last_review: 2026-10-21
---

# Personal library

Your own films: the two system lists and your scores. This is the feature the whole product turns around — [[product/mvp]] step 3 and 4 of the core loop.

> **Not built.** Sprint LIB, issues LIB-01 … LIB-08.

## Scope

- Two system lists: **Want to watch** and **Watched**
- A **0–10 rating in half points**, one per person per film
- Status actions on the details screen: add, move, remove
- A library tab with both lists, sortable and filterable by rated/unrated
- Your score shown beside the TMDb score

## Design

Everything lives in one table, `user_movies`, keyed `(user_id, tmdb_id)` — [[architecture/decisions/0005-system-lists-as-status]]. The two system lists are the `status` column, so a film cannot be in both: the exclusivity is structural, not app-enforced.

The rating lives on the same row and is **global per (user, film)** — rate Dune 8.5 and that is true on your profile and in every shared list containing it. [[architecture/decisions/0004-global-ratings]].

### Rules that the UI must respect

| Rule | Consequence for the UI |
|---|---|
| `0` is a real score; unrated is `NULL` | The picker needs an explicit **clear rating** action. Dragging to zero must not mean unrated |
| Half points only | Input snaps to 0.5; `8.3` is rejected by a database constraint, so it must be unrepresentable in the UI |
| A rating cannot coexist with *Want to watch* | Rating a film from the watchlist moves it to *Watched* in the same action |
| Removing from *Watched* keeps the rating | `status` becomes `null`. Dropping the score is a **separate, explicit** action — and the confirmation should say the score is being kept |
| Removing from *Want to watch* with no rating | Deletes the row outright |

### Collection abstraction

System lists and custom lists have different shapes, which would otherwise grow two parallel list screens. Paid once, in LIB-01:

```dart
sealed class CollectionRef {}
class SystemCollection extends CollectionRef { final MovieStatus status; }
class CustomCollection extends CollectionRef { final String listId; }
```

One collection page, one item tile, two repository branches. Build it **before** either list UI.

### Writes

All writes go through the `set_library_entry` RPC, which upserts `movies_cache` and then `user_movies` atomically. A direct client insert fails on the foreign key, by design — [[architecture/decisions/0006-mirror-tmdb-metadata]].

Writes are optimistic with rollback: an `AsyncNotifier` updates local state immediately and reverts with a snackbar on failure (LIB-07). Rating a film is the most frequent action in the app and must not feel like a round trip.

### A trap

`rating` is `numeric(3,1)`, and PostgREST serializes `numeric` as `String` or `num` depending on driver version. Parse it defensively in **one** helper, not at nine call sites — `type 'String' is not a subtype of type 'double'` on the rating field is the most likely runtime crash in the whole MVP. See [[architecture/data-model]].

## Dependencies

- **Blocked by** AUTH-03 (a current user) and BE-04 + BE-07 (table and write RPCs)
- **Blocks** [[features/home-recommendations/_overview]] — no ratings, no seeds
- Shares the rating display widget with [[features/lists/_overview]]

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Specified as part of the MVP |
