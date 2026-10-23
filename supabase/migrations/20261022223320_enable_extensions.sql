-- Extensions the schema depends on — see architecture/data-model.md.
-- pgcrypto:  gen_random_uuid(), used as the default for every uuid PK.
-- citext:    case-insensitive text, used for profiles.username.
-- pg_trgm:   trigram indexes, used for movies_cache title search.
--
-- citext and pg_trgm are pinned to the public schema explicitly: security
-- definer functions run with search_path = '', so every type/function they
-- touch must be reachable as public.<name>, not resolved implicitly.
-- pgcrypto is pre-installed by Supabase itself, in the extensions schema —
-- `with schema public` is a no-op against an already-installed extension,
-- so it is omitted here rather than implying a placement that isn't real.
-- A security definer function calling gen_random_uuid() needs to write
-- extensions.gen_random_uuid() explicitly; a plain table column default
-- does not, since it resolves via the session search_path (config.toml's
-- extra_search_path already includes "extensions").
create extension if not exists citext with schema public;
create extension if not exists pg_trgm with schema public;
