# Mavie

A portfolio Flutter app for searching and browsing movies, built with clean architecture and Riverpod for state management.

## Status

Early stage. Project scaffold, dependencies, and environment configuration are in place. Search, listing, and detail screens are in progress.

## Planned features

- Search movies by title
- Browse movie details (poster, synopsis, rating)
- Watchlist tied to a user account (planned for a later phase)

## Tech stack

- [Flutter](https://flutter.dev)
- [Riverpod](https://riverpod.dev) for state management
- [Dio](https://pub.dev/packages/dio) for HTTP requests
- [Hive](https://pub.dev/packages/hive) for local storage
- [go_router](https://pub.dev/packages/go_router) for navigation
- [TMDb API](https://www.themoviedb.org/documentation/api) for movie data

## Architecture

The app follows clean architecture, with `lib/` split into three layers:

- `domain/`: entities and repository interfaces, framework-independent
- `data/`: models and repository implementations, talks to the API
- `presentation/`: pages, widgets, and Riverpod providers

Dependencies point inward: `presentation` and `data` depend on `domain`, never the other way around.

## Getting started

1. Copy `.env.example` to `.env` and fill in your TMDb API key.
2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```

Requires the Flutter SDK (^3.12.2). See [flutter.dev](https://docs.flutter.dev/get-started/install) for setup instructions.
