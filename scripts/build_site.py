#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import shutil
import stat
import subprocess
import sys
from pathlib import Path


def copytree_contents(src: Path, dst: Path) -> None:
    dst.mkdir(parents=True, exist_ok=True)
    for item in src.iterdir():
        target = dst / item.name
        if item.is_dir():
            copytree_contents(item, target)
        else:
            shutil.copy2(item, target)


def remove_readonly(func, path: str, _exc_info) -> None:
    """Allow clean rebuilds inside OneDrive folders marked read-only."""
    os.chmod(path, stat.S_IWRITE)
    func(path)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--src", default="src")
    parser.add_argument("--products", default="productos")
    parser.add_argument("--output", default="dist")
    args = parser.parse_args()

    root = Path(__file__).resolve().parents[1]
    src = (root / args.src).resolve()
    products = (root / args.products).resolve()
    out = (root / args.output).resolve()

    if out.exists():
        shutil.rmtree(out, onerror=remove_readonly)
    out.mkdir(parents=True)

    catalog_tmp = root / ".catalog-build.json"
    generator = root / "scripts" / "generate_catalog.py"
    rc = subprocess.run([
        sys.executable, str(generator),
        "--products", str(products),
        "--output", str(catalog_tmp),
    ]).returncode
    if rc != 0:
        return rc

    shutil.copy2(src / "html" / "index.html", out / "index.html")
    for folder in ("css", "js", "assets"):
        copytree_contents(src / folder, out / folder)

    (out / "data").mkdir(parents=True, exist_ok=True)
    shutil.copy2(catalog_tmp, out / "data" / "catalog.json")
    if catalog_tmp.exists():
        catalog_tmp.unlink()

    (out / "productos").mkdir(parents=True, exist_ok=True)
    if products.exists():
        for item in products.iterdir():
            if item.is_file():
                shutil.copy2(item, out / "productos" / item.name)

    cname = root / "CNAME"
    if cname.exists():
        shutil.copy2(cname, out / "CNAME")

    print(f"SITE_BUILT: {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
