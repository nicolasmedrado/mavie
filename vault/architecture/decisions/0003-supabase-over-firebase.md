---
title: Supabase over Firebase
status: accepted
date: 2026-10-21
---

# 0003 — Supabase over Firebase

## Context

Shared lists need both phones to see the same data, which means accounts and a backend. Four options were on the table: Firebase, Supabase, our own API, or staying local-only and dropping sharing from the MVP.

The data is strongly relational. A list has many members and many films; each film-in-a-list has many ratings, one per member. The central query is "for every film in this list, what did each member score it".

## Decision

**Supabase** — Postgres, Auth, Storage, Row Level Security.

## Alternatives considered

- **Firebase.** The most mature Flutter SDK and no project-pausing. But the central query becomes manual denormalisation or subcollection fan-out, and expressing "only accepted members of this list" in security rules is markedly more verbose than the equivalent RLS. The relational shape of the data is the deciding factor.
- **Our own API** (NestJS/FastAPI + Postgres). Full control and a full-stack portfolio story, but it at least doubles the MVP — auth, deploy, migrations, a second repository. Only worth it if backend were also a portfolio target, which it is not here.
- **Local-only with Hive, sync later.** Ships fastest and defers the decision, but shared lists are the point of the product. Deferring them defers the product.

## Consequences

- The central query is one join, inside one RPC. See [[architecture/security-model]].
- Authorisation lives in the database rather than in app code, which is both safer and a better portfolio artifact.
- Storage covers avatars and list covers without a second service.
- **Free-tier projects pause after 7 days of inactivity** — the "recruiter opens it and nothing works" failure mode. Mitigation: a scheduled ping or an explicit cold-start state.
- RLS has sharp edges — policy recursion, `search_path` escalation — documented in [[architecture/security-model]] and proven by the BE-12 test script.
- Postgres is also the natural home for the `movies_cache` mirror, which the list screen depends on.
