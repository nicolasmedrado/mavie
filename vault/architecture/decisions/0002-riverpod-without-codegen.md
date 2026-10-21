---
title: Riverpod with manual providers, no code generation
status: accepted
date: 2026-10-21
---

# 0002 — Riverpod with manual providers, no code generation

## Context

Riverpod 3 can be used two ways: declaring providers by hand, or annotating functions and classes with `@riverpod` and generating them via `riverpod_generator` + `build_runner`. The generator is what the official docs lead with.

## Decision

Hand-written providers. No `riverpod_generator`, no `build_runner`, no `.g.dart` files. Use the modern `Notifier` / `AsyncNotifier` API, never the legacy `StateNotifier`.

## Alternatives considered

- **`riverpod_generator`.** Less boilerplate, generated `family` arguments are type-safe, and it is where the ecosystem is heading. Costs a build step, generated files in the diff, and a layer of indirection between what you write and what runs.
- **A different state management library.** Not reopened — Riverpod is already the project's learning goal.

## Consequences

- Every provider is readable as written; there is nothing to regenerate and no stale-generated-file class of bug.
- `flutter test` runs with no pre-step. CI stays a three-line job.
- More boilerplate per provider, and `family` providers are less ergonomic.
- Revisit once the provider count makes the boilerplate actually annoying — this is a deliberately reversible decision, and migrating to codegen later is mechanical.
