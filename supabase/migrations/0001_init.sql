-- DateMate AI — Supabase schema

-- ---------------------------------------------------------------------
-- couples
-- ---------------------------------------------------------------------
create table if not exists public.couples (
  id              text primary key,
  code            text not null unique,
  foods           text[] not null default '{}',
  activities      text[] not null default '{}',
  locations       text[] not null default '{}',
  budget          numeric not null default 0,
  budget_currency text not null default 'PHP',
  updated_at      timestamptz not null default now()
);

create index if not exists couples_code_idx
  on public.couples (code);

-- ---------------------------------------------------------------------
-- profiles — one row per Supabase Auth user, created automatically
-- ---------------------------------------------------------------------
create table if not exists public.profiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  email      text not null,
  name       text not null default '',
  couple_id  text references public.couples (id) on delete set null,
  created_at timestamptz not null default now()
);

create index if not exists profiles_couple_id_idx
  on public.profiles (couple_id);

-- ---------------------------------------------------------------------
-- Auto-create a profile when a Supabase Auth user is created
-- ---------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, email, name)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'name', '')
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user();

-- ---------------------------------------------------------------------
-- bucket_items — each couple's saved / completed date ideas
-- ---------------------------------------------------------------------
create table if not exists public.bucket_items (
  id           text primary key,
  couple_id    text not null references public.couples (id) on delete cascade,
  name         text not null,
  category     text not null default 'Other',
  price        text not null default '',
  subtitle     text not null default '',
  added_by     uuid not null references auth.users (id),
  status       text not null default 'pending'
                 check (status in ('pending', 'done')),
  rating       numeric
                 check (rating is null or (rating >= 0 and rating <= 5)),
  note         text,
  completed_at timestamptz,
  image_url    text not null default '',
  created_at   timestamptz not null default now()
);

create index if not exists bucket_items_couple_id_idx
  on public.bucket_items (couple_id);

create index if not exists bucket_items_status_idx
  on public.bucket_items (couple_id, status);

-- ---------------------------------------------------------------------
-- favorites
-- ---------------------------------------------------------------------
create table if not exists public.favorites (
  couple_id     text not null references public.couples (id) on delete cascade,
  suggestion_id text not null,
  created_at    timestamptz not null default now(),
  primary key (couple_id, suggestion_id)
);

create index if not exists favorites_couple_id_idx
  on public.favorites (couple_id);

-- ---------------------------------------------------------------------
-- Enable Row Level Security
-- ---------------------------------------------------------------------
alter table public.couples enable row level security;
alter table public.profiles enable row level security;
alter table public.bucket_items enable row level security;
alter table public.favorites enable row level security;

-- ---------------------------------------------------------------------
-- Helper for policies that need the signed-in user's couple_id.
-- SECURITY DEFINER avoids recursively invoking the profiles SELECT policy.
-- ---------------------------------------------------------------------
create or replace function public.current_user_couple_id()
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select p.couple_id
  from public.profiles as p
  where p.id = (select auth.uid())
  limit 1;
$$;

revoke all on function public.current_user_couple_id()
  from public, anon, authenticated;

grant execute on function public.current_user_couple_id()
  to authenticated;

-- ---------------------------------------------------------------------
-- Recreate policies so this section can be rerun.
-- Wrapping the drops and creates in a transaction avoids leaving policies
-- dropped if a later policy statement fails.
-- ---------------------------------------------------------------------
begin;

drop policy if exists "profiles_select_self_or_partner" on public.profiles;
drop policy if exists "profiles_update_self" on public.profiles;
drop policy if exists "profiles_insert_self" on public.profiles;

drop policy if exists "couples_select_authenticated" on public.couples;
drop policy if exists "couples_insert_authenticated" on public.couples;
drop policy if exists "couples_update_members" on public.couples;

drop policy if exists "bucket_items_members_all" on public.bucket_items;
drop policy if exists "favorites_members_all" on public.favorites;

-- Profiles: users can read their own row and their partner's row.
create policy "profiles_select_self_or_partner"
  on public.profiles
  for select
  to authenticated
  using (
    id = (select auth.uid())
    or couple_id = (select public.current_user_couple_id())
  );

create policy "profiles_update_self"
  on public.profiles
  for update
  to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

create policy "profiles_insert_self"
  on public.profiles
  for insert
  to authenticated
  with check (id = (select auth.uid()));

-- Couples: preserve the original access behavior.
create policy "couples_select_authenticated"
  on public.couples
  for select
  to authenticated
  using (true);

create policy "couples_insert_authenticated"
  on public.couples
  for insert
  to authenticated
  with check (true);

create policy "couples_update_members"
  on public.couples
  for update
  to authenticated
  using (
    id = (select public.current_user_couple_id())
  )
  with check (
    id = (select public.current_user_couple_id())
  );

-- Bucket items: only members of the item's couple may read or write.
create policy "bucket_items_members_all"
  on public.bucket_items
  for all
  to authenticated
  using (
    couple_id = (select public.current_user_couple_id())
  )
  with check (
    couple_id = (select public.current_user_couple_id())
  );

-- Favorites: only members of the favorite's couple may read or write.
create policy "favorites_members_all"
  on public.favorites
  for all
  to authenticated
  using (
    couple_id = (select public.current_user_couple_id())
  )
  with check (
    couple_id = (select public.current_user_couple_id())
  );

commit;

-- ---------------------------------------------------------------------
-- join_couple — allows an authenticated user to join via a code.
-- ---------------------------------------------------------------------
create or replace function public.join_couple(target_code text)
returns public.couples
language plpgsql
security definer
set search_path = ''
as $$
declare
  found_couple public.couples;
  member_count integer;
begin
  if (select auth.uid()) is null then
    raise exception 'Authentication required.';
  end if;

  select c.*
  into found_couple
  from public.couples as c
  where c.code = upper(trim(target_code));

  if not found then
    raise exception 'No couple was found with that code.';
  end if;

  select count(*)::integer
  into member_count
  from public.profiles as p
  where p.couple_id = found_couple.id;

  if member_count >= 2
     and not exists (
       select 1
       from public.profiles as p
       where p.id = (select auth.uid())
         and p.couple_id = found_couple.id
     )
  then
    raise exception 'That couple already has two members.';
  end if;

  update public.profiles
  set couple_id = found_couple.id
  where id = (select auth.uid());

  return found_couple;
end;
$$;

revoke all on function public.join_couple(text)
  from public, anon, authenticated;

grant execute on function public.join_couple(text)
  to authenticated;

-- ---------------------------------------------------------------------
-- Realtime publication membership
-- ---------------------------------------------------------------------
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'couples'
  ) then
    alter publication supabase_realtime add table public.couples;
  end if;

  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'bucket_items'
  ) then
    alter publication supabase_realtime add table public.bucket_items;
  end if;
end;
$$;