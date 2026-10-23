---
title: Router gating, splash, sign-out
sprint: auth
feature: auth
milestone: mvp
status: in_progress
started_at: 2026-10-23
finished_at:
---

# AUTH-06 · Router gating, splash, sign-out

## Goal

Every route except the auth screens is unreachable without a session, the session-restoring window shows a splash instead of flashing the sign-in screen, and signing out actually takes you back there — the `redirect` + `refreshListenable` wiring [[architecture/decisions/0010-go-router-declarative-auth]] has been describing since FND-10.

## Scope

- Layers: `core/router`, `presentation`
- Files:
  - `lib/core/router/app_router.dart` — `redirect`, `refreshListenable`, real builders for `/splash`, `/sign-in`, `/sign-up`, `/forgot-password`, `/settings`
  - `lib/core/widgets/splash_page.dart` (new)
  - `lib/features/auth/presentation/pages/settings_page.dart` (new — sign-out stand-in, see Notes)
  - `lib/features/movies/presentation/pages/movie_search_page.dart` (temporary settings entry point, see Notes)
  - `lib/core/router/go_router_refresh.dart` **removed** — see Notes

## Checklist

- [x] `redirect`: still-restoring session → `/splash`; signed out and not already on an auth route → `/sign-in`; signed in and on an auth route or splash → `/search` (not `/home` — see Notes)
- [x] `refreshListenable` re-runs `redirect` reactively on every auth change, without rebuilding the whole router or `ref.watch`ing auth state inside `appRouterProvider` itself
- [x] `/splash`, `/sign-in`, `/sign-up`, `/forgot-password` now build real pages instead of `PlaceholderPage`
- [x] `/settings` builds a minimal real page: just a sign-out button (AUTH-07 replaces it with the full profile/settings screen)
- [x] A temporary gear icon on the search tab's app bar is the only way to reach `/settings` today — no nav tab or Home app bar exists yet
- [x] `flutter analyze` clean; `app_router_test.dart` covers restoring/signed-out/signed-in/reactive-sign-in/reactive-sign-out

## Test scenario

Handed to you in chat as a combined roteiro for AUTH-04/06/08 — stays `in_progress` until you confirm the sign-in → search → settings → sign-out → back-to-sign-in round trip on a real device.

## Dependencies

- **Blocked by:** AUTH-03 (`authStateProvider`/`currentUserProvider`), AUTH-04 (real screens to route to), FND-10 (go_router itself)
- **Blocks:** nothing further in the MVP backlog — AUTH-07 reuses `/settings`'s spot

## Notes

- **`go_router_refresh.dart` removed.** FND-10 wrote `GoRouterRefreshStream` (a `Stream` → `ChangeNotifier` bridge) anticipating this issue would wire it to `SupabaseClient.auth.onAuthStateChange` directly. Building the redirect tests (AUTH-08) surfaced a cleaner option: `ref.listen(authStateProvider, (_, __) => refreshNotifier.notify())` inside `appRouterProvider`'s own builder — one `ChangeNotifier`, no second subscription to the same auth stream, and `appRouterProvider`'s only auth dependency stays `authStateProvider`, which tests already override. `GoRouterRefreshStream` had no other caller, so it was deleted outright rather than left unused. Logged in [[_meta/discrepancies]]; see also [[sprints/foundations/FND-10-go-router-adoption]]'s Maintenance log.
- **A real, launch-blocking bug found and fixed while writing the redirect tests:** `_redirect` originally computed "is this user signed in" via `ref.read(currentUserProvider)`. `currentUserProvider` is a `Provider` that `ref.watch`es `authStateProvider` — and when `_redirect` runs *synchronously inside the same `ref.listen(authStateProvider, ...)` callback stack* that fired because `authStateProvider` just changed, `currentUserProvider` had not recomputed yet (Riverpod notifies direct listeners before it flushes watching dependents). Reading it at that exact point returned the *previous* auth event's value — one event stale. In practice this meant **a real sign-in never actually left the sign-in screen**, because the redirect reacting to the `signedIn` event still saw "signed out" from the stale read. Fixed by deriving `isSignedIn` directly from `authState.value?.session?.user != null` inside `_redirect`, bypassing the derived provider entirely for this one synchronous check. `currentUserProvider` itself is unaffected for normal reactive `ref.watch` consumption (e.g. a future widget watching it) — the staleness window only bites a same-stack `ref.read` of a *different* provider triggered by the *same* upstream event. Logged in [[_meta/discrepancies]].
- Landing route for signed-in users at `/splash`/an auth route is `/search`, not `/home` — `/home` is still `PlaceholderPage` (HOME-01). Revisit once Home is the real landing screen.
- Deep-link scheme registration remains deferred to AUTH-05, unchanged from FND-10's note.

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-23 | issue created and implemented together with AUTH-04/AUTH-08 (execution slot E11). Found and fixed a real sign-in-never-navigates bug (`currentUserProvider` staleness) while building the redirect tests. `flutter analyze`/`flutter test` clean. Manual test pending — stays `in_progress` |
