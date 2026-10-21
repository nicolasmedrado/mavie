---
title: Shared widget library
sprint: foundations
feature: —
milestone: mvp
status: backlog
started_at:
finished_at:
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

- [ ] The five widgets, built on FND-06 tokens
- [ ] Both existing pages migrated to `MoviePoster` and `RatingDisplay`
- [ ] Both pages' error branches migrated to `AppErrorView`
- [ ] `cached_network_image` replaces `Image.network` everywhere
- [ ] Widget tests: null path, broken URL, `rating: 0` versus `rating: null`
- [ ] Tick the poster-duplication and `errorBuilder` rows in [[_meta/discrepancies]]

## Test scenario

1. Open a film with no poster
   - **Expected:** a styled placeholder, not a broken-image icon and not a layout jump
2. Airplane mode, open a previously-viewed film
   - **Expected:** the poster comes from cache
3. Render `RatingDisplay(rating: 0)` next to `RatingDisplay(rating: null)`
   - **Expected:** visibly different — `0` shows a score, `null` shows "not rated"

## Dependencies

- **Blocked by:** FND-06 (tokens), FND-05 (`AppErrorView` needs `AppFailure`)
- **Blocks:** every screen after

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | issue created |
