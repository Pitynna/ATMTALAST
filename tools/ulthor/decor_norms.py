"""Decor density in public areas of Delta, Cyberiad and Ulthor (per 100 floor tiles)."""
import sys, collections
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM
MAPS = {'delta': '_maps/map_files/Delta/delta.dmm', 'cyberiad': '_maps/map_files/cyberiad/cyberiad.dmm',
        'ulthor': '_maps/map_files/Ulthor/Ulthor.dmm'}
KINDS = [('poster', '/obj/structure/sign/poster'), ('sign', '/obj/structure/sign'), ('plant', 'flora'),
         ('bench', 'chair/sofa'), ('bench', 'bench'), ('chair', '/obj/structure/chair'), ('table', '/obj/structure/table'),
         ('decal', '/obj/effect/turf_decal'), ('painting', 'painting'), ('statue', 'statue'), ('carpet', 'floor/carpet'),
         ('wood', 'floor/wood'), ('grass', 'floor/grass'), ('vending', '/obj/machinery/vending'), ('light', '/obj/machinery/light')]
def kind(a):
    for k, p in KINDS:
        if p in a: return k
def classify(area):
    if '/hallway/' in area: return 'hallway'
    if any(k in area for k in ('/service/bar', '/service/library', '/service/chapel', '/crew_quarters', '/service/hydroponics/garden',
                                'commons', 'dorm', 'arcade', 'fitness', 'toilet', 'entry', 'exit', 'lounge', 'cafeteria', 'garden', 'kitchen')): return 'public'
for name, f in MAPS.items():
    m = DMM.from_file(ROOT / f)
    cnt = collections.defaultdict(collections.Counter); tiles = collections.Counter(); turfs = collections.defaultdict(collections.Counter)
    for x in range(1, m.size.x + 1):
        for y in range(1, m.size.y + 1):
            t = m.get_tile((x, y, 1)); a = next(q for q in t if q.startswith('/area'))
            c = classify(a)
            if not c or any(q.startswith(('/turf/simulated/wall', '/turf/space')) for q in t): continue
            tiles[c] += 1
            for o in t:
                b = o.split('{')[0]
                if b.startswith('/turf'): turfs[c][b.replace('/turf/simulated/floor', '')[:30]] += 1
                k = kind(b)
                if k: cnt[c][k] += 1
    for c in tiles:
        print(name, c, tiles[c], {k: round(v * 100 / tiles[c], 1) for k, v in sorted(cnt[c].items())})
        print('   turfs', [(k, v) for k, v in turfs[c].most_common(8)])
