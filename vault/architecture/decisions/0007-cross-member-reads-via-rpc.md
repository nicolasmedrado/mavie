---
title: Cross-member rating reads via a definer RPC
status: accepted
date: 2026-10-21
---

# 0007 — Cross-member rating reads via a definer RPC

## Context

A shared list shows what each member scored each film. Those ratings live in `user_movies`, which is private. Some cross-user read must be allowed; the question is how narrow it can be.

## Decision

`user_movies` RLS stays strictly `user_id = auth.uid()` for all four commands. **Every** cross-user read goes through one `security definer` function, `get_list_items(p_list_id)`, which authorizes once via `is_list_member` and returns, per item, the ratings of accepted members of that one list.

## Alternatives considered

**A cross-user `select` policy on `user_movies`**, allowing reads where the film is co-present in a shared list. Correctly scoped, wrong shape:

1. **Push-based leak.** The readable surface is controlled by a *write* either member can perform. Add a thousand films to a shared list and you can harvest a thousand of the other person's ratings for films they never meant to surface. A read permission granted by someone else's write is not a permission model.
2. **Non-local security.** Reading the policy no longer tells you who can see a row; you must also reason about `list_items` and `list_members`.
3. It runs on every row of every query against `user_movies`, including your own library screen.

**A `security definer` view.** A view cannot take a parameter, so it would derive scope from `auth.uid()` alone and then be queryable with arbitrary `where` clauses — back to problem (1). A function with a parameter and a guard clause is the narrower primitive.

## Consequences

- `user_movies`'s policy is one predicate, auditable at a glance.
- The client cannot enumerate: `get_list_items` takes no `user_id` and no `tmdb_id`.
- Exposure is bounded by construction, not by predicate.
- One place to audit, and one place to add per-rating visibility later — a single column plus a single `AND`, rather than a policy rewrite across four tables.
- **Realtime cannot deliver another member's rating**, because it respects table RLS. Accepted in [[architecture/decisions/0013-no-realtime-in-mvp]].
- Every definer function must `set search_path = ''`, be schema-qualified, have execute revoked from `public`, and perform its own authorization as its first statement.
- Proven by `supabase/tests/rls_test.sql` (BE-12) — with two trusted users, nothing else will catch a regression.

Full reasoning: [[architecture/security-model]].
