# mavie

Flutter app for two people to track films together: individual lists and scores, plus shared lists where both scores are visible. Portfolio project.

## The vault is the source of truth

Product intent, architecture, schema and decisions live in [`vault/`](vault/MOC.md), not in commit messages or chat history.

**Read [`vault/MOC.md`](vault/MOC.md) at the start of any session.** Then:

| You need | Read |
|---|---|
| What the app is and what the MVP includes | [`vault/product/mvp.md`](vault/product/mvp.md) |
| What to work on next | [`vault/sprints/execution-map.md`](vault/sprints/execution-map.md) |
| How the code is organised | [`vault/architecture/overview.md`](vault/architecture/overview.md) |
| The database schema | [`vault/architecture/data-model.md`](vault/architecture/data-model.md) |
| **Anything touching RLS or cross-user reads** | [`vault/architecture/security-model.md`](vault/architecture/security-model.md) |
| Why something is the way it is | [`vault/architecture/decisions/`](vault/architecture/decisions/index.md) |
| The state of a feature | `vault/features/<slug>/_overview.md` |
| Running the app, secrets | [`vault/operations/local-setup.md`](vault/operations/local-setup.md) |

## Vault maintenance rule

**Whenever you touch a feature** — new, refactor, bug fix — update its page at `vault/features/<slug>/_overview.md` in the same session. At minimum, add a row to its `## Maintenance` table with the date and a summary. The Maintenance table is **append-only**: add a line, never rewrite.

Which document for which change:

| Change | Where |
|---|---|
| A feature's behaviour changed | Rewrite `features/<slug>/_overview.md` to describe the **current state of the code**, plus a Maintenance row |
| Narrative of one specific change or bug | `vault/maintenance/`, from [`_template.md`](vault/maintenance/_template.md) |
| A non-obvious technical decision | A new ADR in `vault/architecture/decisions/` |
| Schema change | `architecture/data-model.md`, and `security-model.md` if policies moved |
| Doc disagrees with the code, or a bug found in passing | Append to [`vault/_meta/discrepancies.md`](vault/_meta/discrepancies.md) |
| Work interrupted between sessions | A handoff in `vault/handoffs/` |

Full conventions: [`vault/_meta/documentation-process.md`](vault/_meta/documentation-process.md).

**The code wins over the docs.** If a note contradicts the code, the note is the bug — fix it and log the divergence. Never invent: mark unknowns `> ⚠️ Verify:` rather than guessing.

## Ground rules

- **Conversation in Portuguese. Code, commits, docs and the vault in English.**
- **UI strings are localized**, PT and EN, chosen per user — the two real users run the app in different languages. Never hardcode a user-visible string.
- **No Claude attribution in commits.** No `Co-Authored-By`, no "generated with", no AI mentions anywhere in the message or PR body.
- Work on a branch, never directly on `main`. One PR per issue.
- Claude writes the implementation code and explains the reasoning as it goes.
- **Claude never marks an issue `done` on its own — ask first.**

## Working on an issue

1. Find it in [`vault/sprints/index.md`](vault/sprints/index.md); the order is [`execution-map.md`](vault/sprints/execution-map.md), **not** the sprint numbering.
2. On starting: set the issue's `status` and `started_at`.
3. On finishing: `status: done`, `finished_at`, a Maintenance row, the feature overview updated, and the checkbox ticked in `execution-map.md` with the counters recalculated.

Issues without their own file yet get one from [`vault/sprints/_issue-template.md`](vault/sprints/_issue-template.md).

## Stack

Flutter `^3.12.2` · Riverpod 3 with **manual providers, no codegen** · `dio` for TMDb · Supabase (Postgres, Auth, Storage, RLS) · `go_router` · `flutter_dotenv`.

Testing uses **hand-written fakes, no mocking package**. A fake drifting from its interface should be a compile error.

## Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

`.env` must exist before anything runs — `cp .env.example .env` and fill in the TMDb key.
