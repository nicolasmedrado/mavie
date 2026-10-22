---
title: Localization
status: shipped
stack: flutter + supabase
last_review: 2026-10-21
---

# Localization

Portuguese and English, with the language chosen **per user** rather than per device.

This is not a nice-to-have on this project: the two actual users want different languages. Nicolas runs the app in English, his girlfriend in Portuguese, on different phones, against the same shared data. [[architecture/decisions/0011-l10n-per-user-locale]].

## Scope

- `flutter_localizations` + `intl`, `generate: true`, `l10n.yaml` — generates into `lib/l10n/generated/` (gitignored, rebuilt by `flutter pub get`)
- `app_en.arb` (template) and `app_pt.arb`, in [lib/l10n/arb/](../../../lib/l10n/arb/)
- Every user-visible string extracted
- `localeProvider` ([locale_provider.dart](../../../lib/core/l10n/locale_provider.dart)) resolves device locale → `pt` fallback
- A language selector in Settings, persisted to `profiles.locale`, and wired to `localeProvider` — **not built yet**, needs AUTH-07

## Design

**What is translated and what is not:**

| Content | Where it lives |
|---|---|
| UI chrome, buttons, empty states, errors | ARB files |
| System list names (*Want to watch*, *Watched*) | ARB keys `libraryStatusWantToWatch`/`libraryStatusWatched`, ready for LIB-01 — keyed off the `movie_status` enum once it exists, **never stored in the database** |
| `AppFailure` variants | ARB keys, consumed by `AppErrorView`'s exhaustive switch — errors are translatable by construction |
| Custom list names and descriptions | `lists.name` / `lists.description`, verbatim — the user typed them, they are content, not chrome |
| Film titles and synopses | **Not localized** — accepted debt, see [[architecture/decisions/0015-tmdb-metadata-not-localized]] |

## Current state

Built in FND-08 + FND-09, as one unit of work (extraction breaks assertions, the test harness is the fix — splitting them would have meant migrating the tests twice).

- `localeProvider`: `Provider<Locale>`, device locale if it's `pt` or `en`, else `pt`. `currentUser?.locale` will take priority once AUTH-07 exists and writes `profiles.locale` — the seam is already in place, AUTH-07 only has to supply the value.
- `AppErrorView`'s message switch and `RatingDisplay`'s "unrated" label both read from `AppLocalizations` now, not a hardcoded literal.
- `test/support/pump_app.dart` (FND-09) wraps a widget under test in a localized `MaterialApp`; `l10nOf(tester)` resolves `AppLocalizations` from that tree, so assertions read `find.text(l10n.searchHint)` and pass in either locale — see [[architecture/overview]].

## Dependencies

- **Blocked by** FND-02 (restructure), so ARB keys are organised against the final folder layout — done
- **Blocks** every new screen — see [[sprints/execution-map]]
- The Settings selector additionally needs AUTH-07 (`profiles` write path) — not built yet

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Specified; per-user locale confirmed as a hard requirement by the two real users |
| 2026-10-21 | FND-08 + FND-09 shipped: ARB files, `localeProvider`, every string extracted, `pump_app.dart` test harness. TMDb-language question decided in ADR-0015 |
