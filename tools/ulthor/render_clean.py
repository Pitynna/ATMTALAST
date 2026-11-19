"""Render an Ulthor region without hidden utilities (pipes, cables, disposals),
so floor paint and furniture are readable.
python render_clean.py out.png x0 y0 x1 y1 [map]"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import render_layout  # noqa: E402

HIDE = ('/obj/machinery/atmospherics/pipe', '/obj/structure/cable', '/obj/structure/disposalpipe',
        '/obj/effect/landmark', '/obj/effect/spawner/lootdrop', '/obj/machinery/atmospherics/binary',
        '/obj/machinery/atmospherics/trinary')
_load = render_layout.load


def clean_load(path):
    m, t = _load(path)
    return m, {p: tuple(a for a in tile if not a.startswith(HIDE)) for p, tile in t.items()}


render_layout.load = clean_load
for _props in render_layout.PROPS.values():  # goon_decor.dm sets icon through a macro
    if _props.get('icon') == 'GOON_DECOR':
        _props['icon'] = "'icons/obj/goon_decor.dmi'"

if __name__ == '__main__':
    out = sys.argv[1]
    box = tuple(map(int, sys.argv[2:6]))
    mp = sys.argv[6] if len(sys.argv) > 6 else render_layout.ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
    render_layout.render(mp, box, out, False)
