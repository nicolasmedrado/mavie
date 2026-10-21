---
title: Vault bootstrap — where development resumes
created_at: 2026-10-21
status: active
---

# Handoff — 2026-10 · Vault bootstrap

## Where we stopped

PR #6 merged, so `main` has search and movie details working against TMDb: poster, title, synopsis, TMDb score, with tests.

This session did no product code. It specified the MVP and built this vault.

What was decided — all of it recorded, none of it built:

- The product is **two people with their own lists and their own scores**, plus shared playlist-style lists where both scores are visible. [[product/mvp]]
- Backend is **Supabase**, auth is email/password + Google, ratings are **0–10 in half points**, and lists are entered **by invitation with acceptance**.
- Ratings are **global per (user, film)**, never per list. The two system lists are a **status column**, not rows in `lists`.
- Reading another member's score goes through **one definer RPC**, never a cross-user RLS policy. [[architecture/security-model]]
- The UI gets **per-user localization** — the two real users want different languages against the same data.

Fourteen ADRs in [[architecture/decisions/index]]. Sixty-six issues in [[sprints/index]].

## Next step

[[sprints/execution-map]], Phase 1, in order:

1. **FND-01** — dependency cleanup. Remove the never-imported Hive, add Supabase and l10n.
2. **FND-02** — the feature-first restructure. Nine files today, ~80 at MVP. This is the most time-sensitive issue in the project.
3. **FND-03** — CI, so the rest of the foundations sprint is safe to do.

Do not start product features before Phase 1 closes. Everything in it is cheap now and expensive later.

## Open questions

| Question | Decide in |
|---|---|
| Rating input: a slider snapped to 0.5, or ten half-tappable stars? | LIB-04 |
| Should TMDb metadata follow the user's locale? It would need a per-locale `movies_cache`, which the current schema cannot hold | FND-08 |
| Coverage threshold in CI — deliberately not gated on day one | after FND-09 |

## Suggested prompt for the next session

```
Read vault/MOC.md, vault/sprints/execution-map.md and vault/sprints/foundations/FND-01-dependency-cleanup.md.
Then implement FND-01.
Follow the vault conventions in vault/_meta/documentation-process.md: update the issue's
status and Maintenance table, and tick the Hive rows in vault/_meta/discrepancies.md.
```

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Handoff created at the end of the vault bootstrap session |
