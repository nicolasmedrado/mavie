---
title: Authentication
status: planned
stack: flutter + supabase
last_review: 2026-10-21
---

# Authentication

Accounts exist so that lists can be shared and ratings can be attributed. Nothing in the app is public.

> **Not built.** Sprint AUTH, issues AUTH-01 … AUTH-08.

## Scope

- Sign up and sign in with **email + password**
- **Google sign-in**
- Forgot password
- Profile: username, display name, avatar, **language**
- Session persistence across restarts, and route gating while it restores

Username is the invite handle — `citext`, unique, `^[a-z0-9_]{3,24}$`. A provisional one is generated from the email local part by the `handle_new_user` trigger, and the user can change it in profile setup.

## Design

Supabase Auth, with a `profiles` row mirroring `auth.users` — `auth.users` is not client-readable, so without `profiles` a shared list cannot render a member's name or avatar. Table and policies: [[architecture/data-model]], [[architecture/security-model]].

Providers:

```
supabaseClientProvider   SupabaseClient            (overridden in tests)
authStateProvider        StreamProvider<AuthState> (supabase.auth.onAuthStateChange)
currentUserProvider      Provider<AppUser?>        (derived)
routerProvider           Provider<GoRouter>
```

Route gating is a declarative `redirect`. **Do not `ref.watch` the auth state inside `routerProvider`** — see [[architecture/decisions/0010-go-router-declarative-auth]]. While `authStateProvider` is still loading, pin to `/splash`; otherwise no session and not on an auth route → `/sign-in`, session and on an auth route → `/home`.

Repository methods return `Result<T>`, because sign-in needs a field-level error under the input rather than a page-level error state — [[architecture/decisions/0009-result-for-commands]].

## Risk

**Google sign-in platform configuration is the most time-consuming non-code task in the MVP** and has nothing to do with Dart: debug *and* release SHA-1 fingerprints, `google-services.json`, the iOS reversed client ID, a deep-link scheme, and the Supabase redirect allowlist. It is scheduled late (AUTH-05, execution slot E15) deliberately, so it cannot block the core product loop. Email+password is the critical path.

## Dependencies

- **Blocked by** BE-02 (`profiles` table and trigger) and FND-10 (go_router, for AUTH-06)
- **Blocks** everything in [[features/library/_overview]] and [[features/lists/_overview]]

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Specified as part of the MVP |
