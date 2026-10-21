---
title: l10n setup and string extraction
sprint: foundations
feature: localization
milestone: mvp
status: backlog
started_at:
finished_at:
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

## Checklist

- [ ] `l10n.yaml`, `generate: true` (done in FND-01)
- [ ] `app_en.arb` and `app_pt.arb` with descriptions on every key
- [ ] `localizationsDelegates` and `supportedLocales` in `app.dart`
- [ ] `localeProvider` seam, resolving device → fallback for now
- [ ] Every literal extracted
- [ ] `AppFailure` variants mapped to keys
- [ ] System list names keyed off the enum
- [ ] Decide and record the TMDb `language` question
- [ ] Three test assertions migrated (FND-09)

## Test scenario

1. Run with the device in Portuguese, then in English
   - **Expected:** full UI in each, no leftover literals
2. `grep -rnE "Text\('[A-Za-zÀ-ú]" lib/`
   - **Expected:** no hits
3. Trigger a network error in each locale
   - **Expected:** a translated message, not `Erro: DioException...`

## Dependencies

- **Blocked by:** FND-02, FND-05 (failure keys), FND-07 (`AppErrorView`)
- **Blocks:** **every new screen.** Doing it later means retrofitting strings across twenty files
- **Paired with:** FND-09

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | issue created |
