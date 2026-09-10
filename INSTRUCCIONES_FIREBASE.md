# Cómo activar tu backend con Firebase (versión recomendada)

## 1. Crea Firestore
- En Firebase Console → tu proyecto → **Firestore Database** → **Crear base de datos** → modo **Producción** → elige una región (ej. `us-east1`).

## 2. Activa el inicio de sesión con correo/contraseña
- **Authentication** → pestaña **Sign-in method** → habilita **Correo electrónico/contraseña**.

## 3. Crea el usuario "administrador" oculto
- **Authentication** → pestaña **Users** → **Add user**.
- Correo: exactamente el mismo que pusiste en `ADMIN_EMAIL` dentro del HTML (por defecto `admin@trihardwebsolution.com`, puedes cambiarlo, pero debe coincidir en 3 lugares: el HTML, las reglas de Firestore, y aquí).
- Contraseña: la que vas a usar en el modal de 5 clics. Esta es la única que vas a escribir en el sitio — el correo nunca se muestra.

## 4. Pega las reglas de seguridad
- **Firestore Database** → pestaña **Reglas** → borra lo que haya → pega todo el contenido de `firestore.rules` → **Publicar**.
- Si cambiaste el `ADMIN_EMAIL`, actualízalo también dentro de este archivo de reglas antes de publicar.

## 5. Conecta tu página con Firebase
- **Configuración del proyecto** (ícono de engranaje) → sección **Tus apps** → si no tienes una app web, créala (ícono `</>`) → copia el objeto `firebaseConfig`.
- Abre `index_firebase.html`, busca `FIREBASE_CONFIG` cerca del inicio y pega tus valores reales.

## 6. Publica tu página
Sube `index_firebase.html` (renómbralo a `index.html` si tu hosting lo requiere) a Netlify, Vercel, GitHub Pages, o tu hosting actual.

## 7. Cómo entrar en modo administrador
- Haz clic **5 veces seguidas** sobre el logo "TRIHARD", en menos de ~2.5 segundos.
- Aparece un modal pidiendo **solo la contraseña**.
- Al validar, se activa la edición directa sobre la página (sin ir a ningún dashboard), y aparece la barra flotante con **Guardar Cambios**, **Ver Cotizaciones** y **Salir**.
- La sesión dura mientras tengas la pestaña abierta; al cerrarla, tendrás que volver a hacer los 5 clics.

## Notas de seguridad
- La verificación de la contraseña la hace el servidor de Google (Firebase Auth), no el navegador — nadie puede leer ni adivinar el hash desde el código de la página.
- Las cotizaciones (nombre, teléfono, mensaje de tus clientes) **no se pueden leer** sin haber iniciado sesión como administrador — está bloqueado a nivel de las reglas de Firestore, no solo en el diseño de la página.
- Es 100% gratis dentro del plan **Spark** de Firebase (no requiere tarjeta de crédito ni Cloud Functions).
- Si algún día quieres cambiar la contraseña: **Authentication → Users → (tu usuario) → Reset password**, o bórralo y créalo de nuevo con la contraseña nueva.
