#!/usr/bin/env python3
"""Generate the catalog JSON from product image filenames.

Canonical filename format:
    Orden_Descripción_Disponibilidad_PrecioDOP_categoria.ext

Example:
    001_Pin Pulmones Flores_Disponible_350_Salud.jpg
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".gif", ".avif"}
ALLOWED_AVAILABILITY = {"disponible": "Disponible", "agotado": "Agotado"}


def parse_price(raw: str) -> float:
    value = raw.strip().upper().replace("DOP", "").replace("RD$", "").replace("$", "")
    value = value.replace(",", "")
    if not re.fullmatch(r"\d+(?:\.\d{1,2})?", value):
        raise ValueError("PrecioDOP debe ser numérico, por ejemplo 350 o 350.50")
    return float(value)


def parse_file(path: Path) -> dict:
    parts = path.stem.split("_", 4)
    if len(parts) != 5:
        raise ValueError("Debe tener exactamente 5 campos separados por '_' en el orden: Orden_Descripción_Disponibilidad_PrecioDOP_categoria")

    order_raw, description, availability_raw, price_raw, category = [p.strip() for p in parts]

    if not re.fullmatch(r"\d+", order_raw):
        raise ValueError("Orden debe ser un número entero, por ejemplo 001")
    if not description:
        raise ValueError("Descripción no puede estar vacía")
    if not category:
        raise ValueError("categoria no puede estar vacía")

    availability_key = availability_raw.casefold()
    if availability_key not in ALLOWED_AVAILABILITY:
        raise ValueError("Disponibilidad debe ser 'Disponible' o 'Agotado'")

    price = parse_price(price_raw)

    return {
        "order": order_raw,
        "description": description,
        "availability": ALLOWED_AVAILABILITY[availability_key],
        "price": price,
        "category": category,
        "image": f"./productos/{path.name}",
    }


def collect(products_dir: Path) -> tuple[list[dict], list[str]]:
    products: list[dict] = []
    errors: list[str] = []
    if not products_dir.exists():
        return [], [f"No existe la carpeta de productos: {products_dir}"]

    for path in sorted(products_dir.iterdir(), key=lambda p: p.name.casefold()):
        if not path.is_file() or path.suffix.casefold() not in IMAGE_EXTENSIONS:
            continue
        try:
            products.append(parse_file(path))
        except ValueError as exc:
            errors.append(f"{path.name}: {exc}")

    # Detect duplicated order values; one order = one product in v1.
    seen: dict[str, str] = {}
    for product in products:
        order = product["order"]
        if order in seen:
            errors.append(f"Orden duplicado {order}: {seen[order]} y {product['image'].split('/')[-1]}")
        else:
            seen[order] = product["image"].split("/")[-1]

    products.sort(key=lambda p: int(p["order"]))
    return products, errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--products", default="productos")
    parser.add_argument("--output", default="src/data/catalog.json")
    parser.add_argument("--validate-only", action="store_true")
    parser.add_argument("--strict", action="store_true", default=True)
    args = parser.parse_args()

    products_dir = Path(args.products).resolve()
    products, errors = collect(products_dir)

    if errors:
        print("CATALOG_VALIDATION_FAILED", file=sys.stderr)
        for error in errors:
            print(f" - {error}", file=sys.stderr)
        return 2

    print(f"CATALOG_VALIDATION_OK: {len(products)} producto(s)")
    if args.validate_only:
        return 0

    output = Path(args.output).resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "count": len(products),
        "products": products,
    }
    output.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"CATALOG_WRITTEN: {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
