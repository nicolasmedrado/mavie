---
title: CI pipeline
sprint: foundations
feature: —
milestone: mvp
status: backlog
started_at:
finished_at:
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

- [ ] `ci.yml` running on push to `main` and on every pull request
- [ ] `subosito/flutter-action` pinned to the project's SDK version
- [ ] `cp .env.example .env` before the test step
- [ ] Cache `~/.pub-cache`
- [ ] Upload the coverage artifact (no threshold gate yet — current coverage is partial and a failing gate on day one just gets disabled)
- [ ] Branch protection on `main`: require the check, no direct pushes
- [ ] Add a CI badge to the README

## Test scenario

1. Open a pull request with a deliberately badly formatted file
   - **Expected:** the format step fails and the PR is blocked
2. Open a pull request with a failing test
   - **Expected:** the test step fails
3. Push a clean branch
   - **Expected:** all three steps green in under ~3 minutes

## Dependencies

- **Blocked by:** FND-02 (otherwise CI is set up against a structure about to change)
- **Blocks:** nothing, but guards everything after it

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | issue created |
