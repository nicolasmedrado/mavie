---
title: `Result` for commands, thrown `AppFailure` for queries
status: accepted
date: 2026-10-21
---

# 0009 — `Result` for commands, thrown `AppFailure` for queries

## Context

Today errors are not handled at all: exceptions propagate raw from Dio and render as `Text('Erro: $error')`. With Supabase added there will be three error families (`DioException`, `PostgrestException`, `AuthException`) and real UI requirements — a field error under an email input, a snackbar with rollback when a rating fails to save.

## Decision

Two paths, deliberately different.

**Reads (queries).** Data sources throw; repositories catch and rethrow a sealed `AppFailure extends Exception`; providers surface it as `AsyncValue.error`; one `AppErrorView` switches on the sealed type and renders a localized message with a retry.

**Writes (commands).** Repositories return `Result<T>` — `Ok<T>` | `Err`. Call sites `switch` on it exhaustively.

## Alternatives considered

- **`Result` everywhere.** Uniform, and the usual instinct. But `AsyncValue` already *is* a result type for reads, so you end up with `AsyncValue<Result<T>>` and two layers of unwrapping at every call site.
- **Exceptions everywhere.** Fine for reads, bad for writes: inline, field-level feedback and optimistic rollback fit badly with an exception travelling through `AsyncValue`, and nothing forces the caller to handle it.
- **`dartz` / `fpdart` `Either`.** A dependency and a vocabulary (`fold`, `left`, `right`) for something Dart 3 sealed classes express natively and more legibly.

## Consequences

- Reads get one error widget for the whole app instead of ad-hoc `Text('Erro: ...')`.
- Writes are compiler-checked: a new `AppFailure` variant makes every unhandled `switch` a build error.
- The split must be documented, or it reads as an inconsistency rather than a decision — which is what this ADR is for.
- One `failure_mapper.dart` translates the three exception families into `AppFailure`, so no UI code ever touches a `PostgrestException`.
- `AppFailure` variants are also the l10n keys, which keeps error messages translatable by construction.
