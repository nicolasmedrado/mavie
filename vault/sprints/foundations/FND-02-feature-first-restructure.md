---
title: Feature-first restructure
sprint: foundations
feature: —
milestone: mvp
status: backlog
started_at:
finished_at:
---

# FND-02 · Feature-first restructure

## Goal

`lib/` is organised by feature, with the three clean-architecture layers nested inside each one. Every issue after this lands in the final shape.

**This is the most time-sensitive issue in the project.** Nine files today, roughly eighty at MVP — the migration cost grows superlinearly. [[architecture/decisions/0001-feature-first-modules]].

## Scope

Pure move-and-rename. **No behaviour changes, no new abstractions.** Resist the urge to fix anything else while moving files — the diff has to stay reviewable as "the same code, elsewhere".

| From | To |
|---|---|
| `lib/main.dart` (runApp + MaterialApp) | `lib/main.dart` + `lib/app/bootstrap.dart` + `lib/app/app.dart` |
| `lib/data/datasources/dio_client.dart` | `lib/core/network/tmdb_dio.dart` |
| `lib/domain/entities/movie.dart` | `lib/features/movies/domain/entities/movie.dart` |
| `lib/domain/repositories/movie_repository.dart` | `lib/features/movies/domain/repositories/` |
| `lib/data/models/movie_model.dart` | `lib/features/movies/data/models/` |
| `lib/data/datasources/movie_remote_data_source.dart` | `lib/features/movies/data/datasources/` |
| `lib/data/repositories/movie_repository_impl.dart` | `lib/features/movies/data/repositories/` |
| `lib/data/providers/providers.dart` | **dissolved** into `lib/features/movies/presentation/providers/` |
| `lib/presentation/providers/movie_providers.dart` | `lib/features/movies/presentation/providers/` |
| `lib/presentation/pages/*.dart` | `lib/features/movies/presentation/pages/` |

`test/` mirrors the same structure.

### Rename

`movieClientProvider` → `tmdbDioProvider`. "Movie client" sitting next to a Supabase client is ambiguous, and the Supabase client arrives two issues later.

### Create empty but real

`lib/core/{env,error,network,router,theme,widgets}/` and `lib/features/{auth,library,lists,home,profile}/` get created as work lands, not pre-stubbed with empty folders.

### Write down the rule

`features/X` may import `core/**` and `features/Y/domain/**` — never another feature's `data/` or `presentation/`. `features/movies/domain` is the shared kernel. Already stated in [[architecture/overview]]; this issue is where it starts being true.

## Checklist

- [ ] Move every file per the table
- [ ] Split `main.dart` into `bootstrap()` (dotenv load, later Supabase init) and `app.dart` (`MaterialApp`)
- [ ] Rename `movieClientProvider` → `tmdbDioProvider`
- [ ] Update every import — they are package-absolute (`package:mavie/...`), so this is mechanical
- [ ] Mirror the structure in `test/`
- [ ] Update the file tables in [[features/movie-search/_overview]] and [[features/movie-details/_overview]]

## Test scenario

1. `flutter analyze`
   - **Expected:** zero issues. A missed import is a compile error, not a silent failure
2. `flutter test`
   - **Expected:** all 4 files green, unchanged assertions
3. `flutter run`, search for a film, open it
   - **Expected:** identical behaviour

## Dependencies

- **Blocked by:** FND-01
- **Blocks:** everything. Do it before writing any new feature code

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | issue created |
