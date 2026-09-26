# Categorías e iconos

Las categorías **no están precreadas como datos**. Se crean automáticamente a partir del quinto campo del nombre de cada imagen:

```text
Orden_Descripción_Disponibilidad_PrecioDOP_categoria.ext
```

Ejemplo:

```text
003_Pin estilo manga_Disponible_150_Anime.jpg
```

Al existir al menos un producto con `Anime`, la categoría **Anime** aparecerá automáticamente en la página.

## Iconos visuales conocidos

La web asigna un SVG visual a categorías conocidas. Esto no limita qué categorías pueden existir.

| Categoría | Recurso |
|---|---|
| Todos | `src/assets/category-icons/todos.svg` |
| Salud | `src/assets/category-icons/salud.svg` |
| Mascotas | `src/assets/category-icons/mascotas.svg` |
| Graduación | `src/assets/category-icons/graduacion.svg` |
| Estilo de vida | `src/assets/category-icons/estilo-vida.svg` |
| Naturaleza | `src/assets/category-icons/naturaleza.svg` |
| Frases | `src/assets/category-icons/frases.svg` |
| Instituciones | `src/assets/category-icons/instituciones.svg` |
| Anime | `src/assets/category-icons/anime.svg` |

Las categorías nuevas o no reconocidas reciben automáticamente:

```text
src/assets/category-icons/default.svg
```

Por ejemplo:

```text
004_Llavero azul_Disponible_200_Disney.jpg
```

crea la categoría `Disney` automáticamente y usa el icono genérico hasta que se le asigne uno específico.

## Cómo agregar un icono específico a una categoría nueva

1. Crear un SVG dentro de `src/assets/category-icons/`.
2. Abrir `src/js/category-icons.js`.
3. Agregar la clave normalizada y la ruta del SVG.

Ejemplo:

```js
"disney": "./assets/category-icons/disney.svg"
```

No hay que modificar el parser de productos ni el catálogo JSON.

## Regla Anime

El icono de Anime es deliberadamente genérico/kawaii. No utiliza logotipos, personajes ni marcas de franquicias concretas.
