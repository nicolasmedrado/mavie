---
title: Test infrastructure
sprint: foundations
feature: —
milestone: mvp
status: done
started_at: 2026-10-21
finished_at: 2026-10-21
---

# FND-09 · Test infrastructure

## Goal

Shared test helpers so each new feature's tests compose fakes instead of redeclaring them — and so widget tests survive localization.

> **Do this together with FND-08.**

## Scope

Files: `test/support/`

```
test/support/
  pump_app.dart          pumpApp(tester, child, {overrides, locale}) + l10nOf(tester)
  fakes/                 FakeMovieRepository, FakeHttpAdapter, later FakeAuthRepository …
  fixtures/              real TMDb JSON captures: search_movie.json, movie_details.json,
                         movie_videos.json, movie_recommendations.json
```

### `pumpApp`

Wraps the widget under test in `ProviderScope(overrides: ...)` plus `MaterialApp` with `localizationsDelegates` and a chosen locale. `l10nOf(tester)` resolves `AppLocalizations` from the pumped tree so assertions read:

```dart
expect(find.text(l10n.searchHint), findsOneWidget);   // not 'Buscar filmes...'
```

That is what makes the three currently-breaking assertions pass again, and what stops every future widget test from hardcoding a language.

### Fakes stay hand-written

No `mocktail`, no `mockito` — [[architecture/decisions/0014-hand-rolled-fakes]]. The existing `_FakeMovieRepository` (with its `searchCallCount` spy) and `_FakeAdapter` move to `test/support/fakes/` and lose their underscore so other files can use them. A fake that drifts from its interface stays a **compile error**, which is the whole point with five repositories about to exist.

### Fixtures

Real captured TMDb responses, not hand-written JSON. Hand-written fixtures encode what you *think* the API returns; captures encode what it does — including the nulls and the empty arrays.

## Checklist

- [x] `pump_app.dart` with `pumpApp` and `l10nOf`
- [x] Move and generalize `FakeMovieRepository` and `FakeHttpAdapter`
- [x] Capture four real TMDb responses into `fixtures/` (plus the minimal no-runtime/genres one FND-04 already added)
- [x] Migrate the 3 assertions in `movie_search_page_test.dart` and `widget_test.dart` off Portuguese literals
- [x] All existing test files pass through the new harness (more than four exist now — FND-04/05/06/07 landed in between this issue being written and done)
- [x] Note in [[architecture/overview]] that `test/support/` is the entry point for new tests

## Test scenario

1. `flutter test`
   - **Expected:** all green, no literal-string assertions left
   - **Result:** 43 tests green, `flutter analyze --fatal-infos` clean
2. `pumpApp(..., locale: Locale('en'))` then `Locale('pt')`
   - **Expected:** the same test passes in both, because it asserts on keys
   - **Result:** `movie_search_page_test.dart`'s "renders in English and in Portuguese, from the same keys" test
3. Add a method to `MovieRepository` without updating the fake
   - **Expected:** compile error
   - **Result:** structural property of `implements MovieRepository` — not exercised as a one-off test, it's what every other test in the suite already depends on compiling

## Dependencies

- **Blocked by:** FND-02
- **Paired with:** FND-08
- **Blocks:** AUTH-08, LIB-08, LST-08, HOME-06

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | issue created |
| 2026-10-21 | `test/support/{pump_app.dart,fakes/,fixtures/}` added; every existing test file migrated. No manual step in this issue — closed |
