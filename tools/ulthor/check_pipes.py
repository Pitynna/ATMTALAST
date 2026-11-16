"""Static pipe-topology check for Ulthor: one-sided links and same-network pipes
sharing a direction on one tile (the "pipes stacking in one turf" runtime)."""
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM  # noqa: E402

N, S, E, W = 1, 2, 4, 8
DELTA = {N: (0, 1), S: (0, -1), E: (1, 0), W: (-1, 0)}
REV = {N: S, S: N, E: W, W: E}


def parse(atom):
    path = atom.split('{')[0]
    if not path.startswith('/obj/machinery/atmospherics'):
        return None
    d = re.search(r'\bdir = (\d+)', atom)
    d = int(d[1]) if d else 2
    if '/supply' in path:
        ct = {2}
    elif '/scrubbers' in path:
        ct = {3}
    elif '/unary/vent_pump' in path:
        ct = {1, 2}
    elif '/unary/vent_scrubber' in path:
        ct = {1, 3}
    else:
        ct = {1}
    if '/pipe/simple' in path:
        if d in (1, 2): dirs = N | S
        elif d in (4, 8): dirs = E | W
        else: dirs = d
    elif '/pipe/manifold4w' in path:
        dirs = N | S | E | W
    elif '/pipe/manifold' in path:
        dirs = (N | S | E | W) & ~d
    elif '/pipe/cap' in path or '/unary/' in path:
        dirs = d
    elif '/binary/' in path or '/trinary/' in path or '/omni' in path:
        return None  # devices with their own rules: ignore
    else:
        return None
    m = re.search(r'connect_types = list\(([\d, ]+)\)', atom)
    if m:
        ct = {int(v) for v in m[1].split(',')}
    if '/heat_exchanging' in path:
        ct = {'he'}
    if '/universal' in path:
        ct = {1, 2, 3}
    return path, dirs, ct


def scan(path):
    m = DMM.from_file(str(path))
    by_tile = defaultdict(list)
    for (x, y, z), k in m.grid.items():
        for a in m.dictionary[k]:
            p = parse(a)
            if p:
                by_tile[(x, y)].append(p)
    stacked, onesided = [], []
    for t, items in by_tile.items():
        for i in range(len(items)):
            for j in range(i + 1, len(items)):
                a, b = items[i], items[j]
                if a[2] & b[2] and a[1] & b[1]:
                    stacked.append((t, a[0], b[0]))
        for path_, dirs, ct in items:
            for d, (dx, dy) in DELTA.items():
                if not dirs & d:
                    continue
                n = (t[0] + dx, t[1] + dy)
                partners = [q for q in by_tile.get(n, []) if q[2] & ct and q[1] & REV[d]]
                if len(partners) > 1:
                    stacked.append((n, 'two partners for', path_))
    return stacked


if __name__ == '__main__':
    target = sys.argv[1] if len(sys.argv) > 1 else ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
    st = scan(target)
    for s in st:
        print(s)
    print('stacked/duplicate links:', len(st))
