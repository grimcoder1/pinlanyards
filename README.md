# Pin & Lanyards Store by shers — catálogo landing

Landing page estática para GitHub Pages con catálogo generado automáticamente desde nombres de imágenes sincronizadas desde una carpeta OneDrive.

Dominio canónico preparado: `https://pinlanya-rd.com/`.

Repositorio privado: `https://github.com/grimcoder1/pinlanyards`.

## Estructura

```text
src/
  html/                 HTML fuente
  css/                  estilos
  js/                   lógica, configuración y mapa de iconos
  assets/
    category-icons/     SVG de categorías conocidas + fallback
  data/                 placeholder del catálogo
productos/              espejo Git de la carpeta OneDrive canónica
scripts/                generador, build, sincronización y setup de Windows
.github/workflows/      despliegue GitHub Pages por Actions
docs/                   reglas, categorías y mockup aprobado
config/                 ejemplo de configuración
```

## Nombre de producto

```text
Orden_Descripción_Disponibilidad_PrecioDOP_categoria.ext
```

Ejemplo:

```text
001_Pin Pulmones Flores_Disponible_96_Salud.jpg
003_Pin estilo manga_Agotado_150_Anime.jpg
```

Ver `docs/PRODUCTOS.md`.

## Categorías dinámicas

La categoría sale del último campo del archivo. Salud, Mascotas, Graduación, Estilo de vida, Naturaleza, Frases, Instituciones y Anime tienen SVG propio. Cualquier categoría nueva funciona automáticamente con un icono genérico.

Ver `docs/CATEGORIAS.md`.

## Vista local

```powershell
py -3 scripts/build_site.py
py -3 -m http.server 8080 -d dist
```

Abrir `http://localhost:8080`.

La primera versión incluye tres imágenes de demostración en `productos/` para comprobar búsqueda, categorías dinámicas, disponibilidad y reserva. Deben reemplazarse por el catálogo real al conectar la carpeta OneDrive canónica.

## Estado de la primera corrida

- Build local validado con 3 productos de demostración.
- Dominio canónico y archivo `CNAME` preparados para `pinlanya-rd.com`.
- Workflow de GitHub Pages preparado; la fuente **GitHub Actions** debe activarse manualmente en **Settings → Pages**.
- WhatsApp comercial configurado: `+1 809-768-2327`.
- Pendiente para la automatización final: ruta exacta de la carpeta OneDrive canónica.

## Integración Windows + OneDrive + GitHub

Seguir `CODEX_INTEGRACION.md`. El setup automatizado está en:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Setup-CatalogSync.ps1
```

La carpeta OneDrive indicada durante el setup será la **fuente canónica**. No guardar tokens de GitHub dentro del repositorio; usar Git Credential Manager o GitHub CLI para autenticación.
