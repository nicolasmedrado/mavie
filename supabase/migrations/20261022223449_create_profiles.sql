-- Mirrors auth.users, which is not client-readable. See architecture/data-model.md.
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username citext not null unique,
  display_name text not null,
  avatar_path text,
  locale text not null default 'pt-BR',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint username_format check (username ~ '^[a-z0-9_]{3,24}$'),
  constraint display_name_length check (char_length(display_name) between 1 and 60),
  constraint locale_supported check (locale in ('pt-BR', 'en'))
);

-- Generic updated_at bridge - any table with the column can reuse this.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger set_profiles_updated_at
  before update on public.profiles
  for each row
  execute function public.set_updated_at();

-- Creates the row with a provisional username derived from the email local
-- part, de-duplicated with a numeric suffix. Clients never insert or delete
-- profiles directly: this trigger owns creation, the auth.users cascade
-- owns deletion.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_base_username text;
  v_username public.citext;
  v_suffix int := 0;
begin
  v_base_username := lower(regexp_replace(split_part(new.email, '@', 1), '[^a-z0-9_]', '_', 'g'));
  v_username := v_base_username;

  while exists (select 1 from public.profiles where username = v_username) loop
    v_suffix := v_suffix + 1;
    v_username := v_base_username || v_suffix::text;
  end loop;

  insert into public.profiles (id, username, display_name)
  values (new.id, v_username, coalesce(nullif(split_part(new.email, '@', 1), ''), 'User'));

  return new;
end;
$$;

revoke execute on function public.handle_new_user() from public;

create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user();

alter table public.profiles enable row level security;

-- A blanket read policy would hand every username and avatar to anyone
-- holding the anon key. Invite lookup goes through find_profile_by_username
-- (BE-09), which matches exactly and returns three columns.
--
-- BE-06 adds a second permissive SELECT policy (using shares_list_with(id))
-- once list_members exists - Postgres ORs multiple permissive policies for
-- the same command, so this one needs no change then.
create policy "profiles_select_self" on public.profiles
  for select
  using (id = auth.uid());

create policy "profiles_update_self" on public.profiles
  for update
  using (id = auth.uid());

-- RLS filters rows; this grants the privilege to attempt the operation at
-- all. Required because auto_expose_new_tables is off (both locally and on
-- the hosted project) - no table is reachable through the Data API without
-- an explicit grant. No insert/delete: the trigger owns creation, the
-- auth.users cascade owns deletion.
grant select, update on public.profiles to authenticated;
