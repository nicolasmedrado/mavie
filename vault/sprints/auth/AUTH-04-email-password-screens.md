---
title: Sign in, sign up, forgot password
sprint: auth
feature: auth
milestone: mvp
status: done
started_at: 2026-10-23
finished_at: 2026-10-23
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

**No manual step was skippable here** — real screens, real Supabase Auth calls against the hosted project.

1. Empty-field, malformed-email, short-password and mismatched-confirm-password validation on all three forms
2. Sign up with a real email against the hosted project
3. Sign in, wrong password, forgot password
4. Sign out, sign back in, session persists across an app restart
   - **Result:** confirmed on a physical Android device. Found a real gap in passing — see Notes (Supabase confirmation redirect)

## Dependencies

- **Blocked by:** AUTH-02 (the repository these screens call)
- **Blocks:** AUTH-06 (needs real screens to route to instead of placeholders)

## Notes

- **Sign-up does not imply signed-in.** Supabase's hosted projects default to requiring email confirmation before a session is issued — `signUpWithEmail` can return `Ok(AppUser)` with no active session yet. `SignUpPage` shows `authSignUpConfirmationMessage` in that case rather than assuming success means "now in the app." If the router's redirect *does* see a session appear (confirmation disabled), it navigates away on its own — the screen's message would just flash past.
- **No deep-link handling yet** (AUTH-05's job). The confirmation link opens in a browser; nothing hands that session back to the mobile app. After confirming, come back to the app and sign in normally with email/password — the browser confirmation does not auto-sign-in the app.
- **Found during manual testing: the confirmation link's final redirect errors on a phone.** The hosted project's Auth "Site URL" (Authentication → URL Configuration in the Supabase dashboard) is still the default `http://localhost:3000`, so after Supabase verifies the token server-side it redirects the browser to a destination that doesn't resolve on a phone, and the browser shows a connection error. The confirmation itself still succeeds — GoTrue flips `email_confirmed_at` and issues the session *before* sending that final redirect, confirmed by testing: the account was signed-in-able right after, despite the browser error. Not fixed now — it's the same redirect-URL problem AUTH-05 already owns (deep-link scheme + the Supabase redirect allowlist); changing the Site URL today wouldn't have anywhere real to land anyway. Logged in [[_meta/discrepancies]].
- Found while building this, not introduced by it: `failure_mapper.dart`'s `_mapAuthException` only mapped `401` → `UnauthorizedFailure`, falling through to the generic `UnknownFailure` for everything else — including GoTrue's `400` for invalid email/password, which is the single most common real auth error a user will hit. Added `400` → `ValidationFailure` (closer in meaning than "something went wrong"), covered by a new case in `failure_mapper_test.dart`. Logged in [[_meta/discrepancies]].

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-23 | issue created and implemented together with AUTH-06/AUTH-08 (execution slot E11). `flutter analyze`/`flutter test` clean. Manual test pending — stays `in_progress` |
| 2026-10-23 | Manual test confirmed on a physical device: validation, sign-up, sign-in, wrong password, forgot password, sign-out, session persistence all work. Found the hosted project's Auth Site URL still defaults to `localhost:3000` (confirmation link redirect errors on a phone, confirmation itself still succeeds server-side) — logged, deferred to AUTH-05. Issue closed |
