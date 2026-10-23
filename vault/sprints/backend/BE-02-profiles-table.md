---
title: profiles table
sprint: backend
feature: auth
milestone: mvp
status: done
started_at: 2026-10-22
finished_at: 2026-10-22
---

# BE-02 · `profiles` table

## Goal

Every `auth.users` row gets a matching `profiles` row automatically, readable and updatable only by its owner, with the columns [[features/auth/_overview]] needs (username, display name, avatar, locale).

## Scope

- Layers: `supabase`
- Files: `supabase/migrations/20261022223449_create_profiles.sql`
- Data: `public.profiles`, `set_updated_at()`, `handle_new_user()`, triggers `set_profiles_updated_at` and `on_auth_user_created`, policies `profiles_select_self` / `profiles_update_self`

## Checklist

- [x] `profiles` table: `id` references `auth.users(id) on delete cascade`, `username citext unique`, `display_name`, `avatar_path`, `locale default 'pt-BR'`, `created_at`/`updated_at`
- [x] Constraints: `username_format` (`^[a-z0-9_]{3,24}$`), `display_name_length` (1–60), `locale_supported` (`pt-BR` or `en`)
- [x] Generic `set_updated_at()` trigger function, reusable by any future table with the column
- [x] `handle_new_user()` trigger on `auth.users` — provisions a `profiles` row on signup, deriving a provisional username from the email local part, de-duplicated with a numeric suffix
- [x] `handle_new_user()` is `security definer`, `set search_path = ''`, schema-qualified, `revoke execute from public` — the four non-negotiable rules in [[architecture/security-model]]
- [x] RLS enabled; `profiles_select_self` and `profiles_update_self`, both `using (id = auth.uid())`
- [x] `grant select, update on public.profiles to authenticated` — required because `auto_expose_new_tables = false` (see BE-01 Notes)
- [x] No insert/delete policy or grant: the trigger owns creation, the `auth.users` cascade owns deletion

## Test scenario

No manual device/UI step — verified against the local Dockerized Postgres via direct `psql`, simulating `auth.uid()`/`auth.role()` with `set local role authenticated; set local request.jwt.claim.sub = '<uuid>'` inside `begin; ... rollback;` blocks.

1. Insert a row into `auth.users`
   - **Expected:** `handle_new_user()` fires, a matching `profiles` row appears with a username derived from the email
   - **Result:** confirmed; a second insert with a colliding local part got the `1` suffix as designed
2. Update `profiles.display_name` (update any column) as the owning user
   - **Expected:** succeeds, `updated_at` bumps
   - **Result:** confirmed
3. Select another user's `profiles` row as an authenticated-but-different user
   - **Expected:** zero rows (RLS filters it out)
   - **Result:** confirmed
4. Select `profiles` as the `anon` role
   - **Expected:** `permission denied` — no grant to `anon` at all
   - **Result:** confirmed
5. Update another user's row
   - **Expected:** zero rows affected
   - **Result:** confirmed

## Dependencies

- **Blocked by:** BE-01
- **Blocks:** AUTH-02 (per [[sprints/execution-map]]'s hard-blocker table), [[features/auth/_overview]]

## Notes

- Found and fixed during implementation: RLS policies alone were **not** sufficient. With `auto_expose_new_tables = false`, querying `profiles` as `authenticated` failed with `permission denied for table profiles` even with correct policies in place, because RLS only filters rows *after* table-level privilege is confirmed. Fixed by adding the explicit `grant select, update ... to authenticated`. This is a pattern every later `BE-*` table migration needs to repeat — logged here as the canonical reference.
- A blanket `select` policy was deliberately rejected — it would hand every username and avatar to anyone holding the anon key. Cross-user lookup goes through `find_profile_by_username` (BE-09) instead, which matches exactly and returns three columns.
- BE-06 will add a second permissive `select` policy (`using (shares_list_with(id))`) once `list_members` exists. Postgres ORs multiple permissive policies for the same command, so `profiles_select_self` needs no change then.

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-22 | issue created and closed together with BE-01/BE-03 (execution slot E09). Table, triggers and RLS verified by direct SQL: self-read, cross-user denial, anon denial, self-update vs. other-update, `updated_at` trigger. No manual step |
