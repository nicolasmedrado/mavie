---
title: MVP specification
status: in_progress
last_review: 2026-10-21
---

# MVP specification

## What mavie is

An app for **two people to track films together**. Each person keeps their own lists and gives their own scores; some lists are shared, and inside those each member sees what the other rated.

It doubles as a portfolio piece — the goal is a real app two real users actually use, not a demo. The two are the same goal: a product that is genuinely used is the one worth showing.

The current users are Nicolas and his girlfriend. Nothing in the design assumes exactly two people, but nothing is built for scale either.

## The core loop

1. **Discover** a film — search by title, or from the recommendations home.
2. **Save** it to *Want to watch*, or to a shared list ("films to watch together").
3. **Watch** it, move it to *Watched*.
4. **Rate** it 0–10. In a shared list both scores sit side by side.
5. Those ratings **feed the recommendations** that drive step 1 again.

Step 4 closing back into step 1 is the point of the product. Every MVP feature exists to make that loop turn.

## Scope

### In

| Area | What ships |
|---|---|
| Accounts | Email/password and Google sign-in; profile with username, display name, avatar, language |
| System lists | *Want to watch* and *Watched*, one pair per user |
| Rating | 0–10 with half points, one score per person per film |
| Custom lists | Playlist-like: rename, cover image, description, members, films |
| Shared lists | Invite by username, the invited person accepts, both see each other's ratings on watched films |
| Movie details | Poster, backdrop, synopsis, genres, runtime, year, TMDb score, **your score**, **trailer** |
| Search | By title, paginated, with proper empty and error states |
| Home | Recommendation carousels seeded from the films you rated highly |
| Languages | Portuguese and English, **chosen per user** — the two users will run the app in different languages at the same time |

### Out (and why)

See [[product/post-mvp]] for the full list with reasoning. The short version: no social graph beyond list membership, no public/anonymous list sharing, no offline mode, no rewatch diary, no TV series, no streaming-availability data.

## Product rules

These are the decisions that constrain the schema. Each one has an ADR.

**A rating belongs to a person and a film, not to a list.** If you rate Dune 8.5, that is true on your own profile and in every shared list containing it. Ranking *within* a list is ordering, not a second score — [[architecture/decisions/0004-global-ratings]].

**The two system lists are a status, not rows in a table of lists.** A film is *want to watch* or *watched*, never both — the exclusivity is structural, not enforced by app code. Custom lists are a separate, genuinely list-shaped thing — [[architecture/decisions/0005-system-lists-as-status]].

**Removing a film from *Watched* keeps your rating.** The film leaves the list; the score survives, including where other people can see it. Status becomes null — "not in a system list, but I have watched and judged this".

**`0` is a real rating; unrated is absent.** A score of zero means "this is terrible", which is different from "I haven't rated it". The rating control therefore needs an explicit *clear* action — dragging to zero must not mean unrated.

**Membership requires acceptance.** The owner invites, the invited person accepts. Until then they are not a member and their ratings are not exposed. Without that step anyone could add you to a list and start reading your scores for every film they put in it — [[architecture/security-model]].

**Only accepted members' ratings are visible, and only for films in that list.** Sharing a list is not sharing a library.

## Screens

| Screen | Content |
|---|---|
| Sign in / Sign up / Forgot password | Email+password, Google button |
| Home | Carousels: *Because you liked X*, *Trending* (cold start), *Want to watch* |
| Search | Debounced title search, paginated results |
| Movie details | Artwork, metadata, trailer, TMDb score vs. your score, status actions, "in your lists" |
| Library | Two tabs (*Want to watch* / *Watched*), sortable, filterable by rated/unrated |
| Lists | Your lists, lists shared with you, pending invites |
| List detail | Cover, description, members, films — each with every member's score |
| Create / edit list | Name, description, cover upload |
| Members | Invite by username, pending invites, leave, owner removes |
| Profile / Settings | Display name, avatar, **language**, sign out |

> ⚠️ Verify: the rating input affordance is still open — a slider snapped to 0.5 versus ten tappable half-stars. Decided in LIB-04.

## What exists today

Search and movie details, against TMDb, with no accounts and no persistence. See [[features/movie-search/_overview]] and [[features/movie-details/_overview]]. Everything else in this document is unbuilt — the order of construction is [[sprints/execution-map]].

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | MVP specified from scratch; product rules and scope fixed |
