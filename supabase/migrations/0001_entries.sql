-- Chronik: the Work log, one row per Entry.
-- See docs/superpowers/specs/2026-09-07-supabase-persistence-design.md (D6, D7).

create table if not exists public.entries (
    id         uuid primary key,
    user_id    uuid not null references auth.users (id) on delete cascade default auth.uid(),
    -- A Day, not a moment: Entries belong to a calendar day (CONTEXT.md).
    day        date not null,
    -- Client-sent, not default now(): editing an Entry preserves its original value.
    created_at timestamptz not null,
    title      text not null,
    duration   numeric(5, 2),
    notes      text
);

-- Matches the fetchAll() ordering so the read path stays index-backed once
-- pagination replaces the current .limit(500).
create index if not exists entries_user_day_created_idx
    on public.entries (user_id, day desc, created_at desc);

alter table public.entries enable row level security;

-- Four policies, all keyed on auth.uid(). The anon key ships inside the app
-- binary and is extractable, so these are the only thing protecting the data.
--
-- Postgres has no `create policy if not exists`, so each is dropped first. That
-- makes this file safe to re-run over a project where some of it already exists.

drop policy if exists "Entries are readable by their owner" on public.entries;
create policy "Entries are readable by their owner"
    on public.entries for select
    to authenticated
    using (user_id = auth.uid());

drop policy if exists "Entries are insertable by their owner" on public.entries;
create policy "Entries are insertable by their owner"
    on public.entries for insert
    to authenticated
    with check (user_id = auth.uid());

drop policy if exists "Entries are updatable by their owner" on public.entries;
create policy "Entries are updatable by their owner"
    on public.entries for update
    to authenticated
    using (user_id = auth.uid())
    with check (user_id = auth.uid());

drop policy if exists "Entries are deletable by their owner" on public.entries;
create policy "Entries are deletable by their owner"
    on public.entries for delete
    to authenticated
    using (user_id = auth.uid());
