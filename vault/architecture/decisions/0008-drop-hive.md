---
title: Drop Hive; no offline persistence in the MVP
status: accepted
date: 2026-10-21
---

# 0008 — Drop Hive; no offline persistence in the MVP

## Context

`hive` and `hive_flutter` have been in `pubspec.yaml` since the project scaffold, from a time when local-only storage was the plan for the watchlist. A grep over `lib/` returns zero matches: they were never imported or initialised.

Since then the backend decision landed on [[architecture/decisions/0003-supabase-over-firebase|Supabase]], which is now the source of truth.

## Decision

Remove `hive` and `hive_flutter` from `pubspec.yaml` (FND-01). No local persistence in the MVP.

## Alternatives considered

- **Keep Hive as an offline cache.** Hive 2.x is effectively unmaintained — the community moved to `hive_ce`. Building on it now would be choosing a dead dependency.
- **Adopt `drift` immediately.** The right tool if offline ever matters, since it mirrors the relational model. But offline is explicitly out of MVP scope and the requirements do not exist yet.

## Consequences

- One fewer dependency, and one fewer thing in the repository implying a capability the app does not have. An unused storage dependency in a portfolio repo reads as cargo-culting.
- The app requires connectivity. Acceptable — it is useless offline anyway, with no cached posters and no search.
- If offline reads become desirable post-MVP, the choice is `drift`, made against real requirements.
- `path_provider` disappears as a transitive dependency.
- Logged in [[_meta/discrepancies]], since the README and the old `context.md` both claimed Hive was in use.
