---
title: mavie — Map of Content
status: active
last_review: 2026-10-21
---

# MOC — mavie

> An app for **two people to track films together**: each with their own lists and their own scores, plus shared lists where both scores are visible. Also a portfolio piece — the goal is a real app two real users actually use.
>
> **Current phase:** MVP specified, foundations not yet started. Resume at [[handoffs/2026-10-vault-bootstrap]].

## Start here

- [[product/mvp]] — **what we are building and why**. Read this first
- [[sprints/execution-map]] — **the order to work in**. Read this second
- [[_meta/documentation-process]] — how to keep this vault honest

## Product

- [[product/mvp]] — scope, core loop, product rules, screens
- [[product/post-mvp]] — what was deliberately excluded, and the accepted technical debt

## Architecture

- [[architecture/overview]] — layers, the feature-first rule, provider graph, error handling, testing
- [[architecture/data-model]] — the Postgres schema, table by table
- [[architecture/security-model]] — **RLS and the cross-member read gateway. The hardest part of the app**
- [[architecture/tmdb-integration]] — endpoints, metadata caching, the API key risk, attribution
- [[architecture/decisions/index]] — fourteen ADRs

## Features

Shipped:

- [[features/movie-search/_overview]] — title search, debounced, against TMDb
- [[features/movie-details/_overview]] — one film's screen

Specified, not built:

- [[features/auth/_overview]] — accounts, profiles, route gating
- [[features/library/_overview]] — the two system lists and your score. **The core loop**
- [[features/lists/_overview]] — custom and shared lists. **The headline feature**
- [[features/home-recommendations/_overview]] — discovery seeded by your ratings
- [[features/localization/_overview]] — PT and EN, chosen per user

## Execution

- [[sprints/index]] — 66 issues across 9 functional sprints
- [[sprints/execution-map]] — E01 → E22 with dependencies and progress
- [[sprints/_issue-template]]

## Maintenance and operations

- [[maintenance/process]] — when a change gets its own note
- [[operations/local-setup]] — running the app, secrets, Supabase CLI
- [[_meta/discrepancies]] — append-only log of doc-versus-reality divergences

## Handoffs

- [[handoffs/2026-10-vault-bootstrap]] — **active**

## Stack

| Layer | Choice |
|---|---|
| App | Flutter, Dart `^3.12.2` |
| State | Riverpod 3, manual providers, no codegen |
| HTTP | `dio` |
| Routing | `go_router` — declared, adopted in FND-10 |
| Backend | Supabase: Postgres, Auth, Storage, RLS |
| Film data | TMDb API v3 |
| Secrets | `flutter_dotenv` + a git-ignored `.env` |
| l10n | `flutter_localizations` + ARB, PT and EN |

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Vault created; replaces the retired `vault/context.md` |
