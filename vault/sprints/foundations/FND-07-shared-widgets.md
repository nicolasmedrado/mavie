---
title: Shared widget library
sprint: foundations
feature: —
milestone: mvp
status: done
started_at: 2026-10-21
finished_at: 2026-10-21
---

# FND-07 · Shared widget library

## Goal

The widgets every screen needs exist once, built on the FND-06 tokens. Starting with the poster, which is currently copy-pasted into both existing pages.

## Scope

Files: `lib/core/widgets/`

| Widget | Replaces / provides |
|---|---|
| `MoviePoster` | The duplicated `Image.network('$tmdbImageBaseUrl${movie.posterPath}')` in both pages. Adds `cached_network_image`, a loading placeholder, an error fallback, a null-path fallback, and size variants (thumbnail / card / hero) |
| `RatingDisplay` | Read-only 0–10 score with the semantic rating colour. Used on details, in library rows, in member chips. Must render `0` distinctly from "unrated" |
| `AppErrorView` | Switches on the sealed `AppFailure` from FND-05, shows a localized message and a retry action. Replaces `Text('Erro: $error')` |
| `AppEmptyView` | Icon, message, optional action. Used by search-with-no-results, an empty library, a list with no films |
| `AppLoadingIndicator` | One spinner, consistently placed |

`RatingPickerSheet` (interactive) belongs to LIB-04, not here — this issue is read-only presentation.

### Two rules worth stating

**`MoviePoster` takes a `posterPath`, not a `Movie`.** It is used with summaries, details and cache rows; coupling it to one entity would force conversions at call sites.

**`RatingDisplay` takes a `double?`.** `null` is unrated, `0` is a real score meaning "terrible". Rendering them the same way is the bug this widget exists to prevent — see [[features/library/_overview]].

## Checklist

- [x] The five widgets, built on FND-06 tokens
- [x] Both existing pages migrated to `MoviePoster` and `RatingDisplay` (search has no rating UI to migrate — `RatingDisplay` applies to the details screen only)
- [x] Both pages' error branches migrated to `AppErrorView`
- [x] `cached_network_image` replaces `Image.network` everywhere
- [x] Widget tests: null path, broken URL, `rating: 0` versus `rating: null`
- [x] Tick the poster-duplication and `errorBuilder` rows in [[_meta/discrepancies]]

## Test scenario

1. Open a film with no poster
   - **Expected:** a styled placeholder, not a broken-image icon and not a layout jump
   - **Result:** automated — `movie_poster_test.dart` covers both the null-path and the broken-URL case (a scoped `HttpOverrides` forces the fetch to fail deterministically, no real network needed); both fall back to the same placeholder, same fixed size
2. Airplane mode, open a previously-viewed film
   - **Expected:** the poster comes from cache
   - **Found not achievable yet, tested on a physical device:** opening *any* film's details requires a live `GET /movie/{id}` for the metadata (title, overview, score, genres, runtime) — nothing is cached locally except the poster bytes themselves. Offline, `AppErrorView` renders before the poster ever gets a chance to load from cache, for every film, not just uncached ones. `movies_cache` (BE-03) only backs server-side list rendering, not client offline reads — [[architecture/tmdb-integration]]. True offline viewing of a previously-seen film isn't possible until a local read path exists, which isn't scoped for any current issue. Logged in [[_meta/discrepancies]].
   - What *was* confirmed on-device: `AppErrorView` with a working "Tentar novamente" button appears correctly in both the search screen (offline search) and the details screen (offline open) — exercising exactly the retry wiring this issue built
3. Render `RatingDisplay(rating: 0)` next to `RatingDisplay(rating: null)`
   - **Expected:** visibly different — `0` shows a score, `null` shows "not rated"
   - **Result:** automated — `rating_display_test.dart`

**Also found in passing:** Riverpod's default automatic retry (`ProviderContainer.defaultRetry`, up to 10 attempts with exponential backoff, ~38s total) was masking every failure behind `AsyncLoading` — the `error` branch (and therefore `AppErrorView`) never rendered until all 10 retries exhausted. Disabled app-wide in `main.dart`. See [[architecture/overview]] and [[_meta/discrepancies]].

## Dependencies

- **Blocked by:** FND-06 (tokens), FND-05 (`AppErrorView` needs `AppFailure`)
- **Blocks:** every screen after

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | issue created |
| 2026-10-21 | Five widgets added (`core/widgets/`), both pages migrated. `flutter analyze` clean, 42 tests green. Also fixed Riverpod's ~38s auto-retry masking errors. Pending your manual airplane-mode/cache check |
| 2026-10-21 | Manual check on a physical device: the airplane-mode poster-cache scenario isn't achievable yet (whole-screen dependency on live metadata, not a `MoviePoster` defect); `AppErrorView`'s retry confirmed working in both pages. Issue closed |
