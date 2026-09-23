# Mavie: Project Context

Living reference for whoever (human or assistant) picks up work on this repo. Updated only on explicit request.

## What this is

A portfolio Flutter app. Primary goal: demonstrate clean architecture and solid state management on a real, working app, not a toy demo.

Core feature: search and list movies from a public API (TMDb). Planned next: a watchlist tied to a user account.

## Ground rules

- All dev-phase artifacts (code, commits, docs, comments) are written in English.
- Commits are made by hand by the project owner, not by the assistant.
- The assistant's default write access is limited to `vault/context.md` and `README.md`. Any other file requires explicit permission for that session.
- Code is not written by the assistant on this project, the assistant reviews, explains concepts, and directs. Nicolas writes the implementation himself.

## Architecture

Clean architecture, three layers under `lib/`:

- `domain/`: entities, abstract repository interfaces, (optionally) use cases. No dependency on Flutter or any external package.
- `data/`: models (`fromJson`/`toJson`), remote data sources, repository implementations. Depends on `domain`, never the reverse.
- `presentation/`: pages, widgets, Riverpod providers/notifiers. Depends on `domain`.

Dependency direction always points inward: `presentation` and `data` know about `domain`, `domain` knows about neither.

## Tech stack

- Flutter (SDK ^3.12.2)
- State management: Riverpod (`flutter_riverpod`)
- HTTP client: `dio`
- Local storage: `hive` / `hive_flutter`
- Navigation: `go_router`
- Movie data source: TMDb API
- Secrets: `flutter_dotenv`, key loaded from a local `.env` file (see Secrets management below)
- Persistence for the future watchlist feature: not yet decided (options discussed: Hive locally, or Firebase Auth + Firestore for account-backed)

## Secrets management

The TMDb API key is not committed. It lives in a local `.env` file (git-ignored), loaded at startup via `flutter_dotenv`:

- `.env`: real key, git-ignored, one per machine.
- `.env.example`: committed template with a placeholder value, so anyone cloning the repo knows what to create.
- `.env` is registered as a Flutter asset in `pubspec.yaml` so it ships inside the app bundle.
- `main.dart` calls `WidgetsFlutterBinding.ensureInitialized()` then `await dotenv.load()` before `runApp`, so the key is available before any widget builds.
- The key is read at call sites via `dotenv.env['TMDB_API_KEY']`.

An earlier approach used a git-ignored Dart constants file (`lib/data/tmdb_api_key.dart`). It was replaced by the `.env` approach and removed.

## Current status

Dependencies installed (Riverpod, Dio, Hive, go_router, flutter_dotenv). Environment variable loading is wired and working. `lib/domain`, `lib/data`, `lib/presentation` folders exist but are still empty: no entities, models, repositories, or providers written yet. `lib/main.dart` is still the default Flutter counter template otherwise (no app-specific UI yet).

## Open decisions

- Whether to include an explicit `usecases` sublayer in `domain`, or call repositories directly from Riverpod notifiers.
- Local vs. remote persistence for the watchlist, and whether it requires full auth or a lighter identity scheme.
