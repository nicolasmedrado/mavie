---
title: Sprints
status: active
last_review: 2026-10-21
---

# Sprints

Sprints group issues **by functionality, not by date**. The numbering inside a sprint is not the order to work in — that is [[sprints/execution-map]].

Only the **FND** issues have their own files so far. The rest are specified here as one-liners and get a file from [[sprints/_issue-template]] when their turn comes — see [[_meta/documentation-process]].

**70 issues · 9 sprints**

---

## DOC — Documentation and hygiene

| Issue | Scope | Status |
|---|---|---|
| DOC-01 | Rewrite the README for the real product: features, architecture, setup, TMDb attribution | backlog |
| DOC-02 | Retire `vault/context.md`, redistribute its content | done |
| DOC-03 | Document the shipped search and details flow end to end | done |
| DOC-04 | ER diagram and table-by-table rationale | done |
| DOC-05 | ADR log with the fourteen MVP decisions | done |
| DOC-06 | TMDb attribution in-app: About screen with the required notice and logo | backlog |

## FND — Foundations

| Issue | Scope | Status |
|---|---|---|
| [[sprints/foundations/FND-01-dependency-cleanup\|FND-01]] | Remove `hive`/`hive_flutter`; add `supabase_flutter`, `flutter_localizations`, `intl`, `cached_network_image` | done |
| [[sprints/foundations/FND-02-feature-first-restructure\|FND-02]] | Move the nine existing files into `core/` + `features/movies/`; rename `movieClientProvider` | done |
| [[sprints/foundations/FND-03-ci-pipeline\|FND-03]] | GitHub Actions: format, analyze, test with coverage; branch protection | done |
| [[sprints/foundations/FND-04-entity-split\|FND-04]] | `MovieSummary` / `MovieDetails`; add the discarded fields; add `toJson` | done |
| [[sprints/foundations/FND-05-result-and-failures\|FND-05]] | Sealed `AppFailure` + `Result`, and mappers for the three exception families | done |
| [[sprints/foundations/FND-06-design-system\|FND-06]] | `AppTheme` light and dark, colour, typography and spacing tokens | done |
| [[sprints/foundations/FND-07-shared-widgets\|FND-07]] | `MoviePoster`, `RatingDisplay`, `AppErrorView`, `AppEmptyView`, `AppLoadingIndicator` | done |
| [[sprints/foundations/FND-08-l10n-setup\|FND-08]] | `l10n.yaml`, `app_en.arb`, `app_pt.arb`; extract every hardcoded string | done |
| [[sprints/foundations/FND-09-test-infrastructure\|FND-09]] | `test/support/`: `pumpApp`, shared fakes, JSON fixtures; migrate the broken assertions | done |
| [[sprints/foundations/FND-10-go-router-adoption\|FND-10]] | Route table, `StatefulShellRoute`, migrate off `Navigator.push`, refresh bridge | done |
| [[sprints/foundations/FND-11-lint-rules\|FND-11]] | Tighten `analysis_options.yaml` beyond the `flutter_lints` defaults | done |

## BE — Backend (Supabase)

| Issue | Scope | Status |
|---|---|---|
| [[sprints/backend/BE-01-supabase-project\|BE-01]] | Supabase project, CLI, `supabase/migrations/`, extensions, env keys | done |
| [[sprints/backend/BE-02-profiles-table\|BE-02]] | `profiles` table, `handle_new_user` trigger, `updated_at` trigger, RLS | done |
| [[sprints/backend/BE-03-movies-cache\|BE-03]] | `movies_cache` table, trigram index, read-only RLS | done |
| BE-04 | `user_movies` table, the four CHECK constraints, three indexes, own-rows-only RLS | backlog |
| BE-05 | `lists` / `list_members` / `list_items`, owner-as-member trigger, single-owner index | backlog |
| BE-06 | `is_list_member`, `is_list_owner`, `shares_list_with` + the lists policies | backlog |
| BE-07 | `set_library_entry`, `clear_library_entry`, `refresh_movie_cache` | backlog |
| BE-08 | `get_list_items` — the cross-member ratings gateway | backlog |
| BE-09 | `find_profile_by_username`, `invite_to_list`, `accept_list_invite` | backlog |
| BE-10 | `get_excluded_tmdb_ids`, `get_recommendation_seeds` | backlog |
| BE-11 | `avatars` and `list-covers` buckets with path-scoped write policies | backlog |
| **BE-12** | **`supabase/tests/rls_test.sql` — prove the policies.** Before any list UI | backlog |

## AUTH — Accounts

| Issue | Scope | Status |
|---|---|---|
| [[sprints/auth/AUTH-01-supabase-client\|AUTH-01]] | `Supabase.initialize` in `bootstrap()`, `supabaseClientProvider` | done |
| [[sprints/auth/AUTH-02-auth-repository\|AUTH-02]] | `AppUser`, `AuthRepository`, Supabase implementation returning `Result` | done |
| [[sprints/auth/AUTH-03-auth-state\|AUTH-03]] | `authStateProvider` stream, `currentUserProvider` | done |
| [[sprints/auth/AUTH-04-email-password-screens\|AUTH-04]] | Sign in, sign up, forgot password; inline validation | in_progress |
| AUTH-05 | Google sign-in: provider config, SHA-1s, iOS client ID, deep links | backlog |
| [[sprints/auth/AUTH-06-router-gating\|AUTH-06]] | Router gating, splash while the session restores, sign-out | in_progress |
| AUTH-07 | Profile setup and edit: username uniqueness, display name, avatar, **language** | backlog |
| [[sprints/auth/AUTH-08-fakes-and-tests\|AUTH-08]] | Fake `AuthRepository`, redirect behaviour, form validation tests | in_progress |

## LIB — Personal library and rating

| Issue | Scope | Status |
|---|---|---|
| LIB-01 | Library domain: `LibraryEntry`, `MovieStatus`, the `CollectionRef` sealed type | backlog |
| LIB-02 | Supabase data source over `user_movies` and `set_library_entry` | backlog |
| LIB-03 | Status actions on the details screen: add, move, remove | backlog |
| LIB-04 | Rating picker, 0–10 half points, explicit clear | backlog |
| LIB-05 | Library tab: two sub-tabs, sorting, rated/unrated filter, empty states | backlog |
| LIB-06 | Your score beside the TMDb score on the details screen | backlog |
| LIB-07 | Optimistic writes with rollback and a failure snackbar | backlog |
| LIB-08 | Fake repository; status and rating constraint behaviours | backlog |

## LST — Custom and shared lists

| Issue | Scope | Status |
|---|---|---|
| LST-01 | Lists domain, repository, Supabase implementation | backlog |
| LST-02 | Lists tab: mine, shared with me, pending invites badge | backlog |
| LST-03 | Create and edit: name, description, cover upload with client-side resize | backlog |
| LST-04 | List detail via `get_list_items`: add from search, remove, reorder | backlog |
| LST-05 | Members: invite by username, invite inbox, accept, decline, leave, remove | backlog |
| LST-06 | Per-member rating row: avatar and score chips, "not watched yet" state | backlog |
| LST-07 | Delete a list: destructive confirmation, cascade behaviour | backlog |
| LST-08 | Fakes plus widget tests for the shared-rating row | backlog |

## MOV — Movie experience

| Issue | Scope | Status |
|---|---|---|
| MOV-01 | Details redesign: backdrop, genres, runtime, year, on the design system | backlog |
| MOV-02 | **Trailer**: `/movie/{id}/videos`, official YouTube trailer, graceful absence | backlog |
| MOV-03 | Cache write-through on every library and list add | backlog |
| MOV-04 | Search polish: pagination, skeletons, real no-results state, recent searches | backlog |
| MOV-05 | "In your lists" on the details screen | backlog |

## HOME — Recommendations

| Issue | Scope | Status |
|---|---|---|
| HOME-01 | Home scaffold: sectioned feed, horizontal carousels, loading and empty states | backlog |
| HOME-02 | Recommendation engine: seeds → fan-out → dedupe → exclude → rank (pure function) | backlog |
| HOME-03 | Cold start: `/trending/movie/week` when the user has no ratings | backlog |
| HOME-04 | Feed caching: in-memory TTL, invalidated on rating or list change | backlog |
| HOME-05 | Secondary rails: want-to-watch, recent shared-list additions | backlog |
| HOME-06 | Unit tests over the pure ranking function | backlog |

## REL — Release

| Issue | Scope | Status |
|---|---|---|
| REL-01 | App icon, splash, name | backlog |
| REL-02 | Dark mode and accessibility pass | backlog |
| REL-03 | Error, empty and offline state audit | backlog |
| REL-04 | Performance: image caching, list virtualization | backlog |
| REL-05 | Portfolio write-up and screenshots | backlog |
| REL-06 | Distribution to the two real users | backlog |

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Backlog created; DOC-02 … DOC-05 completed by the vault itself |
| 2026-10-22 | Header corrected from "66 issues" to "70" — the per-sprint tables always summed to 70, see [[_meta/discrepancies]]. BE-01, BE-02, BE-03 done, now with their own issue files |
| 2026-10-23 | AUTH-01, AUTH-02, AUTH-03 done, now with their own issue files |
| 2026-10-23 | AUTH-04, AUTH-06, AUTH-08 implemented, now with their own issue files — `in_progress`, pending your manual confirmation |
