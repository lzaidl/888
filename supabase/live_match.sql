-- Optional server-side matcher.
-- Run after schema.sql.
-- It matches two active sessions when their filters are compatible.

create or replace function public.try_live_match()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  candidate public.search_sessions;
begin
  if new.status <> 'searching' then return new; end if;

  select s.* into candidate
  from public.search_sessions s
  join public.profiles p on p.id = s.user_id
  join public.profiles np on np.id = new.user_id
  where s.status = 'searching'
    and s.id <> new.id
    and s.user_id <> new.user_id
    and (new.preferred_gender is null or p.gender = new.preferred_gender)
    and (candidate.preferred_gender is null or np.gender = candidate.preferred_gender)
    and (new.preferred_country is null or p.country = new.preferred_country)
    and (candidate.preferred_country is null or np.country = candidate.preferred_country)
  order by s.created_at
  limit 1;

  if candidate.id is not null then
    insert into public.search_matches(session_id, matched_user_id)
    values
      (new.id, candidate.user_id),
      (candidate.id, new.user_id)
    on conflict do nothing;

    update public.search_sessions set status='matched', ended_at=now()
      where id in (new.id, candidate.id);
  end if;

  return new;
end;
$$;

drop trigger if exists trg_try_live_match on public.search_sessions;
create trigger trg_try_live_match
after insert on public.search_sessions
for each row execute function public.try_live_match();
