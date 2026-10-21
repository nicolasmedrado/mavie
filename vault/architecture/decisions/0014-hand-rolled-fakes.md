---
title: Hand-written fakes over a mocking package
status: accepted
date: 2026-10-21
---

# 0014 — Hand-written fakes over a mocking package

## Context

The existing tests use fakes written by hand: `_FakeMovieRepository implements MovieRepository` with a `searchCallCount` spy, injected through `ProviderScope(overrides:)`; and `_FakeAdapter implements HttpClientAdapter` swapped onto a bare `Dio` to assert request paths and query parameters. No `mockito`, no `mocktail`.

The MVP adds repositories for auth, library, lists and recommendations, so the pattern is about to be repeated five more times.

## Decision

Keep hand-written fakes. No mocking package.

## Alternatives considered

- **`mocktail`.** No codegen, nice `when`/`verify` ergonomics, and less code per fake. But stubbing is configured per test, so a method you forget to stub fails at runtime rather than at compile time.
- **`mockito` with codegen.** Adds `build_runner`, which [[architecture/decisions/0002-riverpod-without-codegen]] exists to avoid.

## Consequences

- A fake that drifts from its interface is a **compile error**, not a confusing runtime null. With five repositories about to exist, that matters more than the boilerplate it costs.
- Fakes read as plain Dart. Nothing to learn to read a test.
- More code per fake, and expressing "throws on the third call" takes a field rather than a one-liner.
- Shared fakes move to `test/support/fakes/` (FND-09) so features compose them instead of redeclaring them. Real TMDb JSON captures go in `test/support/fixtures/`.
- `pumpApp` in `test/support/` provides `ProviderScope` overrides and localizations in one call — needed anyway by [[architecture/decisions/0011-l10n-per-user-locale]].
- Reversible: adopting `mocktail` later does not invalidate existing fakes, the two coexist.
