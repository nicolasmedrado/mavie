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

supabaseClientProvider     SupabaseClient (overridden in tests)
  └─ <feature> remote data sources → repositories → notifiers
```

Repository providers are always typed as the **domain interface**, never the implementation. That is what lets a test swap in a hand-written fake with `overrideWithValue` and never touch the network.

Providers live beside the feature that owns them — all of the above now lives in `features/movies/presentation/providers/movie_providers.dart`; the old global `lib/data/providers/providers.dart` was dissolved into it by FND-02, which also renamed `movieClientProvider` to `tmdbDioProvider` ("movie client" sitting next to a Supabase client was ambiguous).

## Error handling

Two paths, deliberately different — [[architecture/decisions/0009-result-for-commands]]:

- **Reads.** Data sources throw; repositories catch and rethrow a sealed `AppFailure`; providers surface it as `AsyncValue.error`; one `AppErrorView` switches on the failure type and renders a localized message with a retry. `AsyncValue` already *is* a result type for reads — wrapping another one inside it would mean unwrapping twice at every call site.
- **Writes.** Repositories return `Result<T>` (`Ok` | `Err`). Sign-in, rating, creating a list all need inline feedback — a field error under an input, a snackbar with rollback of an optimistic update — which an exception travelling through `AsyncValue` fits badly. An exhaustive `switch` on a sealed `Result` is checked by the compiler.

`AppFailure` and `Result` landed in FND-05 (`core/error/{app_failure,result,failure_mapper}.dart`). `MovieRepositoryImpl` catches and rethrows mapped failures for both reads today — writes return `Result<T>` from AUTH-02 onward, once the first write repository exists. Screens still render the raw `AsyncValue.error` as `Text('Erro: $error')`, since `AppErrorView` (FND-07) is what actually consumes the failure type.

## Navigation

`go_router`, adopted in FND-10 before any auth work — [[architecture/decisions/0010-go-router-declarative-auth]]. Auth gating is a declarative `redirect` problem; retrofitting it onto imperative `Navigator.push` means scattering session checks across pages.

```
/splash
/sign-in  /sign-up  /forgot-password
StatefulShellRoute.indexedStack
  /home   /search   /library   /lists
/movie/:id                 pushed above the shell
/lists/new  /lists/:listId  /lists/:listId/members
/profile  /settings
```

**Do not `ref.watch` the auth state inside `routerProvider`** — that rebuilds the whole `GoRouter` on every auth event and wipes the navigation stack. Use `refreshListenable` with a `ChangeNotifier` bridged from the auth stream, and `ref.read` inside `redirect`.

While the session is still being restored from secure storage the router pins to `/splash`. Without that gate the sign-in screen flashes on every cold start.

## Design system

`core/theme/{app_colors,app_spacing,app_typography,app_theme}.dart` — landed in FND-06. `AppTheme.light`/`AppTheme.dark` both build on `ColorScheme.fromSeed(seedColor: AppColors.seed)`, wired in `app.dart` with `themeMode: ThemeMode.system`. `AppColors.rating` is the one color with nowhere else to live — used on the details screen today, in list rows, member chips and carousels later; everything else comes from `Theme.of(context).colorScheme` (e.g. `onSurfaceVariant` for muted text) rather than a new named constant. `AppSpacing` is a 4pt scale (`xs 4` … `xl 32`) plus radius and elevation tokens — both existing pages are migrated off their literal `SizedBox`/`BorderRadius.circular`/`Colors.*` values. FND-07 is next, for the shared widgets that consume these tokens (`MoviePoster`, `RatingDisplay`, `AppErrorView`, `AppEmptyView`, `AppLoadingIndicator`).

## Localization

`flutter_localizations` + ARB, Portuguese and English. The locale is a **per-user preference** stored in `profiles.locale`, not the device locale — the two users run the app in different languages on different phones, against the same data. [[architecture/decisions/0011-l10n-per-user-locale]]

System list names (*Want to watch*, *Watched*) are client-side ARB strings keyed off the `movie_status` enum, never stored in the database. Custom list names live in `lists.name` and are not localizable, which is correct — the user typed them.

## Testing

Hand-written fakes, no mocking package — [[architecture/decisions/0014-hand-rolled-fakes]]. The patterns already in the repo are the ones to generalize:

- A fake repository implementing the domain interface, injected via `ProviderScope(overrides: [repositoryProvider.overrideWithValue(fake)])` — see [movie_search_page_test.dart](../../test/presentation/pages/movie_search_page_test.dart).
- A fake `HttpClientAdapter` on a bare `Dio` for data-source tests, capturing the request to assert path and query params — see [movie_remote_data_source_test.dart](../../test/data/datasources/movie_remote_data_source_test.dart).

FND-09 moves the shared pieces into `test/support/` with a `pumpApp` helper that provides localizations, so widget tests assert on `l10n.searchHint` rather than a Portuguese literal.

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
