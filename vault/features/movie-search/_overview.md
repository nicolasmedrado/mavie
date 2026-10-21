---
title: Movie search
status: shipped
stack: flutter
last_review: 2026-10-21
---

# Movie search

Search TMDb by title and show the results as a list. The first feature built, and the only entry point into the app today — `main.dart` opens straight onto it.

Documented retroactively from the shipped code on 2026-10-21. This describes **what the code actually does**, not what it should do.

## Behaviour

- A `TextField` lives in the `AppBar`. Typing is debounced **400 ms** before a request fires.
- Each result shows poster thumbnail, title, and TMDb score.
- Tapping a result pushes [[features/movie-details/_overview]].
- An empty query returns an empty list without calling the API.

## Code

| Layer | File |
|---|---|
| Page | [movie_search_page.dart](../../../lib/features/movies/presentation/pages/movie_search_page.dart) — `ConsumerStatefulWidget`, a local `Timer` for the debounce, `Navigator.push(MaterialPageRoute(...))` on tap |
| Providers | [movie_providers.dart](../../../lib/features/movies/presentation/providers/movie_providers.dart) — `tmdbDioProvider` → `movieRemoteDataSourceProvider` → `movieRepositoryProvider` (typed as the domain interface), `movieSearchQueryProvider` (`NotifierProvider<MovieSearchQueryNotifier, String>`), `movieSearchResultsProvider` (`FutureProvider<List<Movie>>` watching the query) |
| Repository | [movie_repository.dart](../../../lib/features/movies/domain/repositories/movie_repository.dart) (interface) · [movie_repository_impl.dart](../../../lib/features/movies/data/repositories/movie_repository_impl.dart) (maps `MovieModel.toEntity()`) |
| Data source | [movie_remote_data_source.dart](../../../lib/features/movies/data/datasources/movie_remote_data_source.dart) — `GET /search/movie?query=` |
| Entity / model | [movie.dart](../../../lib/features/movies/domain/entities/movie.dart) · [movie_model.dart](../../../lib/features/movies/data/models/movie_model.dart) |

Endpoint details: [[architecture/tmdb-integration]].

## Tests

[movie_search_page_test.dart](../../../test/features/movies/presentation/pages/movie_search_page_test.dart) — `_FakeMovieRepository` with a `searchCallCount` spy, injected via `ProviderScope(overrides: [movieRepositoryProvider.overrideWithValue(...)])`. Covers: debounce (0 calls after 100 ms, 1 call after 400 ms), results rendering, and that tapping navigates to `MovieDetailsPage`.

[movie_remote_data_source_test.dart](../../../test/features/movies/data/datasources/movie_remote_data_source_test.dart) — `_FakeAdapter implements HttpClientAdapter` on a bare `Dio`, capturing `lastRequest` to assert path and query parameters.

## Known gaps

All logged in [[_meta/discrepancies]] with the issue that resolves each:

- **Empty query and "no results" are the same state** — a real search that finds nothing shows the *"type something to search"* placeholder. MOV-04.
- **No pagination.** `page` is never sent, `total_pages` is ignored — only the first 20 results are reachable. MOV-04.
- UI strings hardcoded in Portuguese; three test assertions depend on them. FND-08 + FND-09.
- Poster logic duplicated with the details page. FND-07.
- `Image.network` with no `errorBuilder` or `loadingBuilder`, no caching. FND-01 + FND-07.
- No `AppErrorView` — errors render as `Text('Erro: $error')`. FND-05.

## Planned changes

| Issue | Change |
|---|---|
| FND-07 | Result tile uses the shared `MoviePoster` |
| FND-10 | `Navigator.push` becomes `context.push('/movie/:id')`; the page becomes a shell tab |
| MOV-04 | Pagination, skeletons, a real no-results state, recent searches |

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Documented retroactively from the shipped code, with known gaps recorded |
| 2026-10-21 | FND-02: moved to `features/movies/`; DI table folded into the providers row since `providers.dart` was dissolved and `movieClientProvider` renamed `tmdbDioProvider` |
