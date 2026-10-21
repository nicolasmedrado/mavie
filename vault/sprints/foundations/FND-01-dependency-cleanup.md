---
title: Dependency cleanup
sprint: foundations
feature: —
milestone: mvp
status: done
started_at: 2026-10-21
finished_at: 2026-10-21
---

# FND-01 · Dependency cleanup

## Goal

`pubspec.yaml` reflects what the app actually uses and what the MVP needs. No declared-but-unimported packages.

## Scope

- Files: `pubspec.yaml`, `pubspec.lock`
- Also fix `description:`, which is still `"A new Flutter project."`

### Remove

| Package | Why |
|---|---|
| `hive` ^2.2.3 | Never imported. Supabase is the source of truth, Hive 2.x is unmaintained — [[architecture/decisions/0008-drop-hive]] |
| `hive_flutter` ^1.1.0 | Same |

`go_router` ^18.0.1 **stays** — also never imported, but it gets adopted for real in FND-10.

### Add

| Package | For |
|---|---|
| `supabase_flutter` | Auth, Postgres, Storage |
| `flutter_localizations` (sdk) | FND-08 |
| `intl` | FND-08 |
| `cached_network_image` | Posters — `Image.network` today has no caching, no `errorBuilder`, no `loadingBuilder` |

Also set `flutter: generate: true` for the l10n codegen FND-08 needs.

> Pin versions at whatever `flutter pub add` resolves on the day. Record the resolved versions in the Notes section below, since [[architecture/overview]] does not list them.

## Checklist

- [x] Remove `hive` and `hive_flutter`
- [x] Add `supabase_flutter`, `flutter_localizations`, `intl`, `cached_network_image`
- [x] Add `generate: true` under `flutter:`
- [x] Fix `description:`
- [x] `flutter pub get`, commit the updated `pubspec.lock`
- [x] `flutter analyze` clean, `flutter test` green (4 files)
- [x] Tick the two Hive rows in [[_meta/discrepancies]] as resolved

## Test scenario

1. `flutter pub deps | grep hive`
   - **Expected:** no output — `path_provider` also disappears as a transitive dependency
2. `flutter analyze && flutter test`
   - **Expected:** no issues, all tests pass. Nothing in `lib/` imported Hive, so nothing should break

## Dependencies

- **Blocked by:** nothing
- **Blocks:** everything

## Notes

Resolved on 2026-10-21:

| Package | Version |
|---|---|
| `supabase_flutter` | `^2.18.3` |
| `intl` | `^0.20.3` |
| `cached_network_image` | `^4.0.5` |
| `flutter_localizations` | SDK (bundled with Flutter, no version pin) |

`generate: true` is set with no `l10n.yaml` / ARB files yet — `flutter pub get` and `flutter analyze` both pass clean against it; the codegen only runs once FND-08 adds the inputs.

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | issue created |
| 2026-10-21 | Hive removed, Supabase/l10n/image-cache deps added, `flutter analyze` and `flutter test` (8 tests, 4 files) verified clean |
