# Cómo activar tu backend (5 pasos)

## 1. Corre el SQL en Supabase
- Entra a tu proyecto en supabase.com → menú lateral **SQL Editor** → **New query**.
- Pega TODO el contenido de `supabase_schema.sql` y dale **Run**.
- Antes de correrlo, cambia `'CambiaEsto123'` (línea del `insert into admin_settings`) por la contraseña que quieras usar para entrar en modo administrador.

## 2. Conecta tu página con Supabase
- En Supabase: **Settings → API**.
- Copia el **Project URL** y la clave **anon public**.
- Abre `index.html`, busca esto cerca del inicio (`<head>`):
  ```html
  const SUPABASE_URL = "PEGA_AQUI_TU_SUPABASE_URL";
  const SUPABASE_ANON_KEY = "PEGA_AQUI_TU_SUPABASE_ANON_KEY";
  ```
- Reemplaza ambos valores por los tuyos y guarda el archivo.

## 3. Publica tu página
Sube `index.html` a donde tengas hosteado el sitio (Netlify, Vercel, GitHub Pages, tu hosting actual, etc.) reemplazando el archivo actual.

## 4. Cómo entrar en modo administrador
- Haz clic **5 veces seguidas** sobre el logo "TRIHARD" (arriba a la izquierda), en menos de ~2.5 segundos.
- Aparece un modal pidiendo **solo la contraseña** (sin usuario/email).
- Al entrar correctamente, la página misma se vuelve editable: pasa el mouse sobre cualquier texto marcado y haz clic para escribir directamente encima (título, WhatsApp, teléfono, correo, servicios, estadísticas, testimonios, pie de página).
- Abajo a la derecha aparece una barra flotante:
  - **Guardar Cambios** → guarda todo lo editado en Supabase.
  - **Ver Cotizaciones** → abre un panel (sin salir de la página) con todas las cotizaciones recibidas del formulario, y te deja marcarlas como Nueva / Vista / Atendida.
  - **Salir** → cierra el modo edición.

## 5. Qué se puede editar ahora mismo
Ya están marcados como editables:
- Teléfono, correo y ubicación (el número de WhatsApp y el `tel:` se actualizan automáticamente a partir del teléfono).
- Subtítulo del hero y frase pequeña de la foto.
- Título/descripción de servicios y las 6 tarjetas del catálogo.
- Las 3 estadísticas (proyectos, %, soporte).
- La frase institucional destacada.
- Los 2 testimonios.
- El copyright y frase del footer.

### ¿Quieres que algo más sea editable?
Solo dile a Claude qué texto o sección quieres agregar — es tan simple como añadirle un atributo `data-edit-key="nombre_unico"` a ese elemento en el HTML, el sistema ya está preparado para reconocerlo automáticamente.

## Notas de seguridad
- La contraseña nunca se guarda en el navegador (ni en cookies ni en localStorage): vive solo en memoria mientras tienes la pestaña abierta. Si recargas la página, tienes que volver a hacer los 5 clics.
- Las cotizaciones **no se pueden leer** desde el navegador sin la contraseña correcta (bloqueado a nivel de base de datos, no solo en el front end).
- Puedes cambiar tu contraseña más adelante corriendo esto en el SQL Editor de Supabase:
  ```sql
  select set_admin_password('contraseña_actual', 'contraseña_nueva');
  ```
