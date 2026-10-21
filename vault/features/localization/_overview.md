---
title: Localization
status: planned
stack: flutter + supabase
last_review: 2026-10-21
---

# Localization

Portuguese and English, with the language chosen **per user** rather than per device.

This is not a nice-to-have on this project: the two actual users want different languages. Nicolas runs the app in English, his girlfriend in Portuguese, on different phones, against the same shared data. [[architecture/decisions/0011-l10n-per-user-locale]].

> **Not built.** Issues FND-08 and FND-09, which are **one unit of work**.

## Scope

- `flutter_localizations` + `intl`, `generate: true`, `l10n.yaml`
- `app_en.arb` and `app_pt.arb`
- Every hardcoded string extracted
- A language selector in Settings, persisted to `profiles.locale`
- Device locale as the initial default for a new account

## Design

**What is translated and what is not:**

| Content | Where it lives |
|---|---|
| UI chrome, buttons, empty states, errors | ARB files |
| System list names (*Want to watch*, *Watched*) | ARB, keyed off the `movie_status` enum — **never stored in the database**, so each user sees their own language |
| `AppFailure` variants | ARB keys, so errors are translatable by construction |
| Custom list names and descriptions | `lists.name` / `lists.description`, verbatim — the user typed them, they are content, not chrome |
| Film titles and synopses | TMDb, in whatever language the request asked for |

> ⚠️ Verify: TMDb accepts a `language` parameter the client does not currently send, so synopses always come back in TMDb's default. Whether the film metadata should follow the user's locale is an open question — it would mean a per-locale `movies_cache`, which the current single-row-per-film schema cannot hold. Decide in FND-08.

## Current state

UI strings are hardcoded Portuguese: `'Buscar filmes...'`, `'Digite algo para buscar'`, `'Detalhes do filme'`, `'Erro: $error'`. **Three existing tests assert on those literals**, so extraction breaks them.

That is why FND-08 (extraction) and FND-09 (test harness) are one piece of work: `test/support/pump_app.dart` provides localizations to the widget tree so assertions become `find.text(l10n.searchHint)`. Splitting them means migrating the tests twice.

Doing this before any new UI is built avoids retrofitting strings across twenty files later — which is why it sits in the foundations sprint rather than near release.

## Dependencies

- **Blocked by** FND-02 (restructure), so ARB keys are organised against the final folder layout
- **Blocks** every new screen — see [[sprints/execution-map]]
- The Settings selector additionally needs AUTH-07 (`profiles` write path)

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Specified; per-user locale confirmed as a hard requirement by the two real users |
