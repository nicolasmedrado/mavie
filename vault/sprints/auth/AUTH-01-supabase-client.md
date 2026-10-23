---
title: Supabase client initialization
sprint: auth
feature: auth
milestone: mvp
status: done
started_at: 2026-10-23
finished_at: 2026-10-23
---

# AUTH-01 · Supabase client initialization

## Goal

The app holds one initialized `SupabaseClient`, ready before `runApp`, reachable from any provider via `supabaseClientProvider`.

## Scope

- Layers: `presentation` (bootstrap), `core`
- Files: `lib/app/bootstrap.dart`, `lib/core/network/supabase_client.dart`

## Checklist

- [x] `bootstrap()` calls `Supabase.initialize(url: ..., publishableKey: ...)` from `.env`, after `dotenv.load()` and before `runApp`
- [x] `core/network/supabase_client.dart`: `supabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client)`
- [x] `flutter analyze` clean

## Test scenario

No manual step — nothing user-visible changes yet (no screen reads the client). `flutter analyze`/`flutter test` cover it; the first real exercise of the client is AUTH-02's repository.

## Dependencies

- **Blocked by:** BE-01 (the hosted project and keys it initializes against)
- **Blocks:** AUTH-02, AUTH-03

## Notes

- Used `publishableKey`, not `anonKey` — `supabase_flutter` 2.18.3 flags `anonKey` as deprecated in favor of `publishableKey`, which is the parameter name that matches the new-style `sb_publishable_...` key format `.env` already stores (set up in BE-01). This resolves the compatibility question BE-01 left open.
- `supabaseClientProvider` reads `Supabase.instance.client` rather than constructing its own `SupabaseClient` — `bootstrap()` already created the one true instance, so the provider is a thin accessor, not a second initialization path.

## Maintenance

| Date | Summary |
|------|---------|
| 2026-10-23 | issue created and closed together with AUTH-02/AUTH-03 (execution slot E10). No manual step |
