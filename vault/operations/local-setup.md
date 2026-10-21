---
title: Local setup
status: active
last_review: 2026-10-21
---

# Local setup

## Requirements

- Flutter SDK, Dart `^3.12.2`
- A TMDb API key — free, from [themoviedb.org](https://www.themoviedb.org/settings/api)
- Later, from BE-01: Docker and the Supabase CLI

## Running the app

```bash
cp .env.example .env     # then fill in the real key
flutter pub get
flutter run
```

## Secrets

The TMDb key is not committed. It lives in a git-ignored `.env`, loaded at startup by `flutter_dotenv`:

- `.env` — the real key, one per machine, git-ignored
- `.env.example` — committed template with a placeholder, so a fresh clone knows what to create
- `.env` is registered as a Flutter **asset** in `pubspec.yaml`, so it ships inside the app bundle
- `main.dart` calls `WidgetsFlutterBinding.ensureInitialized()` then `await dotenv.load()` before `runApp`, so the key exists before any widget builds
- Read at call sites via `dotenv.env['TMDB_API_KEY']`

> **The key is recoverable from a built APK** — `.env` being an asset means git-ignoring it protects the repository, not the artifact. Accepted for the MVP: it is a read-only key, so the exposure is rate-limit abuse, not data loss. [[architecture/decisions/0012-tmdb-key-in-client]].

An earlier approach used a git-ignored Dart constants file (`lib/data/tmdb_api_key.dart`). Same property, replaced by `.env`, removed.

### Supabase keys (from BE-01)

`.env` gains `SUPABASE_URL` and `SUPABASE_ANON_KEY`. The anon key is **designed** to be public — the data is protected by [[architecture/security-model|RLS]], not by key secrecy.

**The service role key must never be in the app, in `.env`, or in CI.** It bypasses RLS entirely.

## Tests

```bash
flutter analyze
flutter test
```

Tests never make real network calls — fakes all the way down ([[architecture/decisions/0014-hand-rolled-fakes]]). A placeholder key in `.env` is enough, which is what CI relies on (FND-03).

## Supabase local development

> Arrives with BE-01. Expected shape:
>
> ```bash
> supabase start                  # local Postgres + Auth + Storage in Docker
> supabase db reset               # replay migrations + seed
> supabase migration new <name>
> supabase db push                # apply to the hosted project
> ```
>
> Migrations in `supabase/migrations/`, seed in `supabase/seed.sql`, the RLS proof script in `supabase/tests/rls_test.sql`.

## Gotchas

| Symptom | Cause |
|---|---|
| `Unable to load asset: .env` | `.env` does not exist — copy `.env.example` |
| Search returns nothing, no error | Invalid or empty `TMDB_API_KEY`; TMDb answers 401 and nothing maps it yet (FND-05) |
| Changing `.env` has no effect | It is a bundled asset — hot reload will not pick it up, restart the app |

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Written; secrets section carried over from the retired `vault/context.md` |
