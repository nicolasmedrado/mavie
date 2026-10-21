---
title: Lint rules
sprint: foundations
feature: —
milestone: mvp
status: backlog
started_at:
finished_at:
---

# FND-11 · Lint rules

## Goal

The analyzer catches the mistakes this codebase is actually prone to, not just the `flutter_lints` defaults.

## Scope

Files: `analysis_options.yaml`

Today it is the stock scaffold: `include: package:flutter_lints/flutter.yaml`, platform folders excluded, and an empty `rules:` block.

### Analyzer

```yaml
analyzer:
  language:
    strict-casts: true
    strict-raw-types: true
  errors:
    missing_required_param: error
    missing_return: error
```

`strict-casts` is the one that earns its keep here: it catches the implicit `dynamic` → `double` cast that [[architecture/data-model]] flags as the most likely runtime crash in the MVP, when PostgREST hands back `numeric(3,1)` as a `String`.

### Rules worth adding

| Rule | Why here |
|---|---|
| `prefer_single_quotes` | The codebase already uses single quotes; make it enforced rather than habitual |
| `always_declare_return_types` | |
| `prefer_const_constructors` / `prefer_const_declarations` | Widget rebuild cost, and FND-04 makes the entities `const`-able |
| `unawaited_futures` | Fire-and-forget writes are coming with optimistic updates in LIB-07 |
| `avoid_print` | |
| `use_build_context_synchronously` | Async gaps around `context` are about to be everywhere — sign-in, rating, uploads |
| `require_trailing_commas` | Keeps `dart format` diffs small, which matters for review |
| `sort_pub_dependencies` | |

Do **not** adopt `very_good_analysis` or `lints` wholesale. Fixing a hundred new warnings in one sitting teaches nothing and the usual outcome is a pile of `// ignore:` comments.

### Not now

A `custom_lint` rule enforcing the feature-first dependency boundary ([[architecture/decisions/0001-feature-first-modules]]) would be genuinely useful, but it needs `build_runner`. Revisit if the convention actually starts being violated.

## Checklist

- [ ] `strict-casts` and `strict-raw-types` on
- [ ] The rules above enabled
- [ ] `flutter analyze --fatal-infos` clean
- [ ] CI already runs `--fatal-infos` (FND-03)
- [ ] Any rule deliberately rejected gets a comment in the file saying why

## Test scenario

1. `flutter analyze --fatal-infos`
   - **Expected:** zero issues
2. Write `final double x = someJson['rating'];`
   - **Expected:** `strict-casts` rejects it

## Dependencies

- **Blocked by:** FND-03 (so CI enforces it from the start)
- **Blocks:** nothing — can land in any slot after E04

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | issue created |
