---
title: Test infrastructure
sprint: foundations
feature: —
milestone: mvp
status: backlog
started_at:
finished_at:
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

- [ ] `pump_app.dart` with `pumpApp` and `l10nOf`
- [ ] Move and generalize `FakeMovieRepository` and `FakeHttpAdapter`
- [ ] Capture four real TMDb responses into `fixtures/`
- [ ] Migrate the 3 assertions in `movie_search_page_test.dart` and `widget_test.dart` off Portuguese literals
- [ ] All four existing test files pass through the new harness
- [ ] Note in [[architecture/overview]] that `test/support/` is the entry point for new tests

## Test scenario

1. `flutter test`
   - **Expected:** all green, no literal-string assertions left
2. `pumpApp(..., locale: Locale('en'))` then `Locale('pt')`
   - **Expected:** the same test passes in both, because it asserts on keys
3. Add a method to `MovieRepository` without updating the fake
   - **Expected:** compile error

## Dependencies

- **Blocked by:** FND-02
- **Paired with:** FND-08
- **Blocks:** AUTH-08, LIB-08, LST-08, HOME-06

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | issue created |
