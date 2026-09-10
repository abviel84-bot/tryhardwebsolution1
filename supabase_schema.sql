-- ============================================================
--  TRYHARD WEB SOLUTION — Esquema de Supabase
--  Ejecuta TODO este archivo de una vez en:
--  Supabase → tu proyecto → SQL Editor → New query → Run
-- ============================================================

-- Necesario para generar UUIDs y para el hash de la contraseña
create extension if not exists pgcrypto;

-- ============================================================
-- 1) TABLA: cotizaciones (lo que llega desde el formulario)
-- ============================================================
create table if not exists public.cotizaciones (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  nombre text not null,
  contacto text not null,
  servicio text,
  mensaje text,
  estado text not null default 'nueva' check (estado in ('nueva','vista','atendida'))
);

alter table public.cotizaciones enable row level security;

-- Cualquier visitante puede ENVIAR una cotización (insertar)
drop policy if exists "insertar cotizaciones publicas" on public.cotizaciones;
create policy "insertar cotizaciones publicas"
  on public.cotizaciones for insert
  to anon
  with check (true);

-- OJO: a propósito NO se crea ninguna policy de SELECT/UPDATE/DELETE
-- para "anon". Eso significa que nadie puede leer las cotizaciones
-- directamente desde el navegador. Solo se pueden leer/editar a
-- través de las funciones RPC protegidas con contraseña (más abajo).


-- ============================================================
-- 2) TABLA: config_sitio (todo lo editable de la página)
-- ============================================================
create table if not exists public.config_sitio (
  key text primary key,
  value text not null,
  updated_at timestamptz not null default now()
);

alter table public.config_sitio enable row level security;

-- Lectura pública: necesaria para que la página muestre los textos
drop policy if exists "lectura publica config" on public.config_sitio;
create policy "lectura publica config"
  on public.config_sitio for select
  to anon
  using (true);

-- No hay policy de insert/update/delete para "anon": solo se puede
-- modificar a través de la función save_config() protegida por contraseña.


-- ============================================================
-- 3) TABLA: admin_settings (guarda el HASH de tu contraseña)
-- ============================================================
create table if not exists public.admin_settings (
  id int primary key default 1,
  password_hash text not null,
  constraint solo_una_fila check (id = 1)
);

alter table public.admin_settings enable row level security;
-- Sin policies para "anon": esta tabla queda 100% bloqueada desde el navegador.

-- ⚠️ CAMBIA 'CambiaEsto123' por tu contraseña real antes de ejecutar,
-- o cámbiala después ejecutando esta misma instrucción de nuevo.
insert into public.admin_settings (id, password_hash)
values (1, crypt('CambiaEsto123', gen_salt('bf')))
on conflict (id) do update set password_hash = excluded.password_hash;


-- ============================================================
-- 4) FUNCIONES RPC (la única puerta de entrada protegida)
-- ============================================================

-- Verifica si una contraseña es correcta
create or replace function public.verify_admin_password(p_password text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_hash text;
begin
  select password_hash into v_hash from public.admin_settings where id = 1;
  if v_hash is null then
    return false;
  end if;
  return v_hash = crypt(p_password, v_hash);
end;
$$;

grant execute on function public.verify_admin_password(text) to anon;


-- Guarda/actualiza en bloque todos los textos editables del sitio
create or replace function public.save_config(p_payload jsonb, p_password text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_key text;
  v_value text;
begin
  if not public.verify_admin_password(p_password) then
    raise exception 'Contraseña incorrecta';
  end if;

  for v_key, v_value in select * from jsonb_each_text(p_payload)
  loop
    insert into public.config_sitio(key, value, updated_at)
    values (v_key, v_value, now())
    on conflict (key) do update set value = excluded.value, updated_at = now();
  end loop;

  return true;
end;
$$;

grant execute on function public.save_config(jsonb, text) to anon;


-- Devuelve todas las cotizaciones (solo si la contraseña es correcta)
create or replace function public.get_cotizaciones(p_password text)
returns setof public.cotizaciones
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.verify_admin_password(p_password) then
    raise exception 'Contraseña incorrecta';
  end if;
  return query select * from public.cotizaciones order by created_at desc;
end;
$$;

grant execute on function public.get_cotizaciones(text) to anon;


-- Cambia el estado de una cotización (nueva / vista / atendida)
create or replace function public.update_cotizacion_estado(p_id uuid, p_estado text, p_password text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.verify_admin_password(p_password) then
    raise exception 'Contraseña incorrecta';
  end if;
  if p_estado not in ('nueva','vista','atendida') then
    raise exception 'Estado inválido';
  end if;
  update public.cotizaciones set estado = p_estado where id = p_id;
  return true;
end;
$$;

grant execute on function public.update_cotizacion_estado(uuid, text, text) to anon;


-- Elimina una cotización (opcional, por si quieres limpiar la lista)
create or replace function public.delete_cotizacion(p_id uuid, p_password text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.verify_admin_password(p_password) then
    raise exception 'Contraseña incorrecta';
  end if;
  delete from public.cotizaciones where id = p_id;
  return true;
end;
$$;

grant execute on function public.delete_cotizacion(uuid, text) to anon;


-- Permite cambiar tu contraseña de administrador desde el SQL Editor
-- (pide la contraseña actual como confirmación)
create or replace function public.set_admin_password(p_old_password text, p_new_password text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.verify_admin_password(p_old_password) then
    raise exception 'Contraseña actual incorrecta';
  end if;
  update public.admin_settings set password_hash = crypt(p_new_password, gen_salt('bf')) where id = 1;
  return true;
end;
$$;

grant execute on function public.set_admin_password(text, text) to anon;


-- ============================================================
-- 5) Valores iniciales de config_sitio (opcional)
--    Así la página ya arranca con estos textos aunque no hayas
--    editado nada todavía. Si prefieres, borra este bloque y
--    la página usará los textos que ya están escritos en el HTML.
-- ============================================================
insert into public.config_sitio (key, value) values
  ('telefono_display', '+1 (939) 649-3269'),
  ('email_display', 'tuemail@trihardwebsolution.com'),
  ('ubicacion', 'Puerto Rico | Remoto a Nivel Global')
on conflict (key) do nothing;

-- ============================================================
-- LISTO. Revisa la tabla admin_settings y confirma tu contraseña
-- inicial antes de compartir el link de tu página.
-- ============================================================
