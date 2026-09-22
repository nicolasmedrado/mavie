# Mavie — Project Context

Living reference for whoever (human or assistant) picks up work on this repo. Updated only on explicit request.

## What this is

A portfolio Flutter app. Primary goal: demonstrate clean architecture and solid state management on a real, working app, not a toy demo.

Core feature: search and list movies from a public API. Planned next: a watchlist tied to a user account.

## Ground rules

- All dev-phase artifacts (code, commits, docs, comments) are written in English.
- Commits are made by hand by the project owner, not by the assistant.
- The assistant's default write access is limited to `vault/context.md` and `README.md`. Any other file requires explicit permission for that session.
- Code is not written by the assistant on this project; the assistant reviews, explains concepts, and directs. Nicolas writes the implementation himself.

## Architecture

Clean architecture, three layers under `lib/`:

- `domain/` — entities, abstract repository interfaces, (optionally) use cases. No dependency on Flutter or any external package.
- `data/` — models (`fromJson`/`toJson`), remote data sources, repository implementations. Depends on `domain`, never the reverse.
- `presentation/` — pages, widgets, Riverpod providers/notifiers. Depends on `domain`.

Dependency direction always points inward: `presentation` and `data` know about `domain`; `domain` knows about neither.

## Tech stack

- Flutter (SDK ^3.12.2)
- State management: Riverpod (not yet added to `pubspec.yaml`, planned for an upcoming commit)
- Movie data source: not yet chosen in code, TMDb discussed as the likely candidate (free tier, well documented, includes poster images)
- Persistence for the future watchlist feature: not yet decided (options discussed: `shared_preferences`/`sqflite` for local, or Firebase Auth + Firestore for account-backed)

## Current status

Scaffold stage. `lib/domain`, `lib/data`, `lib/presentation` folders exist and are empty. `lib/main.dart` is still the default Flutter counter template. `pubspec.yaml` has no feature dependencies yet (only `cupertino_icons` and `flutter_lints`). No commits in the repo yet.

## Open decisions

- Movie API provider (leaning TMDb, not confirmed)
- Whether to include an explicit `usecases` sublayer in `domain`, or call repositories directly from Riverpod notifiers
- Local vs. remote persistence for the watchlist, and whether watchlist requires full auth or a lighter identity scheme
