# INSTRUCCIONES PARA CODEX — Pin & Lanyards Store by shers

## Datos confirmados de esta instalación

- Dominio canónico: `https://pinlanyards.com/`
- Repositorio privado: `https://github.com/grimcoder1/pinlanyards.git`
- Rama operativa: `main`
- Pendientes del propietario: ruta OneDrive canónica y número comercial de WhatsApp

## Objetivo

Integrar y dejar operativo este proyecto como una **landing page única de catálogo** desplegada en **GitHub Pages**, donde el usuario no técnico solo administra productos agregando, renombrando o eliminando imágenes en una carpeta local sincronizada con **OneDrive**. Esa carpeta se considera la **fuente canónica de productos** y un job de Windows la sincroniza hacia la carpeta `productos/` del repositorio GitHub.

No convertir esto en un CMS, no agregar base de datos y no complejizar el flujo en esta fase.

---

## PASO 0 — DATO OBLIGATORIO ANTES DE CONTINUAR

Antes de ejecutar cambios de configuración o scripts, pregúntame de forma puntual:

> **“Indícame la ruta local exacta de la carpeta OneDrive que será la fuente CANÓNICA de productos, por ejemplo `C:\Users\...\OneDrive\...\Catalogo`. No puedo terminar la sincronización automática sin esa ruta.”**

Si al pegarte este Markdown ya te di esa ruta, úsala y no vuelvas a preguntarla. **Si no te la di, recuérdame que debo dártela y no inventes una ruta.**

También necesitas conocer la URL HTTPS del repositorio GitHub de destino. Si no puedes obtenerla del `origin` del repositorio actual, pregúntame:

> **“¿Cuál es la URL HTTPS exacta del repositorio GitHub donde se publicará este catálogo?”**

No inventes el repositorio.

Si `src/js/config.js` todavía tiene `whatsappNumber` vacío, pídeme el número de WhatsApp comercial en formato internacional solo para completar los CTA. No bloquees la configuración Git/OneDrive por ese dato; puedes dejarlo pendiente si te indico que siga vacío.

Si se utilizará dominio propio y no está indicado `canonicalUrl`, pregunta cuál será la URL pública canónica. Si no hay dominio propio, una vez desplegado usa la URL final de GitHub Pages como `canonicalUrl`.

---

## 1. Reglas funcionales que NO deben cambiar

La web es una sola landing page. En el encabezado **no debe existir menú** de “Inicio / Catálogo / Categorías / Sobre nosotros / Contacto”. Deben quedar únicamente:

- logo / identidad,
- Instagram,
- WhatsApp,
- botón **“Ver catálogo completo”**, que desplaza a `#catalogo`.

No agregar TikTok.

Debe conservar:

- buscador,
- categorías generadas desde los productos,
- tarjetas de productos,
- vista de detalle en modal,
- CTA por WhatsApp,
- estado Disponible / Agotado,
- precio en RD$ / DOP,
- responsive móvil,
- aviso de envío.

Condiciones de envío visibles:

- **Envíos con costo adicional.**
- **Pedidos mayores a 5 artículos: envío incluido dentro del Distrito Nacional.**

Cuando un producto esté `Agotado`, mostrar **“Pedir y reservarlo”** en lugar del CTA normal y generar un mensaje de WhatsApp orientado a reserva.

---

## 2. Fuente de datos: nombre de archivo

Todo dato del producto debe venir del nombre de la imagen. Formato canónico:

```text
Orden_Descripción_Disponibilidad_PrecioDOP_categoria.ext
```

Ejemplo:

```text
001_Pin Pulmones Flores_Disponible_96_Salud.jpg
002_Pin Huella Rosa_Disponible_96_Mascotas.jpg
003_Pin estilo manga_Agotado_150_Anime.jpg
```

No crear formularios administrativos en esta fase.

Reglas:

- `Orden`: número entero; controla orden ascendente.
- `Descripción`: texto visible; no usar `_` dentro de este campo.
- `Disponibilidad`: únicamente `Disponible` o `Agotado`.
- `PrecioDOP`: número sin símbolo, por ejemplo `350` o `350.50`.
- `categoria`: texto que alimenta automáticamente los filtros.
- Una imagen = un producto en esta versión.
- Borrar imagen = borrar producto.
- Renombrar imagen = actualizar producto.

El parser ya existe en `scripts/generate_catalog.py`; no dupliques esa lógica en otra implementación salvo que haya un defecto real que debas corregir.

### 2.1 Categorías e iconos

Las **categorías no deben precrearse como datos**. Deben aparecer únicamente cuando exista al menos un producto cuyo quinto campo (`categoria`) las utilice.

La web sí incluye un mapa visual de iconos en `src/js/category-icons.js` y SVG en `src/assets/category-icons/`. Mantener esta lógica:

- Todos → `todos.svg`
- Salud → `salud.svg`
- Mascotas → `mascotas.svg`
- Graduación → `graduacion.svg`
- Estilo de vida → `estilo-vida.svg`
- Naturaleza → `naturaleza.svg`
- Frases → `frases.svg`
- Instituciones → `instituciones.svg`
- Anime → `anime.svg`
- cualquier categoría nueva/no reconocida → `default.svg`

**Anime debe quedar incluido desde esta versión.** Su icono es genérico de estética kawaii/manga y no debe usar personajes, logotipos o marcas de franquicias concretas.

Ejemplo:

```text
003_Pin estilo manga_Disponible_150_Anime.jpg
```

Debe crear automáticamente el filtro `Anime` y mostrar su SVG específico.

Ejemplo de categoría no configurada visualmente:

```text
004_Llavero azul_Disponible_200_Disney.jpg
```

Debe crear `Disney` automáticamente y mostrar `default.svg`. No modificar HTML para crear la categoría.

Ver también `docs/CATEGORIAS.md`.

---

## 3. Arquitectura existente

Respeta esta estructura:

```text
src/
  html/index.html
  css/styles.css
  js/config.js
  js/category-icons.js
  js/app.js
  assets/
    category-icons/
  data/catalog.json
productos/
scripts/
  generate_catalog.py
  build_site.py
  Sync-CatalogToGitHub.ps1
  Setup-CatalogSync.ps1
.github/workflows/pages.yml
```

`src/html/index.html` es el HTML fuente. `build_site.py` crea `dist/index.html` y empaqueta los recursos. GitHub Pages publica `dist` mediante Actions.

No mover el HTML fuente a la raíz solo por conveniencia. Mantener HTML, CSS, JS y recursos separados.

---

## 4. Validación técnica inicial

Antes de configurar Windows:

1. Inspecciona el repositorio y confirma que los archivos anteriores existen.
2. Ejecuta:

```powershell
py -3 scripts/build_site.py
```

3. Si hay productos, confirma que `dist/data/catalog.json` contiene los datos derivados del nombre de archivo.
4. Arranca vista local:

```powershell
py -3 -m http.server 8080 -d dist
```

5. Indícame abrir `http://localhost:8080` y verificar visualmente:
   - encabezado sin submenús,
   - botón “Ver catálogo completo”,
   - buscador,
   - filtros por categoría con iconos,
   - categoría `Anime` usando su SVG cuando exista un producto Anime,
   - categoría nueva usando el icono genérico sin tocar HTML,
   - tarjetas,
   - producto agotado con “Pedir y reservarlo”,
   - condiciones de envío,
   - versión móvil.

No continúes a producción si el build falla.

---

## 5. Configuración GitHub Pages

Verifica que la rama operativa sea `main` salvo que el repositorio indique otra.

El workflow `.github/workflows/pages.yml` debe:

1. hacer checkout,
2. instalar Python,
3. ejecutar `python scripts/build_site.py`,
4. subir `dist` como artifact de Pages,
5. desplegarlo con GitHub Pages.

En GitHub, guía paso a paso para verificar:

1. **Settings → Pages**.
2. En **Build and deployment / Source**, seleccionar **GitHub Actions** si todavía no lo está.
3. Abrir **Actions** y confirmar ejecución correcta de `Build and deploy catalog to GitHub Pages`.
4. Abrir la URL publicada y probar catálogo.

No insertar tokens o secretos GitHub en HTML, JavaScript o archivos versionados.

---

## 6. Modelo de operación OneDrive → PC → GitHub

La ruta OneDrive que te entregue en el PASO 0 será la **única fuente canónica** para imágenes de producto.

Flujo esperado:

```text
Usuario no técnico
    ↓
Carpeta OneDrive canónica
    ↓
Sync-CatalogToGitHub.ps1
    ↓
<repositorio-local>\productos
    ↓
git commit / git push
    ↓
GitHub Actions
    ↓
build_site.py
    ↓
GitHub Pages
```

No pedir al usuario final que haga commits manuales.

---

## 7. Setup automático en Windows

El proyecto incluye `scripts/Setup-CatalogSync.ps1`. Tu trabajo es guiarme de forma ordenada y, si tienes acceso a mi terminal, ejecutar los pasos verificando cada resultado.

### Requisitos

Verificar primero:

```powershell
git --version
py -3 --version
```

GitHub debe autenticarse mediante **Git Credential Manager** o una sesión previa de GitHub CLI. No guardar un PAT en scripts o archivos del repositorio.

Si `git clone` o `git push` solicita autenticación, detén la automatización y guíame para autenticar Git de forma segura antes de continuar.

### Ejecución recomendada

Desde una copia temporal o desde el repositorio ya clonado, ejecutar:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Setup-CatalogSync.ps1 `
  -SourceFolder "<RUTA_ONEDRIVE_CANONICA>" `
  -RepositoryUrl "<URL_REPOSITORIO_GITHUB>" `
  -Branch "main" `
  -IntervalMinutes 5
```

Si no se pasan `SourceFolder`, `RepositoryUrl` o `LocalRepoPath`, el script puede pedirlos interactivamente.

El setup debe:

1. verificar `git` y `python`,
2. validar que la ruta OneDrive exista,
3. clonar el repositorio si aún no existe localmente,
4. crear `.catalog-sync.local.json`,
5. dejar ese archivo fuera de Git mediante `.gitignore`,
6. registrar el job de Windows **PinLandYards Catalog Sync**,
7. programarlo cada 5 minutos por defecto,
8. ejecutar una sincronización inicial,
9. indicar dónde revisar `logs/catalog-sync.log`.

La configuración local **no debe subirse a GitHub**.

---

## 8. Qué hace cada corrida programada

`scripts/Sync-CatalogToGitHub.ps1` debe mantener esta secuencia:

1. adquirir lock local para evitar dos corridas simultáneas,
2. leer `.catalog-sync.local.json`,
3. verificar la carpeta OneDrive,
4. `git pull --rebase`,
5. usar `robocopy /MIR` para reflejar la fuente canónica hacia `<repo>\productos`,
6. validar todos los nombres con `generate_catalog.py --validate-only`,
7. si hay archivo inválido: **no hacer push** y dejar error claro en log,
8. si no hay cambios: terminar sin commit,
9. si hay cambios: `git add`, `git commit`, `git push`,
10. GitHub Actions reconstruye Pages.

No hacer push de archivos con nombres inválidos.

---

## 9. Verificación del job de Windows

Después del setup, darme estos comandos para validar:

```powershell
schtasks /Query /TN "PinLandYards Catalog Sync" /V /FO LIST
```

Ejecutar manualmente una prueba:

```powershell
schtasks /Run /TN "PinLandYards Catalog Sync"
```

Luego revisar:

```powershell
Get-Content .\logs\catalog-sync.log -Tail 50
```

Si el repositorio local elegido está en otra ruta, ajusta el comando del log a esa ruta.

---

## 10. Prueba de aceptación end-to-end

Pídeme crear o copiar en la carpeta OneDrive canónica una imagen con un nombre de prueba válido, por ejemplo:

```text
900_Producto de prueba_Disponible_100_Anime.jpg
```

Después:

1. correr el job manualmente,
2. verificar que apareció en GitHub dentro de `productos/`,
3. verificar Action exitosa,
4. verificar que aparece en el catálogo,
5. probar búsqueda por “Producto de prueba”,
6. probar filtro `Anime` y verificar su icono específico,
7. cambiar nombre a:

```text
900_Producto de prueba_Agotado_100_Anime.jpg
```

8. volver a sincronizar,
9. verificar que ahora muestre `Agotado` y **“Pedir y reservarlo”**,
10. eliminar la imagen de prueba y confirmar que desaparece después de la siguiente sincronización.

No declarar el setup terminado hasta completar esta prueba o hasta que yo decida omitirla explícitamente.

---

## 11. Configuración final del sitio

Revisar `src/js/config.js` y completar solo con datos confirmados:

```js
window.PINLAND_CONFIG = {
  brandName: "Pin & Lanyards Store by shers",
  instagramUrl: "https://www.instagram.com/pinlandyards/",
  whatsappNumber: "<NUMERO_INTERNACIONAL_SIN_SIMBOLOS>",
  currency: "DOP",
  locale: "es-DO",
  shippingShort: "Envíos con costo adicional",
  shippingLong: "Pedidos mayores a 5 artículos: envío incluido en Distrito Nacional.",
  catalogHash: "#catalogo",
  canonicalUrl: "<URL_PUBLICA_FINAL>"
};
```

No inventar teléfono, dominio, ruta OneDrive ni URL GitHub.

---

## 12. Entrega final que quiero de Codex

Al terminar, dame un resumen operativo corto con:

- ruta OneDrive canónica utilizada,
- repositorio GitHub utilizado,
- ruta del clon local,
- nombre y frecuencia del job de Windows,
- URL pública de GitHub Pages,
- resultado de la prueba end-to-end,
- cualquier dato todavía pendiente.

Además, dame el paso a paso mínimo para que una persona no técnica gestione el catálogo:

```text
AGREGAR → copiar imagen con nombre válido a OneDrive.
MODIFICAR → renombrar la imagen.
AGOTAR → cambiar Disponible por Agotado en el nombre.
REACTIVAR → cambiar Agotado por Disponible.
ELIMINAR → borrar la imagen.
```

No agregar pasos manuales de Git para ese usuario.
