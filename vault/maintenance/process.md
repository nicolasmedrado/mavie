---
title: Maintenance process
status: active
last_review: 2026-10-21
---

# Maintenance process

A maintenance note is the **narrative of one specific change** — a bug and its fix, or a feature's analysis before it is built. It is not the same thing as a feature overview, which describes the current state of the code.

Do not duplicate. Reference.

## When to create one

- A bug is found and will not be fixed in the next five minutes.
- A change needs analysis before implementation — affected layers, risks, open questions.
- Nicolas says "document a fix for X".

A change that fits inside an existing issue in [[sprints/index]] belongs in that issue's Notes section, not here.

## Where

| Kind | Path |
|---|---|
| Bug fix | `maintenance/fixes/YYYY-MM-DD-<slug>.md` |
| Feature analysis | `maintenance/features/YYYY-MM-DD-<slug>.md` |

Start from [[maintenance/_template]].

## Lifecycle

`pending → in_progress → done` (also `cancelled`).

**Claude never sets `done` on its own — it asks first.** A change is finished when the person who will live with it says so, not when the code compiles.

## On finishing

1. Set `status: done` and `updated_at`.
2. Update the relevant `features/<slug>/_overview.md` so it describes the new reality, and append a Maintenance row there.
3. If the change revealed a doc-versus-reality divergence, append to [[_meta/discrepancies]].
4. If a lasting non-obvious decision was made, write an ADR instead of burying it in the note.

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Process created, adapted from the sabe-jogar-monorepo vault |
