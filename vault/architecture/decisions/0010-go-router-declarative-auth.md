---
title: go_router with a declarative auth redirect
status: accepted
date: 2026-10-21
---

# 0010 — go_router with a declarative auth redirect

## Context

`go_router` has been in `pubspec.yaml` since the scaffold and was never used — navigation is imperative `Navigator.push(MaterialPageRoute(...))`. The MVP adds authentication (screens must be unreachable without a session) and a four-tab shell that keeps state per tab.

## Decision

Adopt `go_router` for real in FND-10, **before** any auth work. Gate routes with a declarative `redirect`, and drive the four tabs with `StatefulShellRoute.indexedStack`.

## Alternatives considered

- **Stay imperative.** Auth gating would mean a session check scattered across every page, and `indexedStack` tabs with preserved per-tab state have no clean imperative equivalent.
- **Remove `go_router`, use Navigator 2.0 directly.** More control, far more code, no benefit here.
- **Adopt it after auth.** Rejected: retrofitting declarative gating onto screens that already push each other means doing the auth work twice.

## Consequences

- Auth gating is one `redirect` function instead of N guards.
- **Never `ref.watch` the auth state inside `routerProvider`.** That rebuilds the whole `GoRouter` on every auth event and wipes the navigation stack. Use `refreshListenable` with a `ChangeNotifier` bridged from the auth stream, and `ref.read` inside `redirect`.
- While the session is restoring from secure storage, `redirect` pins to `/splash`. Without that gate the sign-in screen flashes on every cold start.
- Deep links become possible, which Google sign-in needs anyway.
- One migration touching every existing navigation call — two call sites today, which is exactly why it is cheap now.
- FND-10 depends on FND-06 (shell chrome) and FND-07/FND-08 (localized tab titles), and **blocks AUTH-06**.
