---
title: Localization with a per-user locale
status: accepted
date: 2026-10-21
---

# 0011 — Localization with a per-user locale

## Context

UI strings are hardcoded Portuguese (`'Buscar filmes...'`, `'Digite algo para buscar'`, `'Erro: $error'`) while the project's own ground rule says all artifacts are in English. Three tests assert on those Portuguese literals.

More importantly, the two actual users want different languages: **Nicolas uses the app in English, his girlfriend in Portuguese** — on different phones, against the same shared data.

## Decision

`flutter_localizations` + ARB, with `app_en.arb` and `app_pt.arb`. The active locale is a **per-user preference**, stored in `profiles.locale`, with the device locale as the initial default and a selector in Settings.

## Alternatives considered

- **Switch everything to English, no l10n.** Simplest, and repository-consistent. Rejected because one of the two real users would be reading an app in a language she did not pick.
- **Device locale only.** Works for the common case and needs no column. Rejected: a user with an English phone who wants the app in Portuguese has no recourse, and that is a plausible configuration in this household.
- **Portuguese UI, English code, documented as an exception.** Zero work now, but leaves the inconsistency and leaves the English user without English.

## Consequences

- `profiles.locale` is part of the schema and the Settings screen, not a device setting.
- **System list names** (*Want to watch*, *Watched*) are ARB strings keyed off the `movie_status` enum, never stored in the database — so they appear in each user's own language. Custom list names live in `lists.name` and are not localizable, which is correct: the user typed them.
- `AppFailure` variants map to ARB keys, so errors are translated by construction.
- **Three existing tests break**, since they assert Portuguese literals. The fix is the `test/support/pumpApp` harness that provides localizations, so assertions read `find.text(l10n.searchHint)`. FND-08 and FND-09 are therefore **one unit of work** — splitting them means migrating the tests twice.
- Doing this before any new UI is built avoids retrofitting strings across twenty files later.
