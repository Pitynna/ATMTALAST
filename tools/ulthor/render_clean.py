"""Render an Ulthor region the way the game draws it, without hidden utilities
(pipes, cables, disposals): wall mounts are drawn at their pixel offsets
(map vars, type vars, or the /directional/<side> helpers, ~24 px), so a
poster with pixel_y = 32 shows up on the wall above, not on the floor.
python render_clean.py out.png x0 y0 x1 y1 [map]"""
import re
import sys
from pathlib import Path

from PIL import Image, ImageDraw

sys.path.insert(0, str(Path(__file__).resolve().parent))
import render_layout as R  # noqa: E402
from check_map import parse_map_atom  # noqa: E402

HIDE = ('/obj/machinery/atmospherics/pipe', '/obj/structure/cable', '/obj/structure/disposalpipe',
        '/obj/effect/landmark', '/obj/effect/spawner/lootdrop', '/obj/machinery/atmospherics/binary',
        '/obj/machinery/atmospherics/trinary', '/obj/machinery/navbeacon', '/obj/effect/mapping_helpers')
for _props in R.PROPS.values():  # goon_decor.dm sets icon through a macro
    if _props.get('icon') == 'GOON_DECOR':
        _props['icon'] = "'icons/obj/goon_decor.dmi'"
DIRECTIONAL = {'north': (0, 24), 'south': (0, -24), 'east': (24, 0), 'west': (-24, 0)}


def offset(atom):
    typ, v = parse_map_atom(atom)
    m = re.search(r'/directional/(north|south|east|west)$', typ)
    dx, dy = DIRECTIONAL[m[1]] if m else (0, 0)
    for k in ('pixel_x', 'pixel_y'):
        val = v.get(k, R.prop(typ, k))
        try:
            val = int(val)
        except (TypeError, ValueError):
            continue
        if k == 'pixel_x':
            dx = val
        else:
            dy = val
    return dx, dy


def layer_key(a):
    if a.startswith('/turf'):
        return 0
    if a.startswith('/obj/effect/turf_decal'):
        return 1
    if a.startswith(('/obj/structure/sign', '/obj/structure/goon', '/obj/machinery/light', '/obj/machinery/alarm',
                     '/obj/machinery/firealarm', '/obj/machinery/power/apc', '/obj/item/radio/intercom')) or '/directional/' in a:
        return 4  # wall objects draw over the wall they hang on
    if a.startswith('/obj/item'):
        return 3
    return 2


def render(mapfile, box, out):
    m, t = R.load(mapfile)
    x0, y0, x1, y1 = box
    scale, pad = 32, 36
    im = Image.new('RGBA', ((x1 - x0 + 1) * scale + pad, (y1 - y0 + 1) * scale + pad), '#111111')
    d = ImageDraw.Draw(im)
    items = []
    for y in range(y1 + 1, y0 - 2, -1):
        for x in range(x0 - 1, x1 + 2):
            for a in t.get((x, y, 1), ()):
                if a.startswith(('/area',) + HIDE):
                    continue
                items.append((layer_key(a), -y, x, a))
    for k, ny, x, a in sorted(items, key=lambda i: (i[0], i[1], i[2])):
        s = R.sprite(a)
        if not s:
            continue
        dx, dy = offset(a) if k else (0, 0)
        px = (x - x0) * scale + pad + dx
        py = (y1 + ny) * scale + pad - dy
        im.alpha_composite(s, (px, py + scale - s.height)) if 0 <= px < im.width and 0 <= py + scale - s.height < im.height else None
    for x in range(x0, x1 + 1):
        d.text(((x - x0) * scale + pad, 12), str(x), fill='white')
    for y in range(y0, y1 + 1):
        d.text((5, (y1 - y) * scale + pad + 8), str(y), fill='white')
    im.convert('RGB').save(out)


if __name__ == '__main__':
    out = sys.argv[1]
    box = tuple(map(int, sys.argv[2:6]))
    mp = sys.argv[6] if len(sys.argv) > 6 else R.ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
    _load = R.load
    R.load = lambda p: (lambda mt: (mt[0], mt[1]))(_load(p))
    render(mp, box, out)
