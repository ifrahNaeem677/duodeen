-- =====================================================================
-- DuoDeen V3 — run ONCE in Supabase → SQL Editor → New query → Run.
-- Keeps your existing profiles, pairs and daily_entries tables.
-- Creates: permanent_skills, messages, Storage bucket "snaps".
-- Safe to run more than once.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. Helper: my current pair id (used by security rules)
-- ---------------------------------------------------------------------
create or replace function public.duodeen_my_pair_id()
returns uuid language sql stable security definer set search_path = public as $$
  select pair_id from public.profiles where id = auth.uid();
$$;
grant execute on function public.duodeen_my_pair_id() to authenticated;

-- ---------------------------------------------------------------------
-- 1. daily_entries: new columns for V3 (existing data untouched)
-- ---------------------------------------------------------------------
alter table public.daily_entries add column if not exists read_book     boolean not null default false;
alter table public.daily_entries add column if not exists skill_done    boolean not null default false;
alter table public.daily_entries add column if not exists tasbeeh_count int     not null default 0;

-- Score V3 (runs after any older score trigger, so this one wins):
-- Prayers 25 + Quran 10 + Yaseen 5 + Azkar 5 + Goals 10 each (max 50)
-- + Sleep 7–8 h 5 + Read Book 10 + Work On My Skill 10  = 120
create or replace function public.duodeen_score_v3()
returns trigger language plpgsql as $$
declare
  s int := 0;
  g int := 0;
begin
  if new.fajr    then s := s + 5;  end if;
  if new.dhuhr   then s := s + 5;  end if;
  if new.asr     then s := s + 5;  end if;
  if new.maghrib then s := s + 5;  end if;
  if new.isha    then s := s + 5;  end if;
  if new.quran   then s := s + 10; end if;
  if new.yaseen  then s := s + 5;  end if;
  if new.azkar   then s := s + 5;  end if;
  if jsonb_typeof(new.goals) = 'array' then
    select count(*) into g from jsonb_array_elements(new.goals) e where (e ->> 'done') = 'true';
  end if;
  s := s + least(g, 5) * 10;
  if new.sleep_hours >= 7 and new.sleep_hours <= 8 then s := s + 5; end if;
  if new.read_book  then s := s + 10; end if;
  if new.skill_done then s := s + 10; end if;
  new.score := s;
  return new;
end $$;

drop trigger if exists zz_duodeen_score_v3 on public.daily_entries;
create trigger zz_duodeen_score_v3
  before insert or update on public.daily_entries
  for each row execute function public.duodeen_score_v3();

-- ---------------------------------------------------------------------
-- 2. permanent_skills (each user writes their OWN 60-day skill)
-- ---------------------------------------------------------------------
create table if not exists public.permanent_skills (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references auth.users(id) on delete cascade,
  pair_id         uuid,
  skill_name      text not null,
  daily_action    text not null default '',
  start_date      date not null default current_date,
  end_date        date not null default (current_date + 59),
  total_days      int  not null default 60,
  current_day     int  not null default 1,
  streak          int  not null default 0,
  last_done_date  date,
  is_active       boolean not null default true,
  created_at      timestamptz not null default now()
);

-- only ONE active skill per user
create unique index if not exists permanent_skills_one_active
  on public.permanent_skills (user_id) where is_active;

-- Lock the skill: cannot edit name/action/dates or stop it before 60 days end.
create or replace function public.duodeen_skill_guard()
returns trigger language plpgsql as $$
begin
  if tg_op = 'INSERT' then
    if new.start_date is null or abs(new.start_date - current_date) > 1 then
      new.start_date := current_date;
    end if;
    new.total_days  := 60;
    new.end_date    := new.start_date + 59;
    new.current_day := 1;
    new.streak      := 0;
    new.is_active   := true;
    new.last_done_date := null;
    return new;
  end if;

  if new.user_id     is distinct from old.user_id
     or new.skill_name   is distinct from old.skill_name
     or new.daily_action is distinct from old.daily_action
     or new.start_date   is distinct from old.start_date
     or new.end_date     is distinct from old.end_date
     or new.total_days   is distinct from old.total_days then
    raise exception 'Your skill cannot be edited until the 60 days are finished.';
  end if;

  if old.is_active and not new.is_active and current_date <= old.end_date then
    raise exception 'Your skill cannot be stopped until the 60 days are finished.';
  end if;
  return new;
end $$;

drop trigger if exists duodeen_skill_guard on public.permanent_skills;
create trigger duodeen_skill_guard
  before insert or update on public.permanent_skills
  for each row execute function public.duodeen_skill_guard();

alter table public.permanent_skills enable row level security;

drop policy if exists "skills: read own and partner" on public.permanent_skills;
create policy "skills: read own and partner" on public.permanent_skills
  for select to authenticated
  using (
    user_id = auth.uid()
    or user_id in (
      select id from public.profiles
      where pair_id is not null and pair_id = public.duodeen_my_pair_id()
    )
  );

drop policy if exists "skills: insert own" on public.permanent_skills;
create policy "skills: insert own" on public.permanent_skills
  for insert to authenticated
  with check (user_id = auth.uid());

drop policy if exists "skills: update own" on public.permanent_skills;
create policy "skills: update own" on public.permanent_skills
  for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
-- (no delete policy → skills cannot be deleted)

grant select, insert, update on public.permanent_skills to authenticated;

-- ---------------------------------------------------------------------
-- 3. messages (chat + snaps between paired partners only)
-- ---------------------------------------------------------------------
create table if not exists public.messages (
  id          uuid primary key default gen_random_uuid(),
  pair_id     uuid not null,
  sender_id   uuid not null references auth.users(id) on delete cascade,
  text        text not null default '',
  type        text not null default 'text',   -- 'text' or 'snap'
  image_url   text,
  created_at  timestamptz not null default now()
);
create index if not exists messages_pair_created_idx on public.messages (pair_id, created_at desc);

alter table public.messages enable row level security;

drop policy if exists "messages: read my pair" on public.messages;
create policy "messages: read my pair" on public.messages
  for select to authenticated
  using (pair_id = public.duodeen_my_pair_id());

drop policy if exists "messages: send in my pair" on public.messages;
create policy "messages: send in my pair" on public.messages
  for insert to authenticated
  with check (sender_id = auth.uid() and pair_id = public.duodeen_my_pair_id());

grant select, insert on public.messages to authenticated;

-- ---------------------------------------------------------------------
-- 4. Storage bucket "snaps" (public read, logged-in users can upload)
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('snaps', 'snaps', true)
on conflict (id) do update set public = true;

drop policy if exists "snaps: authenticated upload" on storage.objects;
create policy "snaps: authenticated upload" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'snaps');

drop policy if exists "snaps: authenticated read" on storage.objects;
create policy "snaps: authenticated read" on storage.objects
  for select to authenticated
  using (bucket_id = 'snaps');

-- ---------------------------------------------------------------------
-- 5. Pairing functions (safe server-side pairing; same as V2 fix.sql)
-- ---------------------------------------------------------------------
create or replace function public.pair_with_code(code text)
returns json language plpgsql security definer set search_path = public as $$
declare
  me_id    uuid := auth.uid();
  mine     public.profiles;
  friend   public.profiles;
  new_pair uuid;
begin
  if me_id is null then raise exception 'Please log in again.'; end if;
  select * into mine from public.profiles where id = me_id;
  if mine.pair_id is not null then raise exception 'You are already paired. Unpair first.'; end if;
  select * into friend from public.profiles where pair_code = upper(trim(code));
  if friend.id is null then raise exception 'Invalid Code'; end if;
  if friend.id = me_id then raise exception 'That is your own code'; end if;
  if friend.pair_id is not null then raise exception 'Your friend is already paired with someone else.'; end if;

  insert into public.pairs (user1_id, user2_id) values (me_id, friend.id) returning id into new_pair;
  update public.profiles set pair_id = new_pair where id in (me_id, friend.id);
  update public.daily_entries set pair_id = new_pair
    where user_id in (me_id, friend.id) and date >= current_date - 1;
  update public.permanent_skills set pair_id = new_pair
    where user_id in (me_id, friend.id) and is_active;
  return json_build_object('pair_id', new_pair, 'partner_name', friend.name);
end $$;

create or replace function public.unpair()
returns void language plpgsql security definer set search_path = public as $$
declare
  pid uuid;
begin
  select pair_id into pid from public.profiles where id = auth.uid();
  if pid is null then return; end if;
  update public.pairs set status = 'ended' where id = pid;
  update public.profiles set pair_id = null where pair_id = pid;
end $$;

grant execute on function public.pair_with_code(text) to authenticated;
grant execute on function public.unpair() to authenticated;

-- ---------------------------------------------------------------------
-- 6. Realtime (live updates on both phones)
-- ---------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array['daily_entries', 'profiles', 'permanent_skills', 'messages'] loop
    begin
      execute format('alter publication supabase_realtime add table public.%I', t);
    exception when duplicate_object then null;
    end;
  end loop;
end $$;

-- Recalculate today's scores with the V3 formula
update public.daily_entries set score = score where date >= current_date - 1;

-- Done ✅
