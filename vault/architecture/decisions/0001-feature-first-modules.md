---
title: Feature-first module layout
status: accepted
date: 2026-10-21
---

# 0001 — Feature-first module layout

## Context

`lib/` is organised layer-first: `domain/`, `data/`, `presentation/`, each split by artifact type. With one feature and nine files that is perfectly readable. The MVP adds auth, library, lists, home and profile — roughly eighty files. Layer-first at that size means `data/models/` holds fifteen unrelated models and working on one screen means opening three top-level folders.

## Decision

Nest the three layers **inside each feature**: `features/<name>/{domain,data,presentation}`, with cross-cutting infrastructure in `core/`.

Dependency rule: `features/X` may import `core/**` and `features/Y/domain/**` — never another feature's `data/` or `presentation/`. `features/movies/domain` is the declared shared kernel, since every feature needs the film entities.

Do it now, at nine files (issue FND-02), not later.

## Alternatives considered

- **Keep layer-first.** Zero migration cost today, growing cost every week after.
- **Feature-first without inner layers.** Simpler, but drops the dependency rule that is the reason clean architecture is on this project's CV in the first place.
- **Melos / separate packages per feature.** Compiler-enforced boundaries, but heavy tooling for a one-person app.

## Consequences

- Each feature is a deletable unit, which is a real test of whether the boundaries hold.
- The dependency rule becomes per-feature and visible, rather than a global convention nobody rechecks.
- One migration commit touching every existing file. Done before anything else is built, so nothing lands twice.
- The rule is convention-enforced. If it starts being violated, `custom_lint` can enforce it later.
- `lib/data/providers/providers.dart` is dissolved — providers move next to the feature that owns them.

See [[architecture/overview]].
