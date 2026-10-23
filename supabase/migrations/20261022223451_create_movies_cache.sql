-- TMDb metadata mirrored server-side so list queries return titles and
-- posters without N round trips. See architecture/decisions/0006-mirror-tmdb-metadata.md
-- and architecture/data-model.md.
create table public.movies_cache (
  tmdb_id integer primary key,
  title text not null,
  original_title text,
  overview text,
  poster_path text,
  backdrop_path text,
  release_date date,
  runtime_minutes integer,
  genres text[] not null default '{}',
  tmdb_vote_average numeric(3, 1),
  trailer_youtube_key text,
  fetched_at timestamptz not null default now(),
  constraint runtime_minutes_positive check (runtime_minutes is null or runtime_minutes > 0),
  constraint tmdb_vote_average_range check (
    tmdb_vote_average is null or (tmdb_vote_average >= 0 and tmdb_vote_average <= 10)
  )
);

create index movies_cache_title_trgm_idx on public.movies_cache using gin (title gin_trgm_ops);
create index movies_cache_stale_idx on public.movies_cache (fetched_at);

alter table public.movies_cache enable row level security;

-- No write policies at all. It is a shared global cache - a bad client
-- write would corrupt titles and posters for every user. Writes happen
-- only inside definer RPCs (set_library_entry, add_to_list,
-- refresh_movie_cache - BE-07) that validate the payload shape.
create policy "movies_cache_select_authenticated" on public.movies_cache
  for select
  using (auth.role() = 'authenticated');

-- RLS filters rows; this grants the privilege to attempt the operation at
-- all (auto_expose_new_tables is off). No insert/update/delete: writes
-- only happen inside definer RPCs (BE-07), which run as the function
-- owner and so bypass grants entirely.
grant select on public.movies_cache to authenticated;
