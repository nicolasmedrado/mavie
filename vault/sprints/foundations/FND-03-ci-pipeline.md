---
title: CI pipeline
sprint: foundations
feature: —
milestone: mvp
status: done
started_at: 2026-10-21
finished_at: 2026-10-21
---

# FND-03 · CI pipeline

## Goal

Every push and pull request is formatted, analyzed and tested automatically. The repository has no `.github/` at all today.

Scheduled early, before the risky refactors — CI is what makes the rest of the foundations sprint safe to do.

## Scope

- Files: `.github/workflows/ci.yml`
- GitHub branch protection on `main`

```yaml
# shape, not final content
- flutter pub get
- dart format --output=none --set-exit-if-changed .
- flutter analyze --fatal-infos
- flutter test --coverage
```

### The `.env` problem

`.env` is a declared Flutter asset and is git-ignored, so `flutter test` fails in CI with a missing-asset error. Create it in the workflow from `.env.example` — the tests never make real network calls, so a placeholder key is enough:

```yaml
- run: cp .env.example .env
```

That is also a useful property to preserve: **no test should ever need a real API key.**

## Checklist

- [x] `ci.yml` running on push to `main` and on every pull request
- [x] `subosito/flutter-action` pinned to the project's SDK version (3.47.5, stable)
- [x] `cp .env.example .env` before the test step
- [x] Cache `~/.pub-cache`
- [x] Upload the coverage artifact (no threshold gate yet — current coverage is partial and a failing gate on day one just gets disabled)
- [x] Branch protection on `main`: require the check, no direct pushes — `required_status_checks: ["test"]` (strict), `required_pull_request_reviews` with 0 required approvals (solo project), `enforce_admins: false`
- [x] Add a CI badge to the README

## Test scenario

All three steps ran locally with the exact commands the workflow uses (`dart format --output=none --set-exit-if-changed .`, `flutter analyze --fatal-infos`, `flutter test --coverage`) — all green.

1. Open a pull request with a deliberately badly formatted file
   - **Expected:** the format step fails and the PR is blocked
   - Not exercised — no throwaway PR opened for this
2. Open a pull request with a failing test
   - **Expected:** the test step fails
   - Not exercised — no throwaway PR opened for this
3. Push a clean branch
   - **Expected:** all three steps green in under ~3 minutes
   - **Result:** PR #10's check and the resulting push-to-`main` run both completed `success` in 1m50s ([run 39692588456](https://github.com/nicolasmedrado/mavie/actions/runs/39692588456))

## Dependencies

- **Blocked by:** FND-02 (otherwise CI is set up against a structure about to change)
- **Blocks:** nothing, but guards everything after it

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | issue created |
| 2026-10-21 | `.github/workflows/ci.yml` added, CI badge added to README. Branch protection and the live on-GitHub gate verification left for the user |
| 2026-10-21 | Live run confirmed green on GitHub (run 39692588456, 1m50s). Branch protection on `main` still pending |
| 2026-10-21 | Branch protection applied on `main` via `gh api`: requires the `test` check, blocks direct pushes. Issue closed |
