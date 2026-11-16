"""Wall-following zone analysis for Ulthor (read-only unless used by playable.py).

Splits station floor into sub-rooms bounded by walls, windows, doors and
one-tile doorways cut through a wall line, then reports how the existing
areas and APCs fall into them.
"""
import sys
from collections import Counter, deque
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
sys.path.insert(0, str(ROOT / 'tools/ulthor'))
from dmm import DMM  # noqa: E402
from rooms import Station, CARD, area, turf, is_wall, is_boundary, is_floor  # noqa: E402


def blocked(s, x, y):
    t = s.tile(x, y)
    return not s.walkable(x, y)


def pinch(s, x, y):
    """A one-tile doorway through a wall line (no door object)."""
    if not s.walkable(x, y):
        return False
    we = blocked(s, x - 1, y) and blocked(s, x + 1, y)
    ns = blocked(s, x, y - 1) and blocked(s, x, y + 1)
    if we and not ns:
        # passage runs N-S; it is a doorway if both ends open out sideways
        a, b = (x, y + 1), (x, y - 1)
        return all(not (blocked(s, p[0] - 1, p[1]) and blocked(s, p[0] + 1, p[1])) for p in (a, b))
    if ns and not we:
        a, b = (x + 1, y), (x - 1, y)
        return all(not (blocked(s, p[0], p[1] - 1) and blocked(s, p[0], p[1] + 1)) for p in (a, b))
    return False


def local_width(s, x, y):
    def run(dx, dy):
        n = 1
        for sgn in (1, -1):
            k = 1
            while s.walkable(x + dx * k * sgn, y + dy * k * sgn) and k < 30:
                k += 1
            n += k - 1
        return n
    return min(run(1, 0), run(0, 1))


def subrooms(s):
    pinches = {(x, y) for y in range(1, s.Y + 1) for x in range(1, s.X + 1) if pinch(s, x, y)}
    seen = set(pinches)
    out = []
    for y in range(1, s.Y + 1):
        for x in range(1, s.X + 1):
            if (x, y) in seen or not s.walkable(x, y):
                continue
            comp = []
            q = deque([(x, y)])
            seen.add((x, y))
            while q:
                p = q.popleft()
                comp.append(p)
                for dx, dy, _ in CARD:
                    n = (p[0] + dx, p[1] + dy)
                    if n not in seen and s.walkable(*n):
                        seen.add(n)
                        q.append(n)
            out.append(comp)
    return out, pinches


def apcs(s):
    res = {}
    for (x, y, z), k in s.m.grid.items():
        if any(a.startswith('/obj/machinery/power/apc') for a in s.m.dictionary[k]):
            res[(x, y)] = s.m.dictionary[k][-1]
    return res


def classify(s, comp):
    plating = sum('plating' in turf(s.tile(*p)) for p in comp) / len(comp)
    areas = Counter(area(s.tile(*p)) for p in comp)
    hall = sum(n for a, n in areas.items() if '/hallway/' in a)
    widths = sorted(local_width(s, *p) for p in comp)
    med = widths[len(widths) // 2]
    if plating >= 0.5 or sum(n for a, n in areas.items() if '/maintenance' in a) > len(comp) / 2:
        return 'maint'
    if hall > len(comp) / 2 or (len(comp) >= 25 and med <= 3):
        return 'corridor'
    return 'room'


if __name__ == '__main__':
    s = Station(DMM.from_file(str(ROOT / '_maps/map_files/Ulthor/Ulthor.dmm')))
    subs, pinches = subrooms(s)
    ap = apcs(s)
    print('subrooms', len(subs), 'pinches', len(pinches))
    for comp in sorted(subs, key=len, reverse=True):
        areas = Counter(area(s.tile(*p)) for p in comp)
        if len(areas) < 2 and not sys.argv[1:]:
            continue
        kind = classify(s, comp)
        xs = [p[0] for p in comp]; ys = [p[1] for p in comp]
        here = sorted({ap[p].replace('/area/station/', '') for p in comp if p in ap})
        print(f'{kind:8s} {len(comp):4d} {(min(xs), min(ys), max(xs), max(ys))} apc={here}')
        print('         ', [(a.replace('/area/station/', ''), n) for a, n in areas.most_common(6)])
