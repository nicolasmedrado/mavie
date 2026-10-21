---
title: Result and AppFailure
sprint: foundations
feature: —
milestone: mvp
status: backlog
started_at:
finished_at:
---

# FND-05 · `Result` and `AppFailure`

## Goal

Errors have types and translatable messages. No UI code ever sees a `DioException` or a `PostgrestException`, and no screen renders `Text('Erro: $error')`.

## Scope

Files: `lib/core/error/{app_failure.dart, result.dart, failure_mapper.dart}`

Two paths, deliberately different — [[architecture/decisions/0009-result-for-commands]]:

- **Reads** throw `AppFailure`, surfacing as `AsyncValue.error`.
- **Writes** return `Result<T>`.

```dart
sealed class AppFailure implements Exception {}
class NetworkFailure      extends AppFailure {}  // timeout, no connection
class UnauthorizedFailure extends AppFailure {}  // 401, expired session
class ForbiddenFailure    extends AppFailure {}  // 403, RLS denial (errcode 42501)
class NotFoundFailure     extends AppFailure {}  // 404
class ValidationFailure   extends AppFailure {}  // 400, DB check constraint
class UnknownFailure      extends AppFailure {}  // keeps the original + stack trace

sealed class Result<T> {}
class Ok<T>  extends Result<T> { final T value; }
class Err<T> extends Result<T> { final AppFailure failure; }
```

`failure_mapper.dart` translates `DioException`, `PostgrestException` and `AuthException` into those variants. Specific mappings that matter:

| Source | Maps to |
|---|---|
| `DioExceptionType.connectionTimeout` / `connectionError` | `NetworkFailure` |
| Postgres `42501` (the `raise` in `get_list_items`) | `ForbiddenFailure` |
| Postgres `23514` (check constraint — e.g. an invalid rating) | `ValidationFailure` |
| Postgres `23503` (foreign key — a missing `movies_cache` row) | `ValidationFailure`, and it means a write bypassed an RPC |

Each variant carries an l10n key, so messages are translatable by construction ([[architecture/decisions/0011-l10n-per-user-locale]]). `UnknownFailure` keeps the original error and stack trace — never swallow them.

`AppErrorView` is built in FND-07 and consumes this.

## Checklist

- [ ] Sealed `AppFailure` hierarchy with l10n keys
- [ ] Sealed `Result<T>`
- [ ] `failure_mapper.dart` for the three exception families
- [ ] `MovieRepositoryImpl` catches and rethrows mapped failures
- [ ] Unit tests: each source exception maps to the expected variant
- [ ] An exhaustive `switch` over `AppFailure` compiles without a default clause — that is the property worth protecting

## Test scenario

1. Point the Dio base URL at an unreachable host, open search
   - **Expected:** `NetworkFailure`, not a raw `DioException`
2. Disable the network mid-request
   - **Expected:** `NetworkFailure`, and the retry action works once connectivity returns
3. Add a new `AppFailure` variant
   - **Expected:** the build breaks at every unhandled `switch`

## Dependencies

- **Blocked by:** FND-02
- **Blocks:** FND-07 (`AppErrorView`), every repository from AUTH-02 onward
- Parallel with FND-04

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | issue created |
