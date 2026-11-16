"""Static AI camera coverage: which station floor tiles no camera can see.

Approximates the cameranet: every camera outside restricted networks sees the
tiles within Chebyshev radius 7 that are in line of sight (opaque: walls, false
walls, non-glass airlocks, blast doors/shutters, opaque flaps). A tile counts as
seen when any of several rays from the camera tile reaches it unobstructed,
which is close to BYOND's view(). Maintenance and solar arrays are excluded.

Usage: python -I tools/ulthor/camera_coverage.py [map.dmm ...] [--png out.png] [--rooms N]
"""
import math
import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
sys.path.insert(0, str(ROOT / 'tools/ulthor'))
from dmm import DMM  # noqa: E402
from rooms import Station, turf, area, is_wall  # noqa: E402

RESTRICTED = {'CentComm', 'ERT', 'NukeOps', 'Thunderdome', 'thunder', 'Mining Outpost', 'Labor', 'Telecomms', 'mortar'}
RANGE = 7
OPAQUE_OBJ = ('/obj/structure/falsewall', '/obj/machinery/door/poddoor', '/obj/structure/plasticflaps/opaque',
              '/obj/structure/mineral_door', '/obj/machinery/door/password')


def opaque(tile):
    if is_wall(tile) or 'mineral' in turf(tile):
        return True
    for a in tile:
        p = a.split('{')[0]
        if p.startswith(OPAQUE_OBJ):
            if '/preopen' in p or 'density = 0' in a or 'opacity = 0' in a:
                continue
            return True
        if p.startswith('/obj/machinery/door/airlock') and '/glass' not in p and 'glass = 1' not in a and 'opacity = 0' not in a:
            return True
    return False


def watched(a, comp, plating):
    """Rooms the AI is expected to see (reference maps leave these blind too)."""
    return not ('/maintenance' in a or '/solars' in a or plating >= 0.5 or 'toilet' in a or 'bedroom' in a
                or len(comp) < 6)


def cameras(dmm):
    out = []
    for (x, y, z), k in dmm.grid.items():
        for a in dmm.dictionary[k]:
            if a.startswith('/obj/machinery/camera') and not a.startswith('/obj/machinery/camera_'):
                nets = re.findall(r'"([^"]+)"', (re.search(r'network = list\(([^)]*)\)', a) or [None, '"SS13"'])[1])
                if 'xray' in a.split('{')[0] or not nets or any(n not in RESTRICTED for n in nets):
                    out.append((x, y))
    return out


class Vision:
    """Line-of-sight helper over a Station (cache invalidated by the caller)."""
    def __init__(self, s):
        self.s = s
        self.opq = {}

    def is_opq(self, x, y):
        if (x, y) not in self.opq:
            self.opq[(x, y)] = opaque(self.s.tile(x, y))
        return self.opq[(x, y)]

    def clear(self, cx, cy, tx, ty):
        for ox, oy in ((0, 0), (-.45, -.45), (.45, .45), (-.45, .45), (.45, -.45)):
            ex, ey = tx + ox, ty + oy
            n = int(max(abs(ex - cx), abs(ey - cy)) * 3) + 1
            ok = True
            for i in range(1, n):
                px = round(cx + (ex - cx) * i / n)
                py = round(cy + (ey - cy) * i / n)
                if (px, py) in ((cx, cy), (tx, ty)):
                    continue
                if self.is_opq(px, py):
                    ok = False
                    break
            if ok:
                return True
        return False

    def sees(self, cx, cy, targets=None):
        out = set()
        for tx in range(cx - RANGE, cx + RANGE + 1):
            for ty in range(cy - RANGE, cy + RANGE + 1):
                if (targets is None or (tx, ty) in targets) and self.clear(cx, cy, tx, ty):
                    out.add((tx, ty))
        return out


def coverage(path):
    dmm = DMM.from_file(str(path)) if not isinstance(path, DMM) else path
    s = Station(dmm)
    v = Vision(s)
    seen = set()
    cams = cameras(dmm)
    for cx, cy in cams:
        seen |= v.sees(cx, cy)
    rooms = s.rooms()
    blind_rooms = []
    total = covered = 0
    for comp in rooms:
        a = Counter(area(s.tile(*p)) for p in comp).most_common(1)[0][0]
        plating = sum('plating' in turf(s.tile(*p)) for p in comp) / len(comp)
        if not watched(a, comp, plating):
            continue
        blind = [p for p in comp if p not in seen]
        total += len(comp)
        covered += len(comp) - len(blind)
        if blind:
            blind_rooms.append((len(blind), len(comp), a, blind))
    blind_rooms.sort(key=lambda r: -r[0])
    return s, cams, seen, total, covered, blind_rooms


def main():
    args = sys.argv[1:]
    png = args[args.index('--png') + 1] if '--png' in args else None
    nrooms = int(args[args.index('--rooms') + 1]) if '--rooms' in args else 25
    maps = [a for a in args if a.endswith('.dmm')] or [str(ROOT / '_maps/map_files/Ulthor/Ulthor.dmm')]
    for path in maps:
        s, cams, seen, total, covered, blind = coverage(path)
        print(f'{Path(path).name}: {len(cams)} cameras, {covered}/{total} non-maint floor tiles seen ({100 * covered / total:.1f}%)')
        for n, size, a, tiles in blind[:nrooms]:
            xs = [p[0] for p in tiles]; ys = [p[1] for p in tiles]
            print(f'  {n:4d}/{size:<4d} {a.replace("/area/station/", "")[:55]:55s} blind box {min(xs)},{min(ys)}-{max(xs)},{max(ys)}')
        if png:
            from PIL import Image, ImageDraw
            sc = 6
            im = Image.new('RGB', (s.X * sc, s.Y * sc), '#000')
            d = ImageDraw.Draw(im)
            blind_set = {p for b in blind for p in b[3]}
            for y in range(1, s.Y + 1):
                for x in range(1, s.X + 1):
                    t = s.tile(x, y)
                    c = None
                    if (x, y) in blind_set:
                        c = '#e02020'
                    elif is_wall(t):
                        c = '#777'
                    elif s.walkable(x, y):
                        c = '#2a6' if (x, y) in seen else '#334'
                    if c:
                        d.rectangle(((x - 1) * sc, (s.Y - y) * sc, x * sc - 1, (s.Y - y + 1) * sc - 1), fill=c)
            for x, y in cams:
                d.ellipse(((x - 1) * sc, (s.Y - y) * sc, x * sc, (s.Y - y + 1) * sc), fill='#ff0')
            im.save(png)


if __name__ == '__main__':
    main()
