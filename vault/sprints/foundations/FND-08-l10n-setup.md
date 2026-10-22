---
title: l10n setup and string extraction
sprint: foundations
feature: localization
milestone: mvp
status: done
started_at: 2026-10-21
finished_at: 2026-10-21
---

# FND-08 · l10n setup and string extraction

## Goal

Every user-visible string comes from an ARB file, in Portuguese and English. No hardcoded literals in widgets.

> **Do this together with FND-09.** Extraction breaks three existing test assertions, and FND-09's harness is the fix. Splitting them means migrating the tests twice.

## Scope

Files: `l10n.yaml`, `lib/l10n/arb/{app_en.arb, app_pt.arb}`, every widget with a string.

### Strings to extract

| Current literal | Where |
|---|---|
| `'Buscar filmes...'` | search app bar hint |
| `'Digite algo para buscar'` | search empty state |
| `'Detalhes do filme'` | details app bar |
| `'Erro: $error'` | both pages — becomes `AppErrorView` messages keyed by `AppFailure` variant |

Plus the system list names, *Want to watch* and *Watched*, keyed off the `movie_status` enum — **never stored in the database**, so each user sees them in their own language ([[architecture/decisions/0011-l10n-per-user-locale]]).

### Locale resolution

Device locale is only the initial default. The active locale is the **user's** preference, read from `profiles.locale`:

```
localeProvider: Provider<Locale>
  currentUser?.locale  →  device locale  →  'pt-BR'
```

The Settings selector that writes `profiles.locale` is AUTH-07. Until accounts exist, this issue ships with device-locale resolution and the provider seam already in place, so AUTH-07 only has to supply the value.

> ⚠️ Verify: TMDb accepts a `language` parameter the client never sends, so synopses always arrive in TMDb's default. Whether film metadata should follow the user's locale is open — it would need a per-locale `movies_cache`, which the current one-row-per-film schema cannot hold. **Decide here and record it**, in [[features/localization/_overview]] or as an ADR.
>
> **Decided:** not localized. See [[architecture/decisions/0015-tmdb-metadata-not-localized]] and [[product/post-mvp]].

## Checklist

- [x] `l10n.yaml`, `generate: true` (done in FND-01)
- [x] `app_en.arb` and `app_pt.arb` with descriptions on every key
- [x] `localizationsDelegates` and `supportedLocales` in `app.dart`
- [x] `localeProvider` seam, resolving device → fallback for now
- [x] Every literal extracted
- [x] `AppFailure` variants mapped to keys
- [x] System list names keyed off the enum
- [x] Decide and record the TMDb `language` question
- [x] Three test assertions migrated (FND-09)

## Test scenario

1. Run with the device in Portuguese, then in English
   - **Expected:** full UI in each, no leftover literals
   - **Result:** confirmed on a physical Android device, in both Portuguese and English — search, details, and the error/retry screen all fully in the right language
2. `grep -rnE "Text\('[A-Za-zÀ-ú]" lib/`
   - **Expected:** no hits
   - **Result:** clean, no hits
3. Trigger a network error in each locale
   - **Expected:** a translated message, not `Erro: DioException...`
   - **Result:** `movie_search_page_test.dart`'s error test asserts via `l10nOf(tester).errorNetwork` (locale-agnostic by construction); the English/Portuguese switch itself is covered by the "renders in English and in Portuguese" test. The live on-device trigger (airplane mode) is part of item 1's manual check

## Dependencies

- **Blocked by:** FND-02, FND-05 (failure keys), FND-07 (`AppErrorView`)
- **Blocks:** **every new screen.** Doing it later means retrofitting strings across twenty files
- **Paired with:** FND-09

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | issue created |
| 2026-10-21 | ARB files, `localeProvider`, every string extracted (including `AppErrorView`/`RatingDisplay`, added since this issue was written). TMDb-language question decided (ADR-0015). `flutter analyze --fatal-infos` clean, 43 tests green. Pending your manual device-language check |
| 2026-10-21 | Manual device-language check confirmed on a physical device, PT and EN both fully localized. Issue closed |
