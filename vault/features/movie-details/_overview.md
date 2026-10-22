---
title: Movie details
status: shipped
stack: flutter
last_review: 2026-10-21
---

# Movie details

The screen for one film. Reached by tapping a search result.

Documented retroactively from the shipped code on 2026-10-21. This describes **what the code actually does**.

## Behaviour

Scrollable page showing, in order: poster, title, a metadata line (year · runtime · genres, each part omitted when TMDb has none), TMDb score, synopsis. Loading is `AppLoadingIndicator`; failure is `AppErrorView` with a working retry button that re-fetches via `ref.invalidate`.

Takes a `movieId` and fetches the film itself — it does not receive the `MovieSummary` from the search results. That is intentional: `GET /movie/{id}` returns more than `/search/movie` does, so the details screen is the authoritative read.

## Code

| Layer | File |
|---|---|
| Page | [movie_details_page.dart](../../../lib/features/movies/presentation/pages/movie_details_page.dart) — `ConsumerWidget`, `movieAsync.when(data/error/loading)` |
| Provider | `movieDetailsProvider` — `FutureProvider.family<MovieDetails, int>` in [movie_providers.dart](../../../lib/features/movies/presentation/providers/movie_providers.dart) |
| Repository | [movie_repository_impl.dart](../../../lib/features/movies/data/repositories/movie_repository_impl.dart) (maps `MovieDetailsModel.toEntity()`) |
| Data source | [movie_remote_data_source.dart](../../../lib/features/movies/data/datasources/movie_remote_data_source.dart) — `GET /movie/{id}` |
| Entity / model | [movie_details.dart](../../../lib/features/movies/domain/entities/movie_details.dart) — wraps a `MovieSummary` by composition, plus `backdropPath`, `runtimeMinutes`, `genres` (`List<String>`), `originalTitle` · [movie_details_model.dart](../../../lib/features/movies/data/models/movie_details_model.dart) (`fromJson` + `toJson`, snake_case `movies_cache`-shaped) |
| Widgets | `MoviePoster(size: MoviePosterSize.hero)`, `RatingDisplay`, `AppErrorView`, `AppLoadingIndicator` — [[architecture/overview]] |

Shares its repository and DI graph with [[features/movie-search/_overview]]; `MovieDetails` composes `MovieSummary` rather than extending it, so a `MovieSummary` is usable as a value everywhere without a downcast — [[architecture/decisions/0001-feature-first-modules]] territory, decided in FND-04.

## Tests

[movie_details_page_test.dart](../../../test/features/movies/presentation/pages/movie_details_page_test.dart) — pumped via `pumpApp` with `FakeMovieRepository` (`test/support/`). Covers the metadata line rendering (year, runtime, genres), that it is omitted entirely when TMDb has none of them with no stray `"null"` text, and that `AppErrorView`'s retry button re-fetches — `pumpApp` disables Riverpod's automatic retry by default so the test observes the explicit retry in isolation ([[architecture/overview]]).

[movie_details_model_test.dart](../../../test/features/movies/data/models/movie_details_model_test.dart) — `fromJson` against a real TMDb fixture and a minimal one with no runtime/genres, plus the `toJson` cache-shape mapping.

## Known gaps

- Film titles and synopses are not localized — accepted debt, [[architecture/decisions/0015-tmdb-metadata-not-localized]].

## Planned changes

This screen is where most of the MVP converges.

| Issue | Change |
|---|---|
| MOV-01 | Redesign on the design system: backdrop, genres, runtime, year |
| MOV-02 | **Trailer** — `/movie/{id}/videos`, embedded YouTube player, graceful absence |
| MOV-05 | "In your lists" — which of your lists already contain this film |
| LIB-03 | Status actions: add to *Want to watch*, move to *Watched*, remove |
| LIB-04 | Rating picker, 0–10 in half points, with an explicit clear action |
| LIB-06 | Your score beside the TMDb score |
| MOV-03 | Every add writes through to `movies_cache` |

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Documented retroactively from the shipped code, with known gaps recorded |
| 2026-10-21 | FND-02: moved to `features/movies/` |
| 2026-10-21 | FND-04: entity split into `MovieSummary`/`MovieDetails`; details page now renders year, runtime and genres; `toJson` added |
| 2026-10-21 | FND-06: migrated off hardcoded `Colors.amber`/`SizedBox`/`BorderRadius.circular` onto `core/theme/` tokens |
| 2026-10-21 | FND-07: poster via `MoviePoster`, rating via `RatingDisplay`, errors via `AppErrorView` with a working retry, loading via `AppLoadingIndicator` |
| 2026-10-21 | FND-08 + FND-09: app bar title, runtime unit and `AppErrorView`/`RatingDisplay` strings moved to ARB; test migrated to the shared `pumpApp`/`FakeMovieRepository` harness |
