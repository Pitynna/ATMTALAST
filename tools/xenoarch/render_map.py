"""Approximate PNG render of a map region from the project's own icons.

Resolves icon/icon_state/dir/pixel offsets/color from map vars and DM type
definitions (with inheritance). Icons changed at runtime are not reproduced.

Usage: python tools/xenoarch/render_map.py MAP OUT.png x0 y0 x1 y1 [scale]
"""
import re
import sys
from functools import lru_cache
from pathlib import Path

from PIL import Image, ImageColor

sys.path.insert(0, str(Path(__file__).resolve().parent))
from dmi import ROOT, read_states  # noqa: E402
from dmm import DMM, atom_type, atom_vars  # noqa: E402

DEF = re.compile(r'^(/[A-Za-z0-9_/]+)\s*(?://.*)?$')
VAR = re.compile(r"^\t(icon|icon_state|layer|plane|color|base_icon_state|post_init_icon_state)\s*=\s*(.+?)\s*(?://.*)?$")
LAYERS = {'TURF_LAYER': 2, 'ABOVE_OBJ_LAYER': 3.2, 'OBJ_LAYER': 3, 'MOB_LAYER': 4, 'BELOW_OBJ_LAYER': 2.9,
          'WIRE_LAYER': 2.44, 'GAS_PIPE_HIDDEN_LAYER': 2.35, 'GAS_PIPE_VISIBLE_LAYER': 2.47,
          'DISPOSAL_PIPE_LAYER': 2.3, 'LOW_OBJ_LAYER': 2.5, 'ABOVE_MOB_LAYER': 4.1, 'WALL_OBJ_LAYER': 3.25}


def load_defs():
    defs = {}
    for path in (ROOT / 'code').rglob('*.dm'):
        current = None
        for line in path.read_text(encoding='utf-8', errors='replace').splitlines():
            m = DEF.match(line)
            if m:
                current = m.group(1)
                if '/proc/' in current or '/verb/' in current:
                    current = None
                continue
            if current is None:
                continue
            if line and not line.startswith('\t'):
                current = None
                continue
            v = VAR.match(line)
            if v:
                defs.setdefault(current, {})[v.group(1)] = v.group(2)
    return defs


DEFS = None


def resolve(path, name):
    p = path
    while p:
        value = DEFS.get(p, {}).get(name)
        if value is not None:
            return value
        p = p.rsplit('/', 1)[0] if p.count('/') > 1 else ''
    return None


@lru_cache(maxsize=None)
def sheet(icon):
    try:
        return read_states(icon)[0]
    except Exception:
        return {}


DIR_INDEX = {2: 0, 1: 1, 4: 2, 8: 3, 6: 4, 10: 5, 5: 6, 9: 7}


def sprite(icon, state, d):
    states = sheet(icon)
    st = states.get(state) or states.get('')
    if not st:
        return None
    idx = DIR_INDEX.get(d, 0) if st['dirs'] > 1 else 0
    if idx >= st['dirs']:
        idx = 0
    return st['images'][idx]


def unq(v):
    return v.strip().strip('"').strip("'") if v else v


def layer_of(path, v):
    raw = v.get('layer') or resolve(path, 'layer')
    if raw:
        raw = raw.split('+')[0].split('-')[0].strip()
        try:
            return float(raw)
        except ValueError:
            return LAYERS.get(raw, 3)
    if path.startswith('/turf'):
        return 2
    if path.startswith('/mob'):
        return 4
    return 3


def main(map_path, out_path, x0, y0, x1, y1, scale=1):
    global DEFS
    DEFS = load_defs()
    m = DMM.load(map_path)
    x0, y0, x1, y1, scale = int(x0), int(y0), int(x1), int(y1), int(scale)
    w, h = (x1 - x0 + 1) * 32, (y1 - y0 + 1) * 32
    canvas = Image.new('RGBA', (w, h), (0, 0, 0, 255))
    draws = []
    for x in range(x0, x1 + 1):
        for y in range(y0, y1 + 1):
            for a in m.tile(x, y):
                path = atom_type(a)
                if path.startswith('/area'):
                    continue
                v = atom_vars(a)
                icon = unq(v.get('icon') or resolve(path, 'icon'))
                state = unq(v.get('icon_state') or resolve(path, 'post_init_icon_state') or resolve(path, 'icon_state') or '')
                if state.startswith('/'):
                    state = unq(resolve(path, 'post_init_icon_state')) or ''
                if not icon:
                    continue
                img = sprite(icon, state, int(v.get('dir', '2')))
                if img is None:
                    continue
                colour = unq(v.get('color') or resolve(path, 'color'))
                if colour and colour.startswith('#'):
                    tint = Image.new('RGBA', img.size, ImageColor.getrgb(colour) + (255,))
                    img = Image.composite(Image.blend(img, tint, 0.5), img, img)
                px = int(float(v.get('pixel_x', '0') or 0))
                py = int(float(v.get('pixel_y', '0') or 0))
                draws.append((layer_of(path, v), -y, x, img, px, py))
    draws.sort(key=lambda d: (d[0], d[1]))
    for layer, ny, x, img, px, py in draws:
        y = -ny
        cx = (x - x0) * 32 + px
        cy = (y1 - y) * 32 - py - (img.height - 32)
        canvas.alpha_composite(img, (max(cx, 0), max(cy, 0)), (max(-cx, 0), max(-cy, 0)))
    if scale != 1:
        canvas = canvas.resize((w * scale, h * scale), Image.NEAREST)
    canvas.save(out_path)
    print('saved', out_path, canvas.size)


if __name__ == '__main__':
    main(*sys.argv[1:])
