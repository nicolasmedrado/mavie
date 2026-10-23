---
title: Local setup
status: active
last_review: 2026-10-21
---

# Local setup

## Requirements

- Flutter SDK, Dart `^3.12.2`
- A TMDb API key — free, from [themoviedb.org](https://www.themoviedb.org/settings/api)
- Docker Desktop, running, for local Supabase
- The Supabase CLI, via `npx` — see [Supabase local development](#supabase-local-development)

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

`.env` gains `SUPABASE_URL` and `SUPABASE_ANON_KEY`, pointing at the real hosted project. The anon key is **designed** to be public — the data is protected by [[architecture/security-model|RLS]], not by key secrecy. It is the new-style `sb_publishable_...` format, not the legacy JWT anon key.

**The service role / secret key (`sb_secret_...`) must never be in the app, in `.env`, or in CI.** It bypasses RLS entirely.

## Tests

```bash
flutter analyze
flutter test
```

Tests never make real network calls — fakes all the way down ([[architecture/decisions/0014-hand-rolled-fakes]]). A placeholder key in `.env` is enough, which is what CI relies on (FND-03).

## Supabase local development

No scoop/choco on this project's dev machines — the CLI is never installed globally, always invoked through `npx`:

```bash
npx -y supabase start                  # local Postgres + Auth + Storage in Docker — requires Docker Desktop running
npx -y supabase db reset               # replay migrations + seed
npx -y supabase migration new <name>
npx -y supabase db push                # apply pending migrations to the hosted project
npx -y supabase migration list         # compare local vs. remote migration timestamps
npx -y supabase login                  # interactive OAuth — run this one directly in a real terminal,
                                        # not through an automated/non-TTY tool; it fails with
                                        # LoginMissingTokenError otherwise
npx -y supabase link --project-ref <ref>
```

Migrations in `supabase/migrations/`, seed in `supabase/seed.sql`, the RLS proof script in `supabase/tests/rls_test.sql` (arrives with BE-12).

To test RLS directly against the local Postgres without a real client, simulate a user inside a transaction and roll it back:

```sql
begin;
set local role authenticated;
set local request.jwt.claim.sub = '<uuid>';
-- queries here run as that user, under RLS
rollback;
```

**`auto_expose_new_tables = false`** in `config.toml` (both locally and on the hosted project): no table is reachable through the Data API from an RLS policy alone — every table also needs an explicit `grant` to `authenticated` (or whatever role), or every query fails with `permission denied` regardless of policy correctness. See [[architecture/security-model]].

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
| 2026-10-22 | Supabase local development section replaced with the real, verified workflow from BE-01/02/03 — `npx` prefix (no scoop/choco on this machine), `auto_expose_new_tables` gotcha, RLS testing recipe |
