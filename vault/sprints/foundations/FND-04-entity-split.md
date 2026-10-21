---
title: Entity split and serialization
sprint: foundations
feature: movie-details
milestone: mvp
status: backlog
started_at:
finished_at:
---

# FND-04 · Entity split and serialization

## Goal

Two entities that match the two differently-shaped TMDb responses, carrying every field the MVP needs, serializable in both directions.

## Scope

Today one `Movie` class serves both `/search/movie` and `/movie/{id}`:

```dart
class Movie {
  final int id; final String title; final String overview;
  final String? posterPath; final double voteAverage;
}
```

`/movie/{id}` returns runtime, genres, backdrop and release date — all **fetched and discarded**, because the shared class has nowhere to put them. And `MovieModel` has `fromJson` but no `toJson`, which blocks the `movies_cache` write path entirely.

### Target

| Type | Used by | Fields |
|---|---|---|
| `MovieSummary` | search results, list items, cache rows, carousels | `id`, `title`, `overview`, `posterPath`, `voteAverage`, `releaseDate` |
| `MovieDetails` | details screen, cache writes | everything in summary, plus `backdropPath`, `runtimeMinutes`, `genres`, `originalTitle` |

`MovieDetails` wraps a `MovieSummary` rather than extending it — composition keeps `MovieSummary` usable as a value everywhere without a downcast.

Both get `==` / `hashCode` / `copyWith` and `const` constructors, none of which exist today. By hand — no `freezed`, consistent with [[architecture/decisions/0002-riverpod-without-codegen]].

Models: `MovieSummaryModel` and `MovieDetailsModel` with `fromJson`, `toJson` and `toEntity`. `toJson` must produce the payload shape that `set_library_entry` and `add_to_list` expect — snake_case TMDb keys, so the RPC can upsert `movies_cache` directly from it.

`MovieRepository` splits accordingly: `searchMovies` returns `List<MovieSummary>`, `getMovieDetails` returns `MovieDetails`.

## Checklist

- [ ] `MovieSummary` and `MovieDetails` in `features/movies/domain/entities/`
- [ ] `==`, `hashCode`, `copyWith`, `const` constructors
- [ ] `MovieSummaryModel` / `MovieDetailsModel` with `fromJson` + **`toJson`** + `toEntity`
- [ ] Repository interface and implementation updated
- [ ] `movieDetailsProvider` returns `MovieDetails`; `movieSearchResultsProvider` returns `List<MovieSummary>`
- [ ] Details page renders year, runtime and genres
- [ ] Model tests cover both shapes, missing-field defaults, and a `toJson` → `fromJson` round trip
- [ ] Capture real TMDb JSON into `test/support/fixtures/` (coordinate with FND-09)
- [ ] Tick the `toJson` row in [[_meta/discrepancies]]

## Test scenario

1. Open a film with no runtime or no genres in TMDb
   - **Expected:** those rows are omitted, no crash, no "null"
2. `toJson(fromJson(fixture))` equals the relevant subset of the fixture
   - **Expected:** round-trip stable — this is what `movies_cache` correctness depends on

## Dependencies

- **Blocked by:** FND-02
- **Blocks:** MOV-01, MOV-03, BE-07 (the RPC payload shape), LIB-02
- Parallel with FND-05

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | issue created |
