---
title: Sign in, sign up, forgot password
sprint: auth
feature: auth
milestone: mvp
status: in_progress
started_at: 2026-10-23
finished_at:
---

# AUTH-04 · Sign in, sign up, forgot password

## Goal

A person can actually create an account and sign in with email and password — the first real UI on top of AUTH-01/02/03's client/repository/state layer.

## Scope

- Layers: `presentation`, `core/error` (a shared mapper extracted for reuse)
- Files:
  - `lib/features/auth/presentation/pages/{sign_in_page,sign_up_page,forgot_password_page}.dart`
  - `lib/features/auth/presentation/widgets/auth_submit_button.dart`
  - `lib/features/auth/presentation/validators/auth_validators.dart`
  - `lib/core/error/app_failure_l10n.dart` (new), `lib/core/widgets/app_error_view.dart` (refactored onto it)
  - `lib/core/error/failure_mapper.dart` (one addition, see Notes)
  - `lib/l10n/arb/{app_en,app_pt}.arb` (every auth string)

## Checklist

- [x] `SignInPage`: email + password, "forgot password?" link, "sign up" link, inline validation, submits to `AuthRepository.signInWithEmail`
- [x] `SignUpPage`: email + password + confirm, inline validation including a mismatch check, submits to `signUpWithEmail`, shows a confirmation message instead of assuming the user is signed in (see Notes — email confirmation)
- [x] `ForgotPasswordPage`: email, submits to `sendPasswordResetEmail`, shows a confirmation message
- [x] None of the three screens navigate on success themselves — AUTH-06's router `redirect` reacts to the auth state change instead, per [[architecture/decisions/0010-go-router-declarative-auth]]
- [x] `appFailureMessage(l10n, failure)` extracted from `AppErrorView` into `core/error/app_failure_l10n.dart` so the inline `Result.Err` message on each form reuses the exact same exhaustive switch, not a second copy
- [x] `auth_validators.dart`: email format, password length (matches `supabase/config.toml`'s `minimum_password_length`), confirm-password match — all pure functions taking `AppLocalizations`
- [x] Google button **not** added — AUTH-05 owns it, deliberately deferred (platform configuration, Phase 4)
- [x] `flutter analyze` clean; unit + widget tests (AUTH-08) green

## Test scenario

**No manual step was skippable here** — real screens, real Supabase Auth calls against the hosted project. Roteiro handed to you in chat once AUTH-04/06/08 were implemented together; this issue stays `in_progress` until you confirm it.

## Dependencies

- **Blocked by:** AUTH-02 (the repository these screens call)
- **Blocks:** AUTH-06 (needs real screens to route to instead of placeholders)

## Notes

- **Sign-up does not imply signed-in.** Supabase's hosted projects default to requiring email confirmation before a session is issued — `signUpWithEmail` can return `Ok(AppUser)` with no active session yet. `SignUpPage` shows `authSignUpConfirmationMessage` in that case rather than assuming success means "now in the app." If the router's redirect *does* see a session appear (confirmation disabled), it navigates away on its own — the screen's message would just flash past.
- **No deep-link handling yet** (AUTH-05's job). The confirmation link opens in a browser; nothing hands that session back to the mobile app. After confirming, come back to the app and sign in normally with email/password — the browser confirmation does not auto-sign-in the app.
- Found while building this, not introduced by it: `failure_mapper.dart`'s `_mapAuthException` only mapped `401` → `UnauthorizedFailure`, falling through to the generic `UnknownFailure` for everything else — including GoTrue's `400` for invalid email/password, which is the single most common real auth error a user will hit. Added `400` → `ValidationFailure` (closer in meaning than "something went wrong"), covered by a new case in `failure_mapper_test.dart`. Logged in [[_meta/discrepancies]].

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-23 | issue created and implemented together with AUTH-06/AUTH-08 (execution slot E11). `flutter analyze`/`flutter test` clean. Manual test pending — stays `in_progress` |
