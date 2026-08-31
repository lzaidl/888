-- Chat & Dating V1.0
-- Run this entire file in Supabase SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  age int not null check (age >= 18 and age <= 100),
  gender text not null check (gender in ('male','female')),
  country text not null,
  bio text default '',
  avatar_url text,
  is_online boolean not null default false,
  last_seen timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.likes (
  id uuid primary key default gen_random_uuid(),
  liker_id uuid not null references public.profiles(id) on delete cascade,
  liked_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(liker_id, liked_id),
  check(liker_id <> liked_id)
);

create table if not exists public.matches (
  id uuid primary key default gen_random_uuid(),
  user_a uuid not null references public.profiles(id) on delete cascade,
  user_b uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(user_a, user_b),
  check(user_a <> user_b)
);

create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  type text not null default 'private' check(type in ('private','group')),
  title text,
  created_at timestamptz not null default now()
);

create table if not exists public.conversation_members (
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key(conversation_id,user_id)
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  body text,
  message_type text not null default 'text' check(message_type in ('text','image','system')),
  created_at timestamptz not null default now(),
  read_at timestamptz
);

create table if not exists public.blocked_users (
  blocker_id uuid not null references public.profiles(id) on delete cascade,
  blocked_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(blocker_id,blocked_id),
  check(blocker_id <> blocked_id)
);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  reported_id uuid not null references public.profiles(id) on delete cascade,
  reason text not null,
  details text,
  created_at timestamptz not null default now(),
  status text not null default 'open'
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  type text not null,
  title text not null,
  body text,
  data jsonb default '{}'::jsonb,
  read boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.search_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  preferred_gender text check(preferred_gender is null or preferred_gender in ('male','female')),
  preferred_country text,
  status text not null default 'searching' check(status in ('searching','matched','cancelled','expired')),
  created_at timestamptz not null default now(),
  ended_at timestamptz
);

create table if not exists public.search_matches (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.search_sessions(id) on delete cascade,
  matched_user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(session_id, matched_user_id)
);

create index if not exists idx_profiles_gender_country on public.profiles(gender,country);
create index if not exists idx_messages_conversation on public.messages(conversation_id,created_at);
create index if not exists idx_search_status on public.search_sessions(status,created_at);

alter table public.profiles enable row level security;
alter table public.likes enable row level security;
alter table public.matches enable row level security;
alter table public.conversations enable row level security;
alter table public.conversation_members enable row level security;
alter table public.messages enable row level security;
alter table public.blocked_users enable row level security;
alter table public.reports enable row level security;
alter table public.notifications enable row level security;
alter table public.search_sessions enable row level security;
alter table public.search_matches enable row level security;

create policy "profiles readable by authenticated"
on public.profiles for select to authenticated using (true);

create policy "own profile insert"
on public.profiles for insert to authenticated with check (id = auth.uid());

create policy "own profile update"
on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

create policy "likes own"
on public.likes for all to authenticated using (liker_id = auth.uid()) with check (liker_id = auth.uid());

create policy "matches participants read"
on public.matches for select to authenticated using (user_a = auth.uid() or user_b = auth.uid());

create policy "conversation members read"
on public.conversation_members for select to authenticated using (user_id = auth.uid());

create policy "conversation member insert own"
on public.conversation_members for insert to authenticated with check (user_id = auth.uid());

create policy "messages read members"
on public.messages for select to authenticated using (
  exists(select 1 from public.conversation_members cm
         where cm.conversation_id = messages.conversation_id and cm.user_id = auth.uid())
);

create policy "messages insert own member"
on public.messages for insert to authenticated with check (
  sender_id = auth.uid() and
  exists(select 1 from public.conversation_members cm
         where cm.conversation_id = messages.conversation_id and cm.user_id = auth.uid())
);

create policy "blocked own"
on public.blocked_users for all to authenticated using (blocker_id = auth.uid()) with check (blocker_id = auth.uid());

create policy "reports own"
on public.reports for insert to authenticated with check (reporter_id = auth.uid());

create policy "notifications own"
on public.notifications for select to authenticated using (user_id = auth.uid());

create policy "notifications own update"
on public.notifications for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "search own"
on public.search_sessions for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "search matches own session"
on public.search_matches for select to authenticated using (
  exists(select 1 from public.search_sessions s where s.id = search_matches.session_id and s.user_id = auth.uid())
);

-- Helper: create a private conversation safely after a match.
create or replace function public.create_private_conversation(other_user uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  cid uuid;
begin
  if other_user = auth.uid() then raise exception 'cannot chat with yourself'; end if;

  select c.id into cid
  from conversations c
  join conversation_members a on a.conversation_id = c.id and a.user_id = auth.uid()
  join conversation_members b on b.conversation_id = c.id and b.user_id = other_user
  where c.type = 'private'
  limit 1;

  if cid is not null then return cid; end if;

  insert into conversations(type) values ('private') returning id into cid;
  insert into conversation_members(conversation_id,user_id)
    values (cid, auth.uid()), (cid, other_user);
  return cid;
end;
$$;

-- Match function: if both users liked each other, create a match and conversation.
create or replace function public.like_user(target uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  mid uuid;
  cid uuid;
  mutual boolean;
begin
  if target = auth.uid() then raise exception 'cannot like yourself'; end if;

  insert into likes(liker_id,liked_id)
  values(auth.uid(),target)
  on conflict do nothing;

  select exists(
    select 1 from likes
    where liker_id = target and liked_id = auth.uid()
  ) into mutual;

  if mutual then
    insert into matches(user_a,user_b)
    values(least(auth.uid(),target), greatest(auth.uid(),target))
    on conflict do nothing
    returning id into mid;

    select create_private_conversation(target) into cid;
    return jsonb_build_object('matched',true,'match_id',mid,'conversation_id',cid);
  end if;

  return jsonb_build_object('matched',false);
end;
$$;

-- Realtime publication.
alter publication supabase_realtime add table public.messages;
alter publication supabase_realtime add table public.search_matches;
alter publication supabase_realtime add table public.profiles;
