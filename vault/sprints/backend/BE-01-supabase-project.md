---
title: Supabase project and CLI
sprint: backend
feature: —
milestone: mvp
status: done
started_at: 2026-10-22
finished_at: 2026-10-22
---

# BE-01 · Supabase project and CLI

## Goal

A real hosted Supabase project exists, a local Docker-based dev environment mirrors it, and `supabase/` holds the migration workflow every later BE issue builds on.

## Scope

- Layers: `supabase`
- Files: `supabase/config.toml`, `supabase/seed.sql`, `supabase/migrations/`, `.env`, `.env.example`
- Data: the three extensions every later table depends on — `pgcrypto`, `citext`, `pg_trgm`

## Checklist

- [x] Supabase account and organization confirmed (already existed)
- [x] New hosted project created via the dashboard (`apfdjgsqgzjbydepyyti`)
- [x] Supabase CLI available via `npx -y supabase <command>` — no scoop/choco on this machine, so it is never installed globally, always invoked through `npx`
- [x] `supabase init` → `supabase/config.toml`, `supabase/seed.sql`
- [x] `config.toml`: `auto_expose_new_tables = false` — no table is reachable through the Data API without an explicit `grant`, see [[architecture/security-model]]
- [x] Docker Desktop running, `supabase start` — local Postgres/Auth/Storage stack
- [x] `supabase login` (interactive OAuth — run by the user directly in their own terminal, not through a tool sandbox) and `supabase link --project-ref apfdjgsqgzjbydepyyti`
- [x] Migration `20261022223320_enable_extensions.sql`: `citext`, `pg_trgm` pinned to `public`; `pgcrypto` left alone (see Notes)
- [x] `.env` / `.env.example` gain `SUPABASE_URL` and `SUPABASE_ANON_KEY` (new-style `sb_publishable_...` key)
- [x] `supabase db push` — hosted project matches local migrations

## Test scenario

No manual device/UI step — verified entirely through the CLI and direct SQL.

1. `npx supabase migration list`
   - **Expected:** local and remote columns show the same three timestamps
   - **Result:** confirmed, `20261022223320` / `20261022223449` / `20261022223451` match on both sides after `db push`
2. `npx supabase db reset` (local)
   - **Expected:** replays all migrations clean from empty
   - **Result:** confirmed, no errors

## Dependencies

- **Blocked by:** nothing
- **Blocks:** BE-02, BE-03, and every later `BE-*`/`AUTH-*` issue

## Notes

- No scoop/choco on this Windows machine, and `supabase` is not in the winget registry — every CLI invocation in this project goes through `npx -y supabase <command>`. Documented in [[operations/local-setup]].
- `supabase login`'s automatic OAuth flow refuses to run in a non-TTY environment (`LoginMissingTokenError`). The user ran it in their own terminal; the resulting stored CLI credentials were then usable from tooling automatically since this is the user's real machine.
- `pgcrypto` is pre-installed by Supabase itself, in the `extensions` schema, before any user migration runs. `create extension if not exists pgcrypto with schema public` is a silent no-op against an already-installed extension — it does **not** move it. The migration omits the `with schema public` clause for `pgcrypto` rather than implying a placement that isn't real; a `security definer` function needing `gen_random_uuid()` must call `extensions.gen_random_uuid()` explicitly, since those functions run with `search_path = ''`.
- New-style Supabase API keys (`sb_publishable_...` / `sb_secret_...`) replace the legacy JWT anon/service_role keys. `.env` stores the publishable key. `supabase_flutter` 2.18.3 compatibility with the new key format is not yet verified — deferred to AUTH-01, the first issue that actually initializes the client.
- The service role / secret key is never stored anywhere in this repo or CI, per [[architecture/security-model]].

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-22 | issue created and closed together with BE-02/BE-03 (execution slot E09). Hosted project created, local Docker stack verified, CLI workflow established. No manual step |
| 2026-10-23 | Resolved in AUTH-01: `supabase_flutter` 2.18.3 works with the new-style key via the `publishableKey` parameter (`anonKey` is deprecated in favor of it, same key value) — see [[sprints/auth/AUTH-01-supabase-client]] |
