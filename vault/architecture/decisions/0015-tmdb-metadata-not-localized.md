---
title: TMDb film metadata is not localized
status: accepted
date: 2026-10-21
---

# 0015 — TMDb film metadata is not localized

## Context

FND-08 left this open (`⚠️ Verify` in the issue and in [[features/localization/_overview]]): the UI itself is now per-user localized (PT/EN — [[architecture/decisions/0011-l10n-per-user-locale]]), but `GET /search/movie` and `GET /movie/{id}` never send TMDb's `language` parameter, so titles and synopses always come back in TMDb's default (English, in practice). Nicolas would see the chrome in English and the film data in English too; his girlfriend would see Portuguese chrome around English synopses.

## Decision

Do not send `language` and do not localize film metadata for the MVP. `movies_cache` stays one row per `tmdb_id`, as specified in [[architecture/data-model]].

## Alternatives considered

**Send `language` keyed to the requesting user's locale.** Gets a Portuguese synopsis for the Portuguese user. Rejected: `movies_cache` is a shared row keyed only by `tmdb_id` ([[architecture/decisions/0006-mirror-tmdb-metadata]]) — mirroring per-locale metadata needs either a composite `(tmdb_id, locale)` key or a second table, doubling the cache-write paths (`set_library_entry`, `add_to_list`, `refresh_movie_cache`) for a difference that is cosmetic (synopsis language) rather than functional (both users still see the same poster, score, runtime, genres).

**Fetch live in the request locale, cache only one canonical copy.** Avoids the schema change, but means two users opening the same film see different synopsis languages depending on who triggered the cache write — a confusing, silently-inconsistent shared state. Worse than being consistently in one language.

## Consequences

- Film titles and synopses are in whichever language TMDb returns by default, regardless of the viewing user's locale. UI chrome around them is still correctly localized.
- `movies_cache` stays simple — [[architecture/data-model]] is unaffected by this decision.
- Logged as accepted technical debt in [[product/post-mvp]], not as a bug.
- Revisit if either user actually reports confusion — cheap to send `language=pt-BR`/`language=en-US` per request even without caching it, as a quick partial fix, since the details screen already hits TMDb live on every open ([[architecture/decisions/0006-mirror-tmdb-metadata]]).
