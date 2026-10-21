---
title: Ratings are global per (user, film), never per list
status: accepted
date: 2026-10-21
---

# 0004 — Ratings are global per (user, film), never per list

## Context

Films appear in several places at once: your *Watched* list, a shared list with your partner, possibly a themed list. If each person scores each film, where does that score live — on the film, or on the film-inside-that-list?

## Decision

A rating belongs to **(user, film)**. One row in `user_movies`, visible everywhere that film appears. There is no per-list rating.

## Alternatives considered

**Per-list ratings.** Rejected — three defects appear immediately:

1. The details screen cannot answer "what did I rate this?" when the film is in four lists. Any tiebreak you invent *is* a global rating, just implicit and worse.
2. Adding an already-rated film to a new shared list would show it unrated, forcing a re-rate.
3. Recommendations seed from "my highly-rated films" and would have to collapse the per-list scores into one number anyway.

Cases that look like they need per-list ratings, and what they actually are:

| Looks like | Actually is | Resolution |
|---|---|---|
| "my top 10 horror, ranked" | ordering, not scoring | `list_items.sort_order` |
| "how was movie night?" | a dated rewatch entry | a `watch_log`, post-MVP |
| "we rated it together, as a couple" | a list-owned score | rejected — the product shows *each* person's score |
| "visible in one list, hidden in another" | per-rating visibility | real, deferred, kept cheap by [[architecture/decisions/0007-cross-member-reads-via-rpc]] |

Only the first is an MVP need, and a sort column solves it.

## Consequences

- `user_movies` has `primary key (user_id, tmdb_id)` and holds `rating`.
- A shared list renders scores by joining its items to the `user_movies` rows of its accepted members — the query that [[architecture/security-model]] is built around.
- Rating a film from inside a shared list also updates your personal library. That is intended, and the UI should not pretend otherwise.
- Adding a rewatch diary later does not invalidate this: `user_movies.rating` stays canonical and the log sits beside it.
