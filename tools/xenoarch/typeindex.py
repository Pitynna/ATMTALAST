"""Index of type paths defined in the project's DM code."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEF = re.compile(r'^(/[A-Za-z0-9_/]+)\s*(?:$|//|\{)')


def load_types():
    types = set()
    for path in (ROOT / 'code').rglob('*.dm'):
        for line in path.read_text(encoding='utf-8', errors='replace').splitlines():
            m = DEF.match(line)
            if not m:
                continue
            t = m.group(1).rstrip('/')
            if '/proc/' in t or '/verb/' in t or t.endswith('/proc') or t.endswith('/verb'):
                continue
            parts = t.split('/')
            for i in range(2, len(parts) + 1):
                types.add('/'.join(parts[:i]))
    return types
