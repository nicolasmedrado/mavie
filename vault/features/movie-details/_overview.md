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

Scrollable page showing, in order: poster, title, TMDb score with a star icon, synopsis. Loading is a centred `CircularProgressIndicator`; failure is `Text('Erro: $error')`.

Takes a `movieId` and fetches the film itself — it does not receive the `Movie` from the search results. That is intentional: `GET /movie/{id}` returns more than `/search/movie` does, so the details screen is the authoritative read.

## Code

| Layer | File |
|---|---|
| Page | [movie_details_page.dart](../../../lib/features/movies/presentation/pages/movie_details_page.dart) — `ConsumerWidget`, `movieAsync.when(data/error/loading)` |
| Provider | `movieDetailsProvider` — `FutureProvider.family<Movie, int>` in [movie_providers.dart](../../../lib/features/movies/presentation/providers/movie_providers.dart) |
| Data source | [movie_remote_data_source.dart](../../../lib/features/movies/data/datasources/movie_remote_data_source.dart) — `GET /movie/{id}` |

Shares its entity, repository and DI graph with [[features/movie-search/_overview]].

## Known gaps

- **The entity throws away most of the response.** `Movie` carries only `id`, `title`, `overview`, `posterPath`, `voteAverage` — so `runtime`, `genres`, `backdropPath` and `releaseDate` are fetched and discarded. The cause is one entity serving two differently-shaped endpoints; FND-04 splits it into `MovieSummary` and `MovieDetails`. See [[architecture/tmdb-integration]].
- Poster logic duplicated with the search page. FND-07.
- Styling is ad-hoc: hardcoded `Colors.amber`, literal `SizedBox` spacings, `BorderRadius.circular(8)`. FND-06.
- Portuguese strings (`'Detalhes do filme'`, `'Erro: $error'`). FND-08.
- No `errorBuilder` on `Image.network`. FND-07.

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
