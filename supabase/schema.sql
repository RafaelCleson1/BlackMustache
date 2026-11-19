-- ============================================================================
-- BLACK MUSTACHE - Script completo do banco de dados (Supabase / PostgreSQL)
-- Execute este arquivo no SQL Editor do seu projeto Supabase.
-- ============================================================================

create extension if not exists "pgcrypto";

-- ----------------------------------------------------------------------------
-- 1. TABELAS
-- ----------------------------------------------------------------------------
create table if not exists public.services (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null default '',
  price numeric(10, 2) not null check (price >= 0),
  duration_minutes integer not null check (duration_minutes > 0),
  image_url text,
  is_featured boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.barbers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  specialty text not null default '',
  avatar_url text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  client_name text not null default 'Cliente Black Mustache',
  service_id uuid not null references public.services (id) on delete restrict,
  barber_id uuid not null references public.barbers (id) on delete restrict,
  appointment_date date not null,
  start_time time not null,
  end_time time not null,
  total_price numeric(10, 2) not null default 0 check (total_price >= 0),
  status text not null default 'confirmed'
    check (status in ('confirmed', 'completed', 'cancelled')),
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 2. ÍNDICES
-- ----------------------------------------------------------------------------
create index if not exists appointments_barber_date_idx
  on public.appointments (barber_id, appointment_date);

create unique index if not exists appointments_unique_slot_idx
  on public.appointments (barber_id, appointment_date, start_time)
  where status <> 'cancelled';

-- ----------------------------------------------------------------------------
-- 3. TRIGGER: calcula end_time e total_price a partir do serviço
--    e bloqueia conflitos de horário para o mesmo barbeiro.
-- ----------------------------------------------------------------------------
create or replace function public.prepare_appointment()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_duration integer;
  v_price numeric(10, 2);
begin
  select duration_minutes, price
    into v_duration, v_price
    from public.services
   where id = new.service_id;

  if v_duration is null then
    raise exception 'Serviço não encontrado' using errcode = 'P0002';
  end if;

  new.end_time := new.start_time + make_interval(mins => v_duration);
  new.total_price := v_price;

  if new.status is null or new.status = '' then
    new.status := 'confirmed';
  end if;

  if exists (
    select 1
      from public.appointments a
     where a.barber_id = new.barber_id
       and a.appointment_date = new.appointment_date
       and a.status <> 'cancelled'
       and a.id is distinct from new.id
       and new.start_time < a.end_time
       and new.end_time > a.start_time
  ) then
    raise exception 'Horário indisponível para este profissional'
      using errcode = 'P0001';
  end if;

  return new;
end;
$$;

drop trigger if exists trg_prepare_appointment on public.appointments;

create trigger trg_prepare_appointment
before insert or update on public.appointments
for each row execute function public.prepare_appointment();

-- ----------------------------------------------------------------------------
-- 4. ROW LEVEL SECURITY
--    O app não usa autenticação nesta versão, então o acesso anônimo é liberado
--    apenas para leitura do catálogo e criação/consulta de agendamentos.
--    Em produção, restrinja os agendamentos ao usuário autenticado.
-- ----------------------------------------------------------------------------
alter table public.services enable row level security;
alter table public.barbers enable row level security;
alter table public.appointments enable row level security;

drop policy if exists "services public read" on public.services;
create policy "services public read"
  on public.services for select to anon, authenticated using (true);

drop policy if exists "barbers public read" on public.barbers;
create policy "barbers public read"
  on public.barbers for select to anon, authenticated using (true);

drop policy if exists "appointments public read" on public.appointments;
create policy "appointments public read"
  on public.appointments for select to anon, authenticated using (true);

drop policy if exists "appointments public insert" on public.appointments;
create policy "appointments public insert"
  on public.appointments for insert to anon, authenticated with check (true);

drop policy if exists "appointments public update" on public.appointments;
create policy "appointments public update"
  on public.appointments for update to anon, authenticated using (true) with check (true);

-- ----------------------------------------------------------------------------
-- 5. PERMISSÕES
-- ----------------------------------------------------------------------------
grant usage on schema public to anon, authenticated;
grant select on public.services to anon, authenticated;
grant select on public.barbers to anon, authenticated;
grant select, insert, update on public.appointments to anon, authenticated;

-- ----------------------------------------------------------------------------
-- 6. SEEDS - Serviços
-- ----------------------------------------------------------------------------
insert into public.services (id, name, description, price, duration_minutes, image_url, is_featured)
values
  (
    '11111111-1111-1111-1111-111111111101',
    'Corte tradicional',
    'Tesoura e máquina na medida certa, com acabamento preciso e finalização impecável.',
    35.00,
    30,
    'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?auto=format&fit=crop&w=800&q=80',
    false
  ),
  (
    '11111111-1111-1111-1111-111111111102',
    'Corte degradê',
    'Laterais em degradê e transição suave para um visual moderno e marcante.',
    40.00,
    40,
    'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?auto=format&fit=crop&w=800&q=80',
    true
  ),
  (
    '11111111-1111-1111-1111-111111111103',
    'Barba',
    'Modelagem completa com toalha quente, navalha e óleo essencial.',
    25.00,
    25,
    'https://images.unsplash.com/photo-1621605815971-fbc98d665033?auto=format&fit=crop&w=800&q=80',
    false
  ),
  (
    '11111111-1111-1111-1111-111111111104',
    'Corte + barba',
    'A experiência completa: corte sob medida e barba alinhada ao seu estilo.',
    60.00,
    45,
    'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=800&q=80',
    true
  )
on conflict (id) do update set
  name = excluded.name,
  description = excluded.description,
  price = excluded.price,
  duration_minutes = excluded.duration_minutes,
  image_url = excluded.image_url,
  is_featured = excluded.is_featured;

-- ----------------------------------------------------------------------------
-- 7. SEEDS - Barbeiros
-- ----------------------------------------------------------------------------
insert into public.barbers (id, name, specialty, avatar_url, active)
values
  (
    '22222222-2222-2222-2222-222222222201',
    'Lucas',
    'Especialista em degradês',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
    true
  ),
  (
    '22222222-2222-2222-2222-222222222202',
    'Gabriel',
    'Precisão nos cortes clássicos',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=400&q=80',
    true
  ),
  (
    '22222222-2222-2222-2222-222222222203',
    'Rafael',
    'Expert em barba e visagismo',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
    true
  )
on conflict (id) do update set
  name = excluded.name,
  specialty = excluded.specialty,
  avatar_url = excluded.avatar_url,
  active = excluded.active;

-- ----------------------------------------------------------------------------
-- 8. SEEDS - Agendamentos de exemplo (opcional, demonstra horários ocupados)
-- ----------------------------------------------------------------------------
insert into public.appointments (client_name, service_id, barber_id, appointment_date, start_time, total_price)
select 'Cliente Exemplo', '11111111-1111-1111-1111-111111111104',
       '22222222-2222-2222-2222-222222222201', current_date + 1, '10:00', 0
where not exists (
  select 1 from public.appointments
  where barber_id = '22222222-2222-2222-2222-222222222201'
    and appointment_date = current_date + 1
    and start_time = '10:00'
);

insert into public.appointments (client_name, service_id, barber_id, appointment_date, start_time, total_price)
select 'Cliente Exemplo', '11111111-1111-1111-1111-111111111102',
       '22222222-2222-2222-2222-222222222202', current_date + 1, '14:00', 0
where not exists (
  select 1 from public.appointments
  where barber_id = '22222222-2222-2222-2222-222222222202'
    and appointment_date = current_date + 1
    and start_time = '14:00'
);

insert into public.appointments (client_name, service_id, barber_id, appointment_date, start_time, total_price)
select 'Cliente Exemplo', '11111111-1111-1111-1111-111111111103',
       '22222222-2222-2222-2222-222222222203', current_date + 1, '09:00', 0
where not exists (
  select 1 from public.appointments
  where barber_id = '22222222-2222-2222-2222-222222222203'
    and appointment_date = current_date + 1
    and start_time = '09:00'
);
