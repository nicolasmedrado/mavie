---
title: Architecture overview
status: in_progress
last_review: 2026-10-21
---

# Architecture overview

Flutter client talking to two backends: **TMDb** for film metadata and **Supabase** for everything that belongs to a user. There is no server of our own — [[architecture/decisions/0003-supabase-over-firebase]].

```
Flutter app
  ├─ TMDb REST (dio)        search, details, videos, recommendations, trending
  └─ Supabase (postgrest)   auth, profiles, library, lists, ratings, storage
```

## Layering

Clean architecture, three layers, dependencies pointing inward:

| Layer | Holds | May depend on |
|---|---|---|
| `domain` | entities, repository interfaces, pure logic | nothing — no Flutter, no packages |
| `data` | models (`fromJson`/`toJson`), data sources, repository implementations | `domain` |
| `presentation` | pages, widgets, Riverpod providers and notifiers | `domain` |

`domain` knows about neither of the other two. There is **no `usecases` sublayer**: Riverpod notifiers call repositories directly. A use-case class per operation would be a file with one method forwarding one call, which is ceremony rather than structure — if a piece of logic ever stops being a pass-through, it becomes a pure function in `domain`.

## Feature-first, not layer-first

The three layers are nested **inside each feature**, not at the top of `lib/`:

```
lib/
  main.dart
  app/            bootstrap.dart, app.dart
  core/           env, error, network, router, theme, widgets
  features/
    auth/         domain/ data/ presentation/
    movies/       domain/ data/ presentation/     <- search, details, trailer
    library/      domain/ data/ presentation/     <- user_movies: system lists + rating
    lists/        domain/ data/ presentation/
    home/         domain/ data/ presentation/     <- recommendations
    profile/      domain/ data/ presentation/
  l10n/arb/
```

**Dependency rule:** `features/X` may import `core/**` and `features/Y/domain/**`, never another feature's `data/` or `presentation/`. `features/movies/domain` is the declared shared kernel — every feature needs the movie entities.

This does not weaken clean architecture, it makes it visible: the dependency rule applies per feature, and "can this folder be deleted cleanly?" becomes a real question with a real answer.

> FND-02 moved the code into this shape. `app/`, `core/network/` and `features/movies/` exist; the rest of `core/` and the other `features/*` folders are created as their own issues land, per [[architecture/decisions/0001-feature-first-modules]].

## State management

Riverpod 3, **hand-written providers, no code generation** — [[architecture/decisions/0002-riverpod-without-codegen]]. The modern `Notifier` / `AsyncNotifier` API, never the legacy `StateNotifier`.

Current provider graph:

```
tmdbDioProvider            Dio configured for api.themoviedb.org
  └─ movieRemoteDataSourceProvider
       └─ movieRepositoryProvider : MovieRepository   <- typed as the domain interface
            ├─ movieSearchResultsProvider  FutureProvider<List<Movie>>
            └─ movieDetailsProvider        FutureProvider.family<Movie, int>

supabaseClientProvider     SupabaseClient              <- Supabase.instance.client, initialized in bootstrap()
  ├─ authRepositoryProvider : AuthRepository            <- typed as the domain interface, like movieRepositoryProvider
  │    └─ AuthRepositoryImpl                            commands only: sign up, sign in, reset password, sign out
  └─ authStateProvider        StreamProvider<AuthState> <- supabase.auth.onAuthStateChange
       └─ currentUserProvider Provider<AppUser?>        <- derived; null while loading or signed out
```

Tests override `authRepositoryProvider` with a hand-written fake (once one exists, from AUTH-04) or `authStateProvider` directly with a canned stream — not `supabaseClientProvider` itself, which would mean faking the Supabase SDK's wire protocol for no benefit. See `auth_providers_test.dart`.

Repository providers are always typed as the **domain interface**, never the implementation. That is what lets a test swap in a hand-written fake with `overrideWithValue` and never touch the network.

Providers live beside the feature that owns them — all of the above now lives in `features/movies/presentation/providers/movie_providers.dart`; the old global `lib/data/providers/providers.dart` was dissolved into it by FND-02, which also renamed `movieClientProvider` to `tmdbDioProvider` ("movie client" sitting next to a Supabase client was ambiguous).

## Error handling

Two paths, deliberately different — [[architecture/decisions/0009-result-for-commands]]:

- **Reads.** Data sources throw; repositories catch and rethrow a sealed `AppFailure`; providers surface it as `AsyncValue.error`; one `AppErrorView` switches on the failure type and renders a localized message with a retry. `AsyncValue` already *is* a result type for reads — wrapping another one inside it would mean unwrapping twice at every call site.
- **Writes.** Repositories return `Result<T>` (`Ok` | `Err`). Sign-in, rating, creating a list all need inline feedback — a field error under an input, a snackbar with rollback of an optimistic update — which an exception travelling through `AsyncValue` fits badly. An exhaustive `switch` on a sealed `Result` is checked by the compiler.

`AppFailure` and `Result` landed in FND-05 (`core/error/{app_failure,result,failure_mapper}.dart`). `MovieRepositoryImpl` catches and rethrows mapped failures for both reads today. `AuthRepositoryImpl` (AUTH-02) is the first write repository and returns `Result<T>` from every command — `failure_mapper.dart` already mapped `AuthException` since FND-05, written ahead of the repository that would actually throw one. Both screens render `AppErrorView` (FND-07, `core/widgets/app_error_view.dart`), which switches on the failure and wires a real retry action via `ref.invalidate`. Since FND-08, each case in that switch reads a real `AppLocalizations` getter (`l10n.errorNetwork`, etc.) instead of a hardcoded string — `AppFailure.l10nKey` is a secondary, stable identifier, not what actually drives the switch (ARB-generated getters are named methods, not a dynamic `l10n[key]` lookup).

> **Riverpod retries before you see an error.** `ProviderContainer.defaultRetry` retries a failed provider up to 10 times with exponential backoff (capped at 6.4s, ~38s total) before `AsyncValue` ever reaches `error` — `.when()` treats a retrying failure as `AsyncLoading` the whole time. Found while testing FND-07's retry button. Disabled app-wide in `main.dart` (`ProviderScope(retry: (_, __) => null, ...)`), since `AppErrorView`'s explicit retry is the intended recovery path, not a silent ~38s background one. `test/support/pump_app.dart`'s `pumpApp` disables it by default too, so a new widget test gets this for free.

## Navigation

`go_router`, adopted in FND-10 (`core/router/{app_routes,app_router,app_shell,go_router_refresh}.dart`) before any auth work — [[architecture/decisions/0010-go-router-declarative-auth]]. Auth gating is a declarative `redirect` problem; retrofitting it onto imperative `Navigator.push` means scattering session checks across pages. `app.dart` uses `MaterialApp.router`; the app launches straight into `/search` (the shell's search tab) — unchanged from before this issue, since there's no auth yet to gate on.

```
/splash                                   placeholder — reachable, but nothing redirects here yet
/sign-in  /sign-up  /forgot-password       placeholder
StatefulShellRoute.indexedStack
  /home   /search   /library   /lists      /search is the real MovieSearchPage; the rest are placeholder
/movie/:id                                 real MovieDetailsPage, pushed above the shell
/lists/new  /lists/:listId  /lists/:listId/members   placeholder
/profile  /settings                        placeholder
```

Every route that doesn't have a real screen yet renders `core/widgets/placeholder_page.dart` — per FND-02's own rule, feature folders (`features/{auth,home,library,lists,profile}`) are created when their issue actually lands, not pre-stubbed for a route table.

**Do not `ref.watch` the auth state inside `routerProvider`** — that rebuilds the whole `GoRouter` on every auth event and wipes the navigation stack. Use `refreshListenable` with a `ChangeNotifier` bridged from the auth stream, and `ref.read` inside `redirect`. `go_router_refresh.dart`'s `GoRouterRefreshStream` is written and ready; AUTH-06 is what actually wires a `redirect` and a `refreshListenable` onto `appRouterProvider`, since there's no auth stream to bridge until then.

Deep-link scheme registration (`AndroidManifest.xml` intent-filter, iOS `Info.plist` URL type) is **not done** — deferred to AUTH-05, where the actual OAuth redirect URI decides what the scheme should be, rather than guessing one now and redoing it.

While the session is still being restored from secure storage the router pins to `/splash`. Without that gate the sign-in screen flashes on every cold start.

## Design system

`core/theme/{app_colors,app_spacing,app_typography,app_theme}.dart` — landed in FND-06. `AppTheme.light`/`AppTheme.dark` both build on `ColorScheme.fromSeed(seedColor: AppColors.seed)`, wired in `app.dart` with `themeMode: ThemeMode.system`. `AppColors.rating` is the one color with nowhere else to live — used on the details screen today, in list rows, member chips and carousels later; everything else comes from `Theme.of(context).colorScheme` (e.g. `onSurfaceVariant` for muted text) rather than a new named constant. `AppSpacing` is a 4pt scale (`xs 4` … `xl 32`) plus radius, elevation and poster-size tokens.

`core/widgets/` — landed in FND-07, built on the tokens above: `MoviePoster` (takes a `posterPath`, not a `Movie`; three size variants; `cached_network_image` with a styled placeholder for the null/loading/error cases), `RatingDisplay` (`double?` — `null` is unrated, `0` is a real score), `AppErrorView` (see Error handling above), `AppEmptyView`, `AppLoadingIndicator`. Both existing pages are fully migrated: no more literal `SizedBox`/`BorderRadius.circular`/`Colors.*`/`Image.network`.

## Localization

`flutter_localizations` + ARB (`lib/l10n/arb/{app_en,app_pt}.arb`), landed in FND-08. Codegen output lives in `lib/l10n/generated/` — gitignored, rebuilt by `flutter pub get` (`generate: true`, set in FND-01). The locale is meant to be a **per-user preference** stored in `profiles.locale`, not the device locale — the two users run the app in different languages on different phones, against the same data. [[architecture/decisions/0011-l10n-per-user-locale]]

`core/l10n/locale_provider.dart`'s `localeProvider` resolves it today: device locale if it's `pt` or `en`, else `pt`. `currentUser?.locale` takes priority once AUTH-07 exists — the seam ships now so that issue only has to supply the value.

System list names (*Want to watch*, *Watched*) are client-side ARB strings (`libraryStatusWantToWatch`/`libraryStatusWatched`) keyed off the `movie_status` enum, never stored in the database — not wired to any screen yet since the enum is LIB-01. Custom list names live in `lists.name` and are not localizable, which is correct — the user typed them. Film titles and synopses are **not** localized — [[architecture/decisions/0015-tmdb-metadata-not-localized]].

## Testing

Hand-written fakes, no mocking package — [[architecture/decisions/0014-hand-rolled-fakes]]. `test/support/` (FND-09) is the entry point for new tests:

- [pump_app.dart](../../test/support/pump_app.dart) — `pumpApp(tester, child, {overrides, locale})` wraps the widget under test in a `ProviderScope` + localized `MaterialApp`; `l10nOf(tester)` resolves `AppLocalizations` from that tree so assertions read `find.text(l10n.searchHint)`, passing in either locale. Riverpod's automatic retry is disabled by default (see below) — pass a real `retry` to opt back in.
- [fakes/fake_movie_repository.dart](../../test/support/fakes/fake_movie_repository.dart) — one configurable fake `MovieRepository` (search/details results or failures, call-count spies) replaces the ad hoc fakes that used to live in each test file.
- [fakes/fake_http_adapter.dart](../../test/support/fakes/fake_http_adapter.dart) — a fake `HttpClientAdapter` on a bare `Dio`, either returning a canned JSON response or throwing a given `DioException`, capturing the request for data-source tests.
- [fixtures/](../../test/support/fixtures/) — real captured TMDb JSON (`search_movie.json`, `movie_details.json`, `movie_details_minimal.json`, `movie_videos.json`, `movie_recommendations.json`), not hand-written. The last two aren't consumed by any code yet — captured ahead of MOV-02 and HOME-02.

A fake drifting from its interface is a **compile error** — the whole point with five repositories about to exist.

Testing a `StreamProvider` directly: `container.read(someStreamProvider.future)` does not reliably resolve for an already-settled `Stream.value(...)` on `flutter_riverpod` 3.4.3 — it hangs until the test's own timeout tears the container down (reproduced against a bare `StreamProvider<int>`, nothing auth-specific). `auth_providers_test.dart`'s `_settle()` works around it: `container.listen(provider, (_, __) {})` then two `await Future<void>.delayed(Duration.zero)` ticks. Logged in [[_meta/discrepancies]]; reuse that pattern over `.future` until the upstream bug is confirmed fixed.

The recommendation ranking (HOME-02) is written as a **pure function** over seeds, candidates and exclusions, so it is testable with no I/O at all.

## Related

- [[architecture/data-model]] — the Postgres schema
- [[architecture/security-model]] — RLS and the cross-member read gateway
- [[architecture/tmdb-integration]] — endpoints, caching, attribution
- [[architecture/decisions/0001-feature-first-modules]] and the rest of the ADR log

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Written from the shipped code plus the MVP architecture decisions |
| 2026-10-21 | FND-02 landed: feature-first layout, `tmdbDioProvider` rename, `app/` bootstrap/app split |
| 2026-10-21 | FND-04 landed: `MovieSummary`/`MovieDetails` split, both serializable both ways |
| 2026-10-21 | FND-05 landed: `AppFailure`/`Result`/`failure_mapper`, `MovieRepositoryImpl` rethrows mapped failures |
| 2026-10-21 | FND-06 landed: `core/theme/` tokens, `AppTheme.light`/`dark`, both pages migrated off hardcoded values |
| 2026-10-21 | FND-07 landed: `core/widgets/` (`MoviePoster`, `RatingDisplay`, `AppErrorView`, `AppEmptyView`, `AppLoadingIndicator`); found and fixed Riverpod's default ~38s auto-retry masking errors |
| 2026-10-21 | FND-08 + FND-09 landed: l10n (`localeProvider`, every string extracted) and `test/support/` (`pumpApp`, generalized fakes, real fixtures). Testing section's stale pre-FND-02 paths also corrected in passing |
| 2026-10-21 | FND-10 landed: `go_router` adoption, `MaterialApp.router`, four-tab shell with placeholder routes. `pump_app.dart`'s `pumpApp` gained an optional `routes` param for tests that need real navigation |
| 2026-10-21 | FND-11 landed: `strict-casts`/`strict-raw-types` on, caught an untyped `dio.get` in the data source. **Phase 1 — Foundations closed, 11/11** |
| 2026-10-23 | AUTH-01/02/03 landed: `supabaseClientProvider`, `AppUser`/`AuthRepository`/`AuthRepositoryImpl` (the first `Result`-returning repository), `authStateProvider`/`currentUserProvider`. Found and documented a `StreamProvider.future` bug in riverpod 3.4.3 while testing |
