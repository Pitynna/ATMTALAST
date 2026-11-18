"""Print non-trivial atoms of Ulthor tiles: python tile_dump.py x0 y0 x1 y1"""
import sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM
SKIP = ('/obj/structure/cable', '/obj/machinery/atmospherics/pipe', '/obj/effect/turf_decal', '/obj/structure/disposalpipe', '/area')
m = DMM.from_file(ROOT / '_maps/map_files/Ulthor/Ulthor.dmm')
x0, y0, x1, y1 = map(int, sys.argv[1:5])
for y in range(y1, y0 - 1, -1):
    for x in range(x0, x1 + 1):
        t = [a if ('pixel' in a or 'dir =' in a or 'directional' in a) else a.split('{')[0] for a in m.get_tile((x, y, 1)) if not a.startswith(SKIP)]
        print((x, y), ' | '.join(s[:90] for s in t))
