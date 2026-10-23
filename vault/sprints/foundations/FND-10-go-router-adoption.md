---
title: go_router adoption
sprint: foundations
feature: —
milestone: mvp
status: done
started_at: 2026-10-21
finished_at: 2026-10-21
---

# FND-10 · go_router adoption

## Goal

Declarative routing with a four-tab shell, ready for auth gating. `go_router` has been a declared dependency since the scaffold and has never been imported.

## Scope

Files: `lib/core/router/{app_router.dart, app_routes.dart, go_router_refresh.dart}`, `lib/app/app.dart`

### Route table

```
/splash
/sign-in   /sign-up   /forgot-password
StatefulShellRoute.indexedStack
  /home   /search   /library   /lists
/movie/:id                        pushed above the shell
/lists/new   /lists/:listId   /lists/:listId/members
/profile   /settings
```

`MaterialApp` becomes `MaterialApp.router`. The two existing `Navigator.push` call sites become `context.push`. Path and name constants live in `app_routes.dart` with typed helpers — no string literals at call sites.

Screens that do not exist yet get placeholder routes, so the shell is navigable from day one and AUTH-06 only has to add the `redirect`.

### Two things that will bite

**Never `ref.watch` the auth state inside `routerProvider`.** It rebuilds the whole `GoRouter` on every auth event and wipes the navigation stack. Use `refreshListenable: GoRouterRefreshStream(...)` — a `ChangeNotifier` subscribed to the auth stream — and `ref.read` inside `redirect`. [[architecture/decisions/0010-go-router-declarative-auth]].

**`StatefulShellRoute.indexedStack`, not a `TabBarView`.** Each tab keeps its own navigation stack and scroll position; a `TabBarView` rebuilds and loses both.

## Checklist

- [x] `app_routes.dart` with path/name constants and typed helpers
- [x] `app_router.dart` with the full table and placeholder screens
- [x] `StatefulShellRoute.indexedStack` + a bottom navigation bar on FND-06 tokens
- [x] `go_router_refresh.dart` — the `Stream` → `ChangeNotifier` bridge, written now, wired in AUTH-06
- [x] `MaterialApp.router` in `app.dart`
- [x] Both `Navigator.push` call sites migrated — **only one existed** (`movie_search_page.dart`); the issue's own count was off, nothing else to migrate
- [x] Tab titles localized (FND-08) — `navHome`/`navSearch`/`navLibrary`/`navLists`
- [x] Update the navigation assertion in `movie_search_page_test.dart` — it currently asserts a `MovieDetailsPage` arrives via `Navigator`
- [x] Tick the `go_router` row in [[_meta/discrepancies]]

## Test scenario

1. Search → open a film → back
   - **Expected:** returns to the search tab with the query and scroll position intact
   - **Structural guarantee, not separately automated:** `/movie/:id` is a root-level route (pushed above the `StatefulShellRoute`, per the table), so popping it never touches the shell's branch stacks. Manual check recommended
2. Switch tabs and come back
   - **Expected:** each tab kept its own stack
   - **Result:** `app_shell_test.dart` confirms branches render independently and switch correctly — `StatefulShellRoute.indexedStack`'s own guarantee, not custom logic. Scroll-position preservation specifically isn't separately tested; manual check recommended once a tab has real scrollable content
3. Deep link `mavie://movie/438631` (or the configured scheme)
   - **Not done.** Deferred to AUTH-05: the scheme should be decided by the actual Google sign-in redirect URI, not guessed now and redone later. Logged in [[_meta/discrepancies]]
4. Android hardware back from a pushed details screen
   - **Expected:** pops one level, does not exit the app
   - **Result:** confirmed on a physical Android device — back from details returns to search with the query intact; switching tabs and back to search also preserved the typed query

## Dependencies

- **Blocked by:** FND-06 (shell chrome), FND-08 (localized titles)
- **Blocks:** **AUTH-06**, and every screen that needs a route

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | issue created |
| 2026-10-21 | `core/router/{app_routes,app_router,app_shell,go_router_refresh}.dart` added, `MaterialApp.router` wired, both real pages (search, details) and 9 placeholder routes in the table. `flutter analyze --fatal-infos` clean, 44 tests green. Deep-link scheme deliberately deferred to AUTH-05. Pending your manual back/hardware-back check |
| 2026-10-21 | Manual check confirmed on a physical device — back navigation and tab-switch state preservation both correct. Issue closed |
| 2026-10-23 | `go_router_refresh.dart`'s `GoRouterRefreshStream`, written here for AUTH-06 to wire up, was superseded instead of used: AUTH-06 bridges the refresh signal with `ref.listen(authStateProvider, ...)` + a small internal `ChangeNotifier`, avoiding a second subscription to the same auth stream. The file was removed as dead code. See [[sprints/auth/AUTH-06-router-gating]] and [[_meta/discrepancies]] |
