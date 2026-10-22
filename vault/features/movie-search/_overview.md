---
title: Movie search
status: shipped
stack: flutter
last_review: 2026-10-21
---

# Movie search

Search TMDb by title and show the results as a list. The first feature built, and the search tab of the shell — the app still launches straight into it.

Documented retroactively from the shipped code on 2026-10-21. This describes **what the code actually does**, not what it should do.

## Behaviour

- A `TextField` lives in the `AppBar`. Typing is debounced **400 ms** before a request fires.
- Each result shows poster thumbnail, title, and TMDb score.
- Tapping a result pushes [[features/movie-details/_overview]].
- An empty query returns an empty list without calling the API.

## Code

| Layer | File |
|---|---|
| Page | [movie_search_page.dart](../../../lib/features/movies/presentation/pages/movie_search_page.dart) — `ConsumerStatefulWidget`, a local `Timer` for the debounce, `context.push(AppRoutes.movieDetails(id))` on tap |
| Providers | [movie_providers.dart](../../../lib/features/movies/presentation/providers/movie_providers.dart) — `tmdbDioProvider` → `movieRemoteDataSourceProvider` → `movieRepositoryProvider` (typed as the domain interface), `movieSearchQueryProvider` (`NotifierProvider<MovieSearchQueryNotifier, String>`), `movieSearchResultsProvider` (`FutureProvider<List<MovieSummary>>` watching the query) |
| Repository | [movie_repository.dart](../../../lib/features/movies/domain/repositories/movie_repository.dart) (interface) · [movie_repository_impl.dart](../../../lib/features/movies/data/repositories/movie_repository_impl.dart) (maps `MovieSummaryModel.toEntity()`) |
| Data source | [movie_remote_data_source.dart](../../../lib/features/movies/data/datasources/movie_remote_data_source.dart) — `GET /search/movie?query=` |
| Entity / model | [movie_summary.dart](../../../lib/features/movies/domain/entities/movie_summary.dart) · [movie_summary_model.dart](../../../lib/features/movies/data/models/movie_summary_model.dart) |
| Widgets | `MoviePoster(size: MoviePosterSize.thumbnail)`, `AppErrorView`, `AppLoadingIndicator` — [[architecture/overview]] |

Endpoint details: [[architecture/tmdb-integration]].

## Tests

[movie_search_page_test.dart](../../../test/features/movies/presentation/pages/movie_search_page_test.dart) — pumped via `test/support/pump_app.dart`'s `pumpApp`, with `FakeMovieRepository` (`test/support/fakes/`) overriding `movieRepositoryProvider`. Covers: debounce (0 calls after 100 ms, 1 call after 400 ms), results rendering, tapping navigates to `MovieDetailsPage`, the error/retry path, and that the empty-state prompt renders correctly in both English and Portuguese from the same ARB key.

[movie_remote_data_source_test.dart](../../../test/features/movies/data/datasources/movie_remote_data_source_test.dart) — `FakeHttpAdapter` (`test/support/fakes/`) on a bare `Dio`, capturing `lastRequest` to assert path and query parameters.

## Known gaps

All logged in [[_meta/discrepancies]] with the issue that resolves each:

- **Empty query and "no results" are the same state** — a real search that finds nothing shows the *"type something to search"* placeholder. MOV-04.
- **No pagination.** `page` is never sent, `total_pages` is ignored — only the first 20 results are reachable. MOV-04.

## Planned changes

| Issue | Change |
|---|---|
| MOV-04 | Pagination, skeletons, a real no-results state, recent searches |

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Documented retroactively from the shipped code, with known gaps recorded |
| 2026-10-21 | FND-02: moved to `features/movies/`; DI table folded into the providers row since `providers.dart` was dissolved and `movieClientProvider` renamed `tmdbDioProvider` |
| 2026-10-21 | FND-04: search results are now `MovieSummary`, serialized by `MovieSummaryModel` (`fromJson` + `toJson`) |
| 2026-10-21 | FND-06: result tile's thumbnail size, radius and placeholder colour migrated onto `core/theme/` tokens |
| 2026-10-21 | FND-07: result tile uses `MoviePoster`; errors render via `AppErrorView` with a working retry; loading uses `AppLoadingIndicator` |
| 2026-10-21 | FND-08 + FND-09: every string moved to ARB; tests migrated to the shared `pumpApp`/`FakeMovieRepository`/`FakeHttpAdapter` harness |
| 2026-10-21 | FND-10: `Navigator.push` replaced by `context.push(AppRoutes.movieDetails(id))`; the page is now the search tab of the shell, reached via `go_router` instead of being the app's `home` |
