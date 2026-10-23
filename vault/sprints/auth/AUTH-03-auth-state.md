---
title: authStateProvider and currentUserProvider
sprint: auth
feature: auth
milestone: mvp
status: done
started_at: 2026-10-23
finished_at: 2026-10-23
---

# AUTH-03 · `authStateProvider` and `currentUserProvider`

## Goal

The rest of the app can read "who is signed in, right now" reactively, without touching the Supabase SDK directly.

## Scope

- Layers: `presentation`
- Files: `lib/features/auth/presentation/providers/auth_providers.dart`

## Checklist

- [x] `authStateProvider = StreamProvider<AuthState>((ref) => client.auth.onAuthStateChange)`
- [x] `currentUserProvider = Provider<AppUser?>` — derives from `authStateProvider`'s latest session, `null` while loading or signed out
- [x] `authRepositoryProvider` (the provider wiring for AUTH-02's repository, placed alongside since both live in the same file)
- [x] Unit tests covering all three states: signed in, signed out, still loading
- [x] `flutter analyze` clean

## Test scenario

No manual step — nothing reads `currentUserProvider` yet (AUTH-06 wires it into router gating). Covered by `test/features/auth/presentation/providers/auth_providers_test.dart`, overriding `authStateProvider` directly rather than touching `supabaseClientProvider` or any real Supabase instance:

1. Override with a `signedIn` event → `currentUserProvider` returns the matching `AppUser`
2. Override with a `signedOut` event → `currentUserProvider` returns `null`
3. Override with a stream that never emits → `currentUserProvider` returns `null` (the loading state)
   - **Result:** all three pass

## Dependencies

- **Blocked by:** AUTH-01, AUTH-02 (shares its `toAppUser` mapper)
- **Blocks:** AUTH-06 (router gating — `redirect` reads `currentUserProvider` via `ref.read`, never `ref.watch`, per [[architecture/decisions/0010-go-router-declarative-auth]])

## Notes

- **Found in passing, a real environment bug:** `StreamProvider<T>.future` does not resolve for an already-settled `Stream.value(...)` on `flutter_riverpod` 3.4.3 — `container.read(someStreamProvider.future)` hangs until the test runner's own timeout tears the container down mid-`loading`. Reproduced against a bare `StreamProvider<int>`, with and without `overrideWith`, with and without `.asBroadcastStream()` — nothing auth-specific about it. Logged in [[_meta/discrepancies]]. Worked around in the test file: `container.listen(provider, (_, __) {})` followed by two `await Future<void>.delayed(Duration.zero)` ticks reliably drives the same stream event through, and is what `_settle()` does in the test. Anyone writing a `StreamProvider` test after this one should reuse that pattern, not `.future`, until the Riverpod bug is confirmed fixed upstream.
- `currentUserProvider` treats "still loading" and "signed out" identically (`null`) — correct for now since no screen distinguishes them yet. AUTH-06 is what actually needs to tell them apart (pin to `/splash` while loading, redirect to `/sign-in` once truly signed out), and will read `authStateProvider`'s `AsyncValue` directly rather than through this provider for that distinction.

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-23 | issue created and closed together with AUTH-01/AUTH-02 (execution slot E10). Found and documented a `StreamProvider.future` bug in riverpod 3.4.3 while writing the test. No manual step |
