(() => {
  "use strict";

  // Las categorías nacen dinámicamente del nombre de los archivos de producto.
  // Este mapa SOLO decide qué icono visual usa una categoría conocida.
  // Una categoría nueva sigue funcionando y recibe default.svg automáticamente.
  window.PINLAND_CATEGORY_ICONS = Object.freeze({
    todos: "./assets/category-icons/todos.svg",
    salud: "./assets/category-icons/salud.svg",
    mascotas: "./assets/category-icons/mascotas.svg",
    graduacion: "./assets/category-icons/graduacion.svg",
    "estilo de vida": "./assets/category-icons/estilo-vida.svg",
    naturaleza: "./assets/category-icons/naturaleza.svg",
    frases: "./assets/category-icons/frases.svg",
    instituciones: "./assets/category-icons/instituciones.svg",
    anime: "./assets/category-icons/anime.svg",
    default: "./assets/category-icons/default.svg"
  });
})();
