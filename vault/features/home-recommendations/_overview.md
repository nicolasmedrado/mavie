---
title: Home and recommendations
status: planned
stack: flutter + tmdb
last_review: 2026-10-21
---

# Home and recommendations

The app's landing screen: carousels of films to discover, seeded by what you rated highly. This is what closes the core loop — rating a film feeds the suggestions that lead to the next one.

> **Not built.** Sprint HOME, issues HOME-01 … HOME-06.

## Scope

- Sectioned feed of horizontal carousels
- *Because you liked X* — recommendations seeded from your highest-rated films
- *Trending this week* — the cold-start fallback
- *Want to watch* — a shortcut into your own watchlist
- *Recently added to shared lists*

## Design

Pure TMDb, no recommendation model of our own:

1. `get_recommendation_seeds(10)` → your highest-rated `tmdb_id`s, read from the partial index on `user_movies`.
2. One `GET /movie/{id}/recommendations` per seed.
3. Flatten, de-duplicate, and drop everything in `get_excluded_tmdb_ids()` — your library plus every film in your lists.
4. Rank: films recommended by several seeds above films recommended by one, tie-broken by the seed's rating, then by TMDb popularity.

**Step 4 is a pure function** — `List<MovieSummary> rank(seeds, candidates, excluded)` — with no I/O, so it is unit-testable in isolation. It is the single most valuable test in the project and the piece most worth showing off (HOME-06).

**Cold start.** A new account has no ratings, so seeds come back empty and the feed falls back to `/trending/movie/week`. This is the state a recruiter opening the app will see, so it has to look finished, not empty.

**Cost.** Ten requests per refresh. Within TMDb's limits, but wasteful on every scroll — hence the in-memory TTL cache in HOME-04, invalidated when a rating or a list changes.

Endpoint details: [[architecture/tmdb-integration]].

## Dependencies

- **Blocked by** LIB-04 — with no ratings there are no seeds, so this cannot be meaningfully built or tested before the rating feature works
- **Blocked by** BE-10 (`get_recommendation_seeds`, `get_excluded_tmdb_ids`)
- HOME-02 and HOME-06 are a pure algorithm plus tests and **can be written before the home UI exists** — a useful parallel lane

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Specified as part of the MVP |
