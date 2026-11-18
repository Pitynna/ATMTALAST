"""Report Ulthor tiles where two wall-mounted objects hang on the same wall spot.
python wallmount_overlaps.py [map]"""
import sys
from collections import defaultdict
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
import wallmounts as W
from dmm import DMM
m = DMM.from_file(sys.argv[1] if len(sys.argv) > 1 else W.MAP)
f = W.Fixer(m)
DSIDE = {'north': 'N', 'south': 'S', 'east': 'E', 'west': 'W'}
bad = 0
for (x, y, z), key in sorted(m.grid.items()):
    spots = defaultdict(list)
    for a in m.dictionary[key]:
        base, pairs = W.split_atom(a)
        if not base.startswith('/obj') or base.startswith(('/obj/machinery/light', '/obj/structure/sign', '/obj/machinery/camera')):
            continue
        if '/directional/' in base:
            b, d = base.rsplit('/directional/', 1)
            if d not in DSIDE or (b not in W.HELPER and not b.startswith('/obj/item/radio/intercom')):
                continue
            s, lat = DSIDE[d], 0
        elif f.kind(base) == 'fixed':
            px, py = W.getv(pairs, 'pixel_x'), W.getv(pairs, 'pixel_y')
            s = W.side_of(px, py)
            if s is None or max(abs(px), abs(py)) < 20:
                continue
            lat = py if s in 'EW' else px
        else:
            continue
        spots[s].append((lat, base))
    for s, items in spots.items():
        for i in range(len(items)):
            for j in range(i + 1, len(items)):
                if abs(items[i][0] - items[j][0]) < 10:
                    bad += 1
                    print((x, y), s, items[i][1], items[j][1])
print('overlaps:', bad)
