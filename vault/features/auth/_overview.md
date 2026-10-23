---
title: Authentication
status: in_progress
stack: flutter + supabase
last_review: 2026-10-23
---

# Authentication

Accounts exist so that lists can be shared and ratings can be attributed. Nothing in the app is public.

> **Email/password sign-in works end to end, confirmed on a physical device (AUTH-01 … AUTH-04, AUTH-06, AUTH-08).** Google sign-in (AUTH-05) and profile setup/edit (AUTH-07) remain.

## Scope

- Sign up and sign in with **email + password**
- **Google sign-in**
- Forgot password
- Profile: username, display name, avatar, **language**
- Session persistence across restarts, and route gating while it restores

Username is the invite handle — `citext`, unique, `^[a-z0-9_]{3,24}$`. A provisional one is generated from the email local part by the `handle_new_user` trigger, and the user can change it in profile setup.

## Design

Supabase Auth, with a `profiles` row mirroring `auth.users` — `auth.users` is not client-readable, so without `profiles` a shared list cannot render a member's name or avatar. Table and policies: [[architecture/data-model]], [[architecture/security-model]].

Providers, `core/network/supabase_client.dart` + `features/auth/presentation/providers/auth_providers.dart` (AUTH-01/02/03, done):

```
supabaseClientProvider   SupabaseClient            Supabase.instance.client, initialized in bootstrap()
authRepositoryProvider   AuthRepository            AuthRepositoryImpl — signUpWithEmail/signInWithEmail/sendPasswordResetEmail/signOut, all Result<T>
authStateProvider        StreamProvider<AuthState> supabase.auth.onAuthStateChange
currentUserProvider      Provider<AppUser?>        derived from authStateProvider; null while loading or signed out
```

`appRouterProvider` (FND-10) is gated since AUTH-06. Route gating is a declarative `redirect`. **Do not `ref.watch` the auth state inside `appRouterProvider`** — see [[architecture/decisions/0010-go-router-declarative-auth]]. While `authStateProvider` is still loading, pin to `/splash`; otherwise no session and not on an auth route → `/sign-in`, session and on an auth route or splash → `/search` (`/home` is still a placeholder, HOME-01). Full detail, including a real bug found and fixed in this exact logic, in [[architecture/overview]]'s Navigation section.

`sign_in_page.dart` / `sign_up_page.dart` / `forgot_password_page.dart` (AUTH-04) never navigate themselves on success — the redirect above reacts to the auth state change instead. `settings_page.dart` (AUTH-06) is a one-button stand-in for sign-out until AUTH-07 builds the real profile/settings screen.

Repository methods return `Result<T>`, because sign-in needs a field-level error under the input rather than a page-level error state — [[architecture/decisions/0009-result-for-commands]].

> **The sign-up confirmation email's link currently errors on a phone.** The hosted project's Auth Site URL is still the default `http://localhost:3000` — Supabase confirms the email and issues a session server-side *before* redirecting the browser there, so the account is confirmed despite the error page. Fixing the destination for real needs AUTH-05's deep-link scheme; see [[_meta/discrepancies]].

## Risk

**Google sign-in platform configuration is the most time-consuming non-code task in the MVP** and has nothing to do with Dart: debug *and* release SHA-1 fingerprints, `google-services.json`, the iOS reversed client ID, a deep-link scheme, and the Supabase redirect allowlist. It is scheduled late (AUTH-05, execution slot E15) deliberately, so it cannot block the core product loop. Email+password is the critical path.

## Dependencies

- **Blocked by** BE-02 (`profiles` table and trigger) and FND-10 (go_router, for AUTH-06)
- **Blocks** everything in [[features/library/_overview]] and [[features/lists/_overview]]

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Specified as part of the MVP |
| 2026-10-23 | AUTH-01/02/03 done: Supabase client, `AppUser`/`AuthRepository`/`AuthRepositoryImpl`, `authStateProvider`/`currentUserProvider`. No screen built yet, no manual step |
| 2026-10-23 | AUTH-04/06/08 implemented: real sign-in/sign-up/forgot-password screens, router auth gating, splash, a minimal sign-out page, fakes and tests. `in_progress` pending manual confirmation of the sign-in → search → sign-out round trip on a real device |
| 2026-10-23 | Manual confirmation landed on a physical device. Found the Supabase Site URL defaulting to `localhost:3000` (confirmation link errors on a phone, confirmation still succeeds). **Email+password sign-in done end to end** |
