---
# ── Tracking (fill in and keep current while working) ──────────────
title: <short issue title>
sprint: <sprint-name>          # sprint by FUNCTIONALITY, not by date
feature: <feature-slug>        # points at vault/features/<slug>/_overview.md
milestone: mvp                 # mvp | post-mvp
status: backlog                # backlog | in_progress | in_review | done | blocked
started_at:                    # YYYY-MM-DD
finished_at:                   # YYYY-MM-DD
---

# <CODE> · <Title>

## Goal

One or two sentences: what is true after this issue that is not true now.

## Scope

- Layers: `domain` / `data` / `presentation` / `supabase`
- Files: <paths this issue is expected to touch>
- Data: <tables, columns, RPCs>

## Checklist

- [ ] ...

## Test scenario

How to verify this by hand after implementing it.

1. ...
   - **Expected:** ...

## Dependencies

- **Blocked by:** <issue codes that must be done first>
- **Blocks:** <issue codes waiting on this>

## Notes

Decisions taken while working, surprises, anything a future reader needs. If a decision is non-obvious and lasting, it belongs in an ADR instead — link it from here.

## Maintenance

| Date | Summary |
|------|---------|
| YYYY-MM-DD | issue created |
