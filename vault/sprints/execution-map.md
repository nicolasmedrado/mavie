---
title: Execution map
status: active
last_review: 2026-10-21
---

# Execution map

**The order to actually work in.** Sprint numbering in [[sprints/index]] is a grouping, not a sequence — this page is the sequence.

## How to track progress

- Each step has a code (`E01`, `E02`, …) and a checkbox.
- When an issue finishes, tick it here, update its row in [[sprints/index]], and recalculate the phase and overall counters by hand.
- `Overall = done / 66`.

**Overall: 14% (9/66)** · **Phase 0: 67% (4/6)** · **Phase 1: 45% (5/11)**

---

## Phase 0 — Record the decisions · 67% (4/6)

Independent of everything. Done first so decisions are written as they are made, not reconstructed months later.

- [x] **E01** (`DOC-02`) Retire `vault/context.md`, redistribute its content
- [x] **E01** (`DOC-03`) Document the shipped search and details flow
- [x] **E01** (`DOC-04`) Data model and ER rationale
- [x] **E01** (`DOC-05`) ADR log, fourteen decisions
- [ ] (`DOC-01`) README rewrite — *better once the app looks like the product*
- [ ] (`DOC-06`) TMDb attribution screen — *needs a Settings/About screen to live in*

## Phase 1 — Foundations · 45% (5/11)

Everything here is cheap now and expensive later. **Do not start product features before this phase closes.**

- [x] **E02** (`FND-01`) Dependency cleanup
- [x] **E03** (`FND-02`) **Feature-first restructure** — nine files today, ~80 at MVP. The cost grows superlinearly; this is the single most time-sensitive issue in the project
- [x] **E04** (`FND-03`) CI pipeline — guards every refactor that follows, so it comes before the risky ones
- [x] **E05** (`FND-04`) Entity split and serialization ∥ (`FND-05`) `Result` and `AppFailure` — *independent of each other, both block UI work*
- [ ] **E06** (`FND-06`) Design system → (`FND-07`) Shared widgets — *sequential: the widgets consume the tokens* — *FND-06 done; FND-07 automated checks green, pending manual airplane-mode/cache check*
- [ ] **E07** (`FND-08` + `FND-09`) **l10n and test infrastructure, together** — l10n breaks three existing tests and the harness is the fix. Splitting them means migrating the tests twice
- [ ] **E08** (`FND-10`) go_router adoption — *needs E06 for shell chrome and E07 for localized titles.* **Blocks AUTH-06**
- [ ] (`FND-11`) Lint rules — *any time after E03*

## Phase 2 — Backend baseline and accounts · 0% (0/11)

- [ ] **E09** (`BE-01` → `BE-02` → `BE-03`) Supabase project, `profiles`, `movies_cache`
- [ ] **E10** (`AUTH-01` → `AUTH-02` → `AUTH-03`) Client, repository, auth state
- [ ] **E11** (`AUTH-04`, `AUTH-06`, `AUTH-08`) Email/password screens, router gating, tests

🎯 **Milestone 1 — you can sign in and the app knows who you are.**

## Phase 3 — The core loop · 0% (0/12)

The point of the product. After this phase, mavie is useful to its two users even with nothing else built.

- [ ] **E12** (`BE-04` → `BE-07` → `LIB-01` → `LIB-02`) Library table, write RPCs, `CollectionRef`, data layer
- [ ] **E13** (`LIB-03`, `LIB-04`, `LIB-06`, `LIB-07`) Status actions, rating picker, score comparison, optimistic writes
- [ ] **E14** (`LIB-05`, `MOV-01`, `MOV-03`) Library tab, details redesign, cache write-through

🎯 **Milestone 2 — save a film, watch it, rate it.**

## Phase 4 — Identity polish · 0% (0/3)

Deliberately *after* the core loop: Google configuration is slow, platform-specific and entirely non-Dart. It must not sit on the critical path.

- [ ] **E15** (`AUTH-05`) Google sign-in ∥ (`BE-11` → `AUTH-07`) Storage buckets, profile edit, avatar, **language selector**

## Phase 5 — Shared lists · 0% (0/13)

- [ ] **E16** (`BE-05` → `BE-06` → **`BE-12`**) Lists schema, definer predicates, **RLS proof script**
      — *BE-12 before any list UI. With two trusted users an RLS bug never surfaces on its own*
- [ ] **E17** (`BE-08`, `BE-09` → `LST-01` → `LST-02` → `LST-03` → `LST-04`) Read gateway, membership RPCs, lists UI
- [ ] **E18** (`LST-05` → `LST-06`) Members, invites, **per-member ratings**
- [ ] (`LST-07`) Delete a list

🎯 **Milestone 3 — the headline feature: a shared list showing both scores.**

## Phase 6 — Discovery · 0% (0/9)

- [ ] **E19** (`BE-10` → `HOME-01` → `HOME-02` → `HOME-03` → `HOME-06`) Seeds, feed, ranking, cold start, tests
      — *needs real ratings from E13; with no ratings there is nothing to seed from*
- [ ] **E20** (`MOV-02`, `MOV-04`, `MOV-05`, `HOME-04`, `HOME-05`) Trailer and polish

## Phase 7 — Close out · 0% (0/8)

- [ ] **E21** (`LIB-08`, `LST-08`, `DOC-01`, `DOC-06`) Test backfill and documentation
- [ ] **E22** (`REL-01` … `REL-06`) Release

---

## Parallel lanes

When something blocks, pull from here instead of idling:

| Lane | Why it is unblocked |
|---|---|
| `DOC-*` | No dependencies, any slot |
| `MOV-01`, `MOV-02`, `MOV-04` | **Pure TMDb, zero Supabase.** The lane to use whenever backend or Google configuration stalls |
| `HOME-02` + `HOME-06` | A pure ranking function and its tests — writable before the home UI exists |
| `FND-04` ∥ `FND-05` | Independent of each other |
| `AUTH-05`, `AUTH-07` ∥ `LIB-*` | After E12 |

## Hard blockers, worth memorizing

| Before | Must come after |
|---|---|
| anything | `FND-02` — restructure cost grows with the file count |
| any new UI | `FND-08` — otherwise strings get retrofitted across twenty files |
| `AUTH-06` | `FND-10` |
| `AUTH-02` | `BE-02` |
| `LIB-02` | `BE-04` |
| `LST-02` | `BE-06` **and `BE-12`** |
| `HOME-02` | `LIB-04` — no ratings, no seeds |

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-21 | Map created; Phase 0 documentation issues ticked as the vault was written |
| 2026-10-21 | E02 (FND-01) ticked: Hive removed, Supabase/l10n/image-cache deps added |
| 2026-10-21 | E03 (FND-02) ticked: manual check confirmed on a physical Android device |
| 2026-10-21 | E04 (FND-03) ticked: live CI run green, branch protection applied on `main`. First block of Phase 1 (FND-01→03) closed |
| 2026-10-21 | FND-04 done (entity split); E05 stays unticked until FND-05 also lands |
| 2026-10-21 | FND-05 done (`AppFailure`/`Result`/`failure_mapper`); E05 ticked — both halves closed |
| 2026-10-21 | FND-06 tokens + theme landed, automated checks green; E06 left unticked pending the manual light/dark check |
| 2026-10-21 | FND-06 manual check confirmed; E06 stays unticked until FND-07 also lands |
| 2026-10-21 | FND-07 widgets landed, automated checks green; E06 left unticked pending the manual airplane-mode/cache check |
