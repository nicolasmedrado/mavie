---
title: Decision log
status: active
last_review: 2026-10-21
---

# Decision log

Lightweight ADRs. One file per non-obvious technical decision, numbered sequentially and **never renumbered**. Superseded decisions stay in place with `status: superseded` and a link forward — the record of why something changed is worth more than a tidy list.

Template: [[maintenance/_template]] is for change narratives; an ADR uses `## Context` → `## Decision` → `## Alternatives considered` → `## Consequences`.

| # | Decision | Status |
|---|---|---|
| [[architecture/decisions/0001-feature-first-modules\|0001]] | Feature-first module layout | accepted |
| [[architecture/decisions/0002-riverpod-without-codegen\|0002]] | Riverpod with manual providers, no code generation | accepted |
| [[architecture/decisions/0003-supabase-over-firebase\|0003]] | Supabase over Firebase | accepted |
| [[architecture/decisions/0004-global-ratings\|0004]] | Ratings are global per (user, film), never per list | accepted |
| [[architecture/decisions/0005-system-lists-as-status\|0005]] | System lists are a status column, not rows in `lists` | accepted |
| [[architecture/decisions/0006-mirror-tmdb-metadata\|0006]] | Mirror TMDb metadata in `movies_cache` | accepted |
| [[architecture/decisions/0007-cross-member-reads-via-rpc\|0007]] | Cross-member rating reads via a definer RPC | accepted |
| [[architecture/decisions/0008-drop-hive\|0008]] | Drop Hive; no offline persistence in the MVP | accepted |
| [[architecture/decisions/0009-result-for-commands\|0009]] | `Result` for commands, thrown `AppFailure` for queries | accepted |
| [[architecture/decisions/0010-go-router-declarative-auth\|0010]] | go_router with a declarative auth redirect | accepted |
| [[architecture/decisions/0011-l10n-per-user-locale\|0011]] | Localization with a per-user locale | accepted |
| [[architecture/decisions/0012-tmdb-key-in-client\|0012]] | TMDb key ships in the client — accepted risk | accepted |
| [[architecture/decisions/0013-no-realtime-in-mvp\|0013]] | No Realtime in the MVP | accepted |
| [[architecture/decisions/0014-hand-rolled-fakes\|0014]] | Hand-written fakes over a mocking package | accepted |

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Log created with the fourteen decisions behind the MVP |
