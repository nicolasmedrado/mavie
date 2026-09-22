# Mavie

A portfolio Flutter app for searching and browsing movies, built with clean architecture and Riverpod for state management.

## Status

Early scaffold stage. Search/list functionality and the architecture layers are in progress.

## Planned features

- Search movies by title
- Browse movie details (poster, synopsis, rating)
- Watchlist tied to a user account (planned for a later phase)

## Tech stack

- [Flutter](https://flutter.dev)
- [Riverpod](https://riverpod.dev) for state management
- Movie data via a public movies API (provider TBD, TMDb under consideration)

## Architecture

The app follows clean architecture, with `lib/` split into three layers:

- `domain/` — entities and repository interfaces, framework-independent
- `data/` — models and repository implementations, talks to the API
- `presentation/` — pages, widgets, and Riverpod providers

Dependencies point inward: `presentation` and `data` depend on `domain`, never the other way around.

## Getting started

```bash
flutter pub get
flutter run
```

Requires the Flutter SDK (^3.12.2). See [flutter.dev](https://docs.flutter.dev/get-started/install) for setup instructions.
