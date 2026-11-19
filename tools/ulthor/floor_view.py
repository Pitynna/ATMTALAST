"""Print plasteel icon_state/dir codes for a region: python floor_view.py map x0 y0 x1 y1"""
import sys, re
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM
m = DMM.from_file(ROOT / sys.argv[1]); x0, y0, x1, y1 = map(int, sys.argv[2:6])
for y in range(y1, y0 - 1, -1):
    row = []
    for x in range(x0, x1 + 1):
        t = m.get_tile((x, y, 1)); c = '  .  '
        for o in t:
            if o.startswith(('/turf/simulated/wall', '/turf/simulated/mineral')): c = '#####'
            elif o.startswith('/turf/simulated/floor/plasteel'):
                s = re.search(r'icon_state = "([^"]+)"', o); d = re.search(r'dir = (\d+)', o)
                c = ((s.group(1) if s else 'pl')[:3] + (d.group(1) if d else '')).ljust(5)[:5]
            elif o.startswith('/turf/simulated/floor'): c = o.split('/')[-1].split('{')[0][:5].ljust(5)
        if any(o.startswith('/obj/machinery/door') and 'firedoor' not in o for o in t): c = 'DOOR '
        row.append(c)
    print(f'{y:3d}', ' '.join(row))
