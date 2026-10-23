---
title: Discrepancies
status: active
last_review: 2026-10-21
---

# Discrepancies

Divergences between documentation and reality (code, libraries, external APIs), and bugs found in passing that were not fixed on the spot.

**Always append rows. Never overwrite.**

| Date | Where | Expected | Found | Action |
|---|---|---|---|---|
| 2026-10-21 | `pubspec.yaml` × `lib/` | `hive` / `hive_flutter` used for local storage, as `vault/context.md` and the README claimed | Declared as dependencies, **never imported anywhere in `lib/`** | Removing both — [[architecture/decisions/0008-drop-hive]], issue FND-01 |
| 2026-10-21 | `pubspec.yaml` × `lib/` | `go_router` used for navigation, as the README claimed | Declared, never imported. Navigation is imperative `Navigator.push(MaterialPageRoute(...))` in [movie_search_page.dart](../../lib/presentation/pages/movie_search_page.dart) | Adopting it for real in FND-10, before auth gating — [[architecture/decisions/0010-go-router-declarative-auth]] |
| 2026-10-21 | `vault/context.md` × `lib/` | "`lib/domain`, `lib/data`, `lib/presentation` exist but are still empty; `main.dart` is still the default counter template" | Three layers fully implemented, search and details shipped, 4 test files passing | `context.md` deleted; content redistributed across this vault |
| 2026-10-21 | `vault/context.md` × reality | "Code is not written by the assistant on this project" | No longer true — Claude writes mavie's implementation code | Ground rules restated in [CLAUDE.md](../../CLAUDE.md) |
| 2026-10-21 | [movie_providers.dart](../../lib/presentation/providers/movie_providers.dart) | Empty query and "search returned nothing" are different states | Both render as an empty list, so a search with no hits shows the *"type something to search"* placeholder | Fix scheduled in MOV-04 |
| 2026-10-21 | UI strings × `vault/context.md` ground rule | All dev artifacts in English | UI strings are hardcoded Portuguese (`'Buscar filmes...'`, `'Digite algo para buscar'`, `'Erro: $error'`) and 3 tests assert on those literals | Resolved by l10n with a per-user locale — [[architecture/decisions/0011-l10n-per-user-locale]], issues FND-08 + FND-09 |
| 2026-10-21 | [movie_search_page.dart](../../lib/presentation/pages/movie_search_page.dart) × [movie_details_page.dart](../../lib/presentation/pages/movie_details_page.dart) | One poster widget | Poster/placeholder logic is duplicated across both pages | Extracting `MoviePoster` in FND-07 |
| 2026-10-21 | [movie_model.dart](../../lib/data/models/movie_model.dart) | Model is serializable both ways | `fromJson` only, no `toJson` — blocks writing to `movies_cache` | Added in FND-04 |
| 2026-10-21 | Both pages | Network images degrade gracefully | `Image.network` with no `errorBuilder` / `loadingBuilder`, no caching | `cached_network_image` + `MoviePoster` in FND-01/FND-07 |
| 2026-10-21 | [movie_remote_data_source.dart](../../lib/data/datasources/movie_remote_data_source.dart) | Paginated search | `page` is never sent and `total_pages` is ignored — only the first 20 results are ever reachable | Pagination in MOV-04 |

| 2026-10-21 | `pubspec.yaml` | `hive` / `hive_flutter` removed per FND-01 | Resolved — both removed, `flutter pub deps` confirms no trace, `flutter analyze`/`flutter test` clean | Row above (`hive`/`hive_flutter` never imported) closed |
| 2026-10-21 | `movie_summary_model.dart` / `movie_details_model.dart` | Model serializable both ways, per FND-04 | Resolved — both models have `toJson`, snake_case `movies_cache`-shaped, covered by round-trip tests | Row above (`movie_model.dart` no `toJson`) closed |
| 2026-10-21 | `MoviePoster` (FND-07) | One poster widget | Resolved — duplicated poster/placeholder logic in both pages replaced by `core/widgets/movie_poster.dart`, built on `cached_network_image` | Row above (poster logic duplicated) closed |
| 2026-10-21 | `MoviePoster` (FND-07) | Network images degrade gracefully | Resolved — `cached_network_image` with a styled placeholder for null path, loading and error states, covered by `movie_poster_test.dart` | Row above (`Image.network` with no `errorBuilder`) closed |
| 2026-10-21 | `lib/main.dart` × Riverpod 3 defaults | A broken network request surfaces `AppErrorView` promptly | Found in passing while testing FND-07: Riverpod's `ProviderContainer.defaultRetry` retries a failed provider up to 10 times with exponential backoff (capped 6.4s, ~38s total) *before* `AsyncValue` ever reaches the `error` branch — `.when()` treats a retrying failure as `AsyncLoading`, so the spinner would spin for up to ~38s before any error UI appeared | Disabled app-wide: `ProviderScope(retry: (_, __) => null, ...)` in `main.dart`, since `AppErrorView`'s explicit retry button (FND-07) is the intended recovery path, not a silent background one |
| 2026-10-21 | FND-07's own test scenario 2 × reality | Airplane mode, open a previously-viewed film → the poster comes from cache | Found on a physical device: opening *any* film's details needs a live `GET /movie/{id}` for the metadata — nothing but the poster bytes is cached locally. Offline, `AppErrorView` renders before `MoviePoster` ever gets a chance to load from cache, for every film. `movies_cache` (BE-03) only backs server-side list rendering, never a client offline read path — [[architecture/tmdb-integration]] | Not a code defect — the issue's own test scenario assumed an offline-read capability that isn't scoped anywhere yet. Documented as a known limitation in FND-07; no new issue opened since true offline viewing isn't part of the current MVP backlog |
| 2026-10-21 | UI strings × FND-08 | Every user-visible string from an ARB file | Resolved — `'Buscar filmes...'`, `'Digite algo para buscar'`, `'Detalhes do filme'`, `'Erro: $error'`, plus `AppErrorView`'s six messages and `RatingDisplay`'s "unrated" label, all extracted to `lib/l10n/arb/{app_en,app_pt}.arb` | Row below (UI strings hardcoded Portuguese) closed |
| 2026-10-21 | `go_router` × FND-10 | `go_router` used for navigation | Resolved — `core/router/{app_routes,app_router,app_shell,go_router_refresh}.dart`, `MaterialApp.router`, the one `Navigator.push` call site migrated to `context.push`. Deep-link scheme registration (test scenario 3) deferred to AUTH-05, where the actual redirect URI is decided | Row above (`go_router` declared, never imported) closed |
| 2026-10-22 | [[sprints/index]] header × its own per-sprint tables | "66 issues · 9 sprints" | Summing the per-sprint tables gives **70** (DOC 6, FND 11, BE 12, AUTH 8, LIB 8, LST 8, MOV 5, HOME 6, REL 6), confirmed by cross-checking every issue code named in [[sprints/execution-map]]. The same `66` was baked into every phase/overall percentage in `execution-map.md` and into [[MOC]]'s "66 issues across 9 functional sprints" line. Present since the original vault-bootstrap session — not introduced by any work in this session | Corrected to 70 everywhere: `sprints/index.md`, `MOC.md`, and every `execution-map.md` counter recalculated against the true total. Several phase headers in `execution-map.md` also had wrong denominators independent of the 66/70 mistake (Phase 2 said 11, actually 9; Phase 3 said 12, actually 11; Phase 5 said 13, actually 12; Phase 6 said 9, actually 10) — fixed in the same pass |

| 2026-10-23 | `flutter_riverpod` 3.4.3's `StreamProvider<T>.future` | `container.read(someStreamProvider.future)` resolves once the stream emits, same as `FutureProvider` | Hangs indefinitely for an already-settled `Stream.value(...)` — the test's own timeout eventually tears the container down mid-`loading`, logging "disposed during loading state, yet no value could be emitted". Reproduced against a bare `StreamProvider<int>`, with and without `overrideWith`, with and without `.asBroadcastStream()` — not specific to auth or to this codebase | Found while testing AUTH-03's `currentUserProvider`. Worked around, not fixed (it is a dependency bug, not ours to fix): `container.listen(provider, (_, __) {})` then two `await Future<void>.delayed(Duration.zero)` ticks reliably drives the same event through. Documented in [[architecture/overview]] and [[sprints/auth/AUTH-03-auth-state]] so the next `StreamProvider` test reuses the workaround instead of rediscovering the hang |

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Log created and seeded with the findings from the pre-vault codebase audit |
| 2026-10-21 | FND-01 closed the Hive row — appended a resolution row rather than editing the original |
| 2026-10-22 | Logged and fixed the vault-wide 66→70 issue-count error, and four wrong phase denominators in `execution-map.md`, found while closing out BE-01/02/03 |
| 2026-10-23 | Logged a `StreamProvider.future` hang in `flutter_riverpod` 3.4.3, found while closing out AUTH-01/02/03 |
