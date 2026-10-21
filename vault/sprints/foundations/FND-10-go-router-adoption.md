---
title: go_router adoption
sprint: foundations
feature: —
milestone: mvp
status: backlog
started_at:
finished_at:
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

- [ ] `app_routes.dart` with path/name constants and typed helpers
- [ ] `app_router.dart` with the full table and placeholder screens
- [ ] `StatefulShellRoute.indexedStack` + a bottom navigation bar on FND-06 tokens
- [ ] `go_router_refresh.dart` — the `Stream` → `ChangeNotifier` bridge, written now, wired in AUTH-06
- [ ] `MaterialApp.router` in `app.dart`
- [ ] Both `Navigator.push` call sites migrated
- [ ] Tab titles localized (FND-08)
- [ ] Update the navigation assertion in `movie_search_page_test.dart` — it currently asserts a `MovieDetailsPage` arrives via `Navigator`
- [ ] Tick the `go_router` row in [[_meta/discrepancies]]

## Test scenario

1. Search → open a film → back
   - **Expected:** returns to the search tab with the query and scroll position intact
2. Switch tabs and come back
   - **Expected:** each tab kept its own stack
3. Deep link `mavie://movie/438631` (or the configured scheme)
   - **Expected:** opens the details screen directly — Google sign-in needs this plumbing anyway
4. Android hardware back from a pushed details screen
   - **Expected:** pops one level, does not exit the app

## Dependencies

- **Blocked by:** FND-06 (shell chrome), FND-08 (localized titles)
- **Blocks:** **AUTH-06**, and every screen that needs a route

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | issue created |
