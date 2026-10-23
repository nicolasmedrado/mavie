---
title: Fake AuthRepository, redirect behaviour, form validation tests
sprint: auth
feature: auth
milestone: mvp
status: in_progress
started_at: 2026-10-23
finished_at:
---

# AUTH-08 · Fake `AuthRepository`, redirect behaviour, form validation tests

## Goal

AUTH-04's screens and AUTH-06's router gating are covered by automated tests that don't touch the real Supabase SDK — a hand-written fake repository and fixture `AuthState`s, same pattern as [[architecture/decisions/0014-hand-rolled-fakes]].

## Scope

- Layers: `test/support`, `test`
- Files:
  - `test/support/fakes/fake_auth_repository.dart`
  - `test/support/fakes/fake_auth_state.dart`
  - `test/core/router/app_router_test.dart`
  - `test/features/auth/presentation/pages/{sign_in_page_test,sign_up_page_test,forgot_password_page_test,settings_page_test}.dart`
  - `test/features/auth/presentation/validators/auth_validators_test.dart`
  - `test/core/error/app_failure_l10n_test.dart`
  - `test/core/error/failure_mapper_test.dart` (extended, one new case)
  - `test/widget_test.dart` (rewritten for the auth-gated app)

## Checklist

- [x] `FakeAuthRepository`: configurable `Result` per method, call-count spies, last-arguments capture — mirrors `FakeMovieRepository`
- [x] `fake_auth_state.dart`: `signedInAuthState()` / `signedOutAuthState` fixtures, reused by `widget_test.dart` and `app_router_test.dart`
- [x] Sign-in/sign-up/forgot-password widget tests: empty-field validation, malformed email, password length, confirm-password mismatch, successful submit calls the repository with the right arguments, a failed submit shows the mapped message
- [x] `app_router_test.dart`: still-restoring → splash; signed out → sign-in; signed in visiting an auth route → bounced to search; **reacts to a live sign-in event** and **a live sign-out event** without being told to navigate
- [x] `widget_test.dart` rewritten: a signed-out cold start lands on sign-in (the new real default), a signed-in cold start still reaches search
- [x] `flutter analyze` clean, 80 tests green

## Test scenario

Pure test infrastructure and automated coverage — no manual step of its own. It stays `in_progress` only because it was implemented and will be closed in the same PR as AUTH-04/AUTH-06, which do need your manual confirmation.

## Dependencies

- **Blocked by:** AUTH-04, AUTH-06 (there is nothing to test until the screens and gating exist)
- **Blocks:** nothing

## Notes

- **A real `flutter_riverpod` 3.4.3 gotcha, found while writing `app_router_test.dart`:** `container.read(appRouterProvider)` alone — without something actively watching or listening to it — leaves the provider's internal `ref.listen(authStateProvider, ...)` inert; the override's `Stream` value never arrives no matter how many frames are pumped. The fix was test-side: wrap the router in a `Consumer` that `ref.watch`es `appRouterProvider`, mirroring exactly how `app.dart`'s `MyApp` obtains it in the real app (`ref.watch(appRouterProvider)`), rather than a one-off `container.read`. This is the same family of issue as [[sprints/auth/AUTH-03-auth-state]]'s `StreamProvider.future` finding and AUTH-06's `currentUserProvider` staleness finding — Riverpod 3.4.3 providers that aren't actively watched/listened to don't reliably propagate async updates in tests. Logged in [[_meta/discrepancies]].
- `pumpAndSettle()` cannot be used anywhere a `SplashPage` might render — its `CircularProgressIndicator` animates forever, so the call times out. `app_router_test.dart` uses a bounded `_settle()` helper (five `pump()` ticks) instead, everywhere.
- A broadcast `StreamController<AuthState>` drops any event `add()`-ed before something is listening. `app_router_test.dart`'s multi-event tests always `add()` *after* `_pumpRouter` has subscribed, never before.

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-23 | issue created and implemented together with AUTH-04/AUTH-06 (execution slot E11). Found a second riverpod provider-liveness gotcha while building the router test. `flutter analyze`/`flutter test` clean, 80 tests. Stays `in_progress` pending AUTH-04/06's manual confirmation |
