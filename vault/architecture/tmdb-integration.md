---
title: TMDb integration
status: in_progress
last_review: 2026-10-21
---

# TMDb integration

[TMDb](https://www.themoviedb.org) is the source of all film metadata. Supabase stores what belongs to a user; TMDb stores what belongs to the film.

## Client

[dio_client.dart](../../lib/data/datasources/dio_client.dart) — one `Dio` instance:

```dart
const tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';

baseUrl: 'https://api.themoviedb.org/3'
queryParameters: {'api_key': dotenv.env['TMDB_API_KEY']}
connectTimeout: Duration(seconds: 8)
```

Auth is the **v3 `api_key` query parameter**, not the v4 bearer token. No interceptors, no retry, no `receiveTimeout`, no `language` or `region` parameter — all of which are gaps, not decisions.

Image paths come back relative (`/abc123.jpg`) and are prefixed with `tmdbImageBaseUrl` at the call site. Poster size is fixed at `w500`.

## Endpoints

| Endpoint | Used for | Status |
|---|---|---|
| `GET /search/movie?query=` | title search | **live** |
| `GET /movie/{id}` | details screen | **live** |
| `GET /movie/{id}/videos` | trailer | MOV-02 |
| `GET /movie/{id}/recommendations` | home carousels | HOME-02 |
| `GET /trending/movie/week` | cold-start home | HOME-03 |

### Trailer selection (MOV-02)

`/movie/{id}/videos` returns a mixed list. Pick the first entry where `site == 'YouTube'` and `type == 'Trailer'`, preferring `official == true`; fall back to `type == 'Teaser'`. Many films have none — the absent case is normal UI, not an error. The chosen key is cached in `movies_cache.trailer_youtube_key`.

### Recommendations (HOME-02)

1. `get_recommendation_seeds(10)` → my highest-rated `tmdb_id`s.
2. One `/movie/{id}/recommendations` call per seed.
3. Flatten, de-duplicate, drop everything in `get_excluded_tmdb_ids()`.
4. Rank — films recommended by several seeds rank above films recommended by one, tie-broken by the seed's rating and then TMDb popularity.

Step 4 is a **pure function** `List<MovieSummary> rank(seeds, candidates, excluded)`, so it is unit-testable with no I/O. It is the single most valuable test in the project.

Cold start: a brand-new account has no ratings, so seeds come back empty and the home falls back to `/trending/movie/week`.

Cost: ten requests per refresh. Fine within TMDb's limits, wasteful on every scroll — hence the TTL cache in HOME-04.

## Caching in Postgres

Film metadata is mirrored into `movies_cache` — [[architecture/decisions/0006-mirror-tmdb-metadata]]. Four reasons, in order of force:

1. **It is what makes the single-RPC list screen possible.** Without a server-side copy, `get_list_items` could only return integers, and the whole [[architecture/security-model]] design collapses into a second cross-user query path plus N TMDb calls.
2. **TMDb has no bulk-fetch-by-ids endpoint.** A 40-item list would be 40 round trips on mobile, with 40 independent failure modes.
3. **Searching or sorting your own library** by title requires titles server-side.
4. **Recommendation exclusion** belongs next to the data it excludes.

Staleness: posters and titles change rarely, runtime and genres effectively never. `fetched_at` older than 30 days triggers a background `refresh_movie_cache` when the details screen opens. The details screen hits TMDb live regardless — the cache only backs list rendering.

Clients never write the cache directly. Writes happen inside `set_library_entry`, `add_to_list` and `refresh_movie_cache`, which validate the payload shape. A bad client write would corrupt metadata for **both** users.

## Two entities, not one

`/search/movie` results and `/movie/{id}` responses are different shapes, and the current `Movie` class forces both into one — which is why `runtime`, `genres`, `backdropPath` and `releaseDate` are missing today. FND-04 splits them:

- `MovieSummary` — search results, list items, cache rows
- `MovieDetails` — the details screen and cache writes

`MovieModel` also has no `toJson`, which blocks the cache write path entirely. Same issue.

## API key: accepted risk

`.env` is registered as a Flutter asset, so **the key ships inside the app bundle** and `unzip` + `strings` recovers it.

It is a read-only key. The exposure is rate-limit abuse of one TMDb account, not data loss. Accepted for the MVP — [[architecture/decisions/0012-tmdb-key-in-client]]. The fix is routing TMDb through a Supabase Edge Function with a server-held key, which is wanted anyway for server-side cache writes.

Local setup for the key: [[operations/local-setup]].

## Attribution

TMDb's terms permit caching and **require attribution**. The About screen and the README must carry:

> This product uses the TMDB API but is not endorsed or certified by TMDB.

plus the TMDb logo. Issue DOC-06.

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Documented the shipped client and endpoints; specified trailer, recommendations and the caching strategy |
