---
title: Documentation process
status: active
last_review: 2026-10-21
---

# Documentation process

How this vault is written and kept honest. Read this before adding or editing any note.

## Principles

- **The vault is the cross-stack source of truth.** Product intent, architecture, schema and decisions live here, not in commit messages or chat history.
- **Code wins over docs.** If a note contradicts the code, the code is right and the note is a bug. Fix the note and log the divergence in [[_meta/discrepancies]].
- **Never invent.** If something is unclear in the code, mark it `> ⚠️ Verify: <question>` rather than guessing. An honest gap beats a confident fabrication.
- **Link, don't duplicate.** The schema lives in one place ([[architecture/data-model]]), the security model in one place ([[architecture/security-model]]). Everything else links to them.
- **Document in the same session as the change.** A feature touched without its note updated is an incomplete change.
- **English** for every note, every heading, every table.
- **Short and scannable.** Tables and lists over paragraphs. If a note needs scrolling three times, split it.

## File conventions

| Rule | Detail |
|---|---|
| Folders | lowercase, semantic, no numeric prefix. Meta folders prefixed `_` |
| Files | lowercase kebab-case |
| Features | `features/<slug>/_overview.md` — one folder per feature even when it holds one file |
| Issues | `sprints/<sprint>/<PREFIX>-NN-<slug>.md`, prefix matching the sprint |
| Maintenance notes | `maintenance/{fixes,features}/YYYY-MM-DD-<slug>.md` |
| Handoffs | `handoffs/YYYY-MM-<subject>.md` |
| ADRs | `architecture/decisions/NNNN-<slug>.md`, four digits, never renumbered |
| Dates | ISO `YYYY-MM-DD`, everywhere |

## Frontmatter

Every note carries YAML frontmatter with at least a `title`, a `status`, and a last-touched date.

```yaml
---
title: Shared lists
status: planned          # planned | in_progress | shipped | paused | archived
last_review: 2026-10-21
---
```

Issues use the richer tracking block in [[sprints/_issue-template]].

## Linking

- **Between notes:** wikilinks relative to the vault root — `[[architecture/data-model]]`, `[[features/library/_overview]]`. With an alias when the raw path reads badly: `[[architecture/security-model|the RLS model]]`.
- **To source code:** markdown links with a path relative to the note, and a line anchor when pointing at something specific. From `features/movie-search/_overview.md` that is `[movie_search_page.dart:42](../../../lib/presentation/pages/movie_search_page.dart#L42)`. Relative paths are what resolve in both Obsidian and the GitHub web view.
- Inside table cells, escape the pipe: `[[sprints/foundations/FND-02-feature-first-restructure\|FND-02]]`.

## The Maintenance section

Every feature overview and every issue ends with a `## Maintenance` block. It is **append-only** — add a line, never rewrite history.

```markdown
## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Feature documented retroactively from the shipped code |
```

This is the minimum obligation when touching a feature. Everything else in a note is optional; this line is not.

## Which document for which kind of change

| Situation | Where it goes |
|---|---|
| New feature, or a feature's behaviour changed | `features/<slug>/_overview.md` — rewrite it to describe the **current state of the code**, plus a Maintenance line |
| Narrative of one specific change or bug | `maintenance/fixes/` or `maintenance/features/` via [[maintenance/_template]] |
| Non-obvious technical decision | A new ADR in `architecture/decisions/` |
| Schema change | [[architecture/data-model]] **and** [[architecture/security-model]] if policies move |
| Doc disagrees with reality, or a bug found in passing | Append to [[_meta/discrepancies]] |
| Work interrupted between sessions | A handoff in `handoffs/` |

A feature overview describes **what is true now**. A maintenance note is **the story of one change**. They are not the same document — reference, don't duplicate.

## Issue lifecycle

`backlog → in_progress → in_review → done` (also `blocked`). On starting an issue, set `status` and `started_at`. On finishing, set `status: done`, `finished_at`, append a Maintenance row, and tick the checkbox in [[sprints/execution-map]], recalculating the progress counters.

**Claude never marks an issue `done` on its own — it asks first.**

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Process created, adapted from the sabe-jogar-monorepo vault |
