"""Segredos só no servidor — env ou arquivo. Nunca no celular."""
from __future__ import annotations

import json
import os
from pathlib import Path


def _load_json(path: Path) -> dict:
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return {}


def env_or_file(env_key: str, *file_keys: str, default: str = "") -> str:
    v = (os.environ.get(env_key) or "").strip()
    if v:
        return v
    # optional local secrets (dev)
    for base in (Path("/home/data/secrets"), Path(__file__).resolve().parent.parent / "secrets"):
        d = _load_json(base / "comandos.json") if (base / "comandos.json").exists() else {}
        for k in file_keys:
            cur = d
            ok = True
            for part in k.split("."):
                if isinstance(cur, dict) and part in cur:
                    cur = cur[part]
                else:
                    ok = False
                    break
            if ok and cur:
                return str(cur).strip()
    return default
