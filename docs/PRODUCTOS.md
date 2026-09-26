# Regla de nombres de productos

La carpeta OneDrive funciona como fuente canónica del catálogo. Cada imagen de producto debe usar este formato exacto:

```text
Orden_Descripción_Disponibilidad_PrecioDOP_categoria.ext
```

Ejemplos válidos:

```text
001_Pin Pulmones Flores_Disponible_96_Salud.jpg
002_Pin Huella Rosa_Disponible_96_Mascotas.jpg
003_Pin estilo manga_Agotado_150_Anime.jpg
004_Lanyard floral_Disponible_350_Estilo de vida.webp
```

## Campos

- `Orden`: entero único usado para ordenar el catálogo, por ejemplo `001`.
- `Descripción`: nombre mostrado en la tarjeta y en la vista detalle.
- `Disponibilidad`: solo `Disponible` o `Agotado`.
- `PrecioDOP`: número en pesos dominicanos, sin `RD$`; admite decimales, por ejemplo `350` o `350.50`.
- `categoria`: categoría del producto. Se crea dinámicamente en la página.
- `ext`: `.jpg`, `.jpeg`, `.png`, `.webp`, `.gif` o `.avif`.

No usar `_` dentro de la descripción ni dentro de la categoría porque el guion bajo es el separador de campos. Los espacios sí están permitidos.

## Disponibilidad

`Disponible` muestra el producto como disponible y ofrece pedido por WhatsApp.

`Agotado` muestra el estado agotado y cambia la llamada a la acción a:

```text
Pedir y reservarlo
```

El mensaje de WhatsApp también indica que se desea pedir y reservar el artículo.

## Categorías

Las categorías se crean automáticamente. No hay que editar HTML para añadir una nueva.

Las categorías conocidas tienen un icono específico y las nuevas reciben un icono genérico. Ver `docs/CATEGORIAS.md`.
