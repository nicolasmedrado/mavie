---
title: AppUser and AuthRepository
sprint: auth
feature: auth
milestone: mvp
status: done
started_at: 2026-10-23
finished_at: 2026-10-23
---

# AUTH-02 · `AppUser` and `AuthRepository`

## Goal

A domain-level `AppUser` and `AuthRepository` exist, with a Supabase-backed implementation that performs the four commands (sign up, sign in, send password reset, sign out) and returns `Result<T>` — [[architecture/decisions/0009-result-for-commands]].

## Scope

- Layers: `domain`, `data`
- Files:
  - `lib/features/auth/domain/entities/app_user.dart`
  - `lib/features/auth/domain/repositories/auth_repository.dart`
  - `lib/features/auth/data/mappers/app_user_mapper.dart`
  - `lib/features/auth/data/repositories/auth_repository_impl.dart`

## Checklist

- [x] `AppUser` (`id`, `email`) — pure domain, no `supabase_flutter` import, value equality
- [x] `AuthRepository`: `signUpWithEmail`, `signInWithEmail`, `sendPasswordResetEmail`, `signOut`, all returning `Result<T>`
- [x] `AuthRepositoryImpl` wraps `SupabaseClient.auth`, catches and maps exceptions via the existing `failure_mapper.dart` (already handled `AuthException` since FND-05)
- [x] `toAppUser(User)` mapper lives in `data/`, not `domain/` — the architecture rule is "domain depends on nothing," and `User` is a `supabase_flutter` type
- [x] `flutter analyze` clean; unit tests for the mapper and for `AppUser` equality

## Test scenario

No manual step — no screen calls `AuthRepository` yet (AUTH-04). Covered by:

1. `test/features/auth/domain/entities/app_user_test.dart` — value equality
2. `test/features/auth/data/mappers/app_user_mapper_test.dart` — `toAppUser` carries `id`/`email`, including a null email
   - **Result:** both pass

## Dependencies

- **Blocked by:** AUTH-01
- **Blocks:** AUTH-04 (the screens that call these methods), AUTH-03's `currentUserProvider` (shares the mapper)

## Notes

- `AuthRepositoryImpl`'s try/catch wiring around the Supabase SDK calls is **not** unit-tested directly — unlike `MovieRepositoryImpl`, which gets this cheaply via `FakeHttpAdapter` on a bare `Dio`. `gotrue`'s `signUp`/`signInWithPassword` build a PKCE challenge and hit a specific REST wire format internally; faking that at the HTTP layer would mean reimplementing GoTrue's protocol for a five-line try/catch, which is exactly the kind of ceremony [[architecture/overview]] already rejects for a thin pass-through. The exception→`AppFailure` mapping itself is fully covered by `failure_mapper_test.dart`. The actual sign-up/sign-in flow against the real hosted project gets its first real exercise once AUTH-04 ships a screen to drive it by hand.
- No `getCurrentUser`/session accessor on `AuthRepository` — that is AUTH-03's job (`currentUserProvider`, derived from the auth state stream), kept separate so the repository stays commands-only.

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-23 | issue created and closed together with AUTH-01/AUTH-03 (execution slot E10). No manual step |
