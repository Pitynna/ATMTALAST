"""Room segmentation helpers for Ulthor map tooling (read-only on its own).

A room is a 4-connected region of floor tiles bounded by walls, space,
windows/grilles and doors (airlocks, window doors, blast doors).
"""
import sys
from collections import Counter, deque
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
CARD = [(0, 1, 1), (0, -1, 2), (1, 0, 4), (-1, 0, 8)]
BOUNDARY = ('/obj/machinery/door/airlock', '/obj/machinery/door/window', '/obj/machinery/door/poddoor',
            '/obj/machinery/door/unpowered', '/obj/machinery/door/morgue', '/obj/effect/spawner/window',
            '/obj/structure/window/full', '/obj/structure/window/reinforced/fulltile', '/obj/structure/window/plasmareinforced/fulltile',
            '/obj/structure/grille', '/obj/structure/falsewall', '/obj/machinery/door/password', '/obj/machinery/door/airlock')


def turf(tile):
    return next(a for a in tile if a.startswith('/turf'))


def area(tile):
    return tile[-1]


def is_wall(tile):
    t = turf(tile)
    return t.startswith(('/turf/simulated/wall', '/turf/unsimulated/wall', '/turf/simulated/mineral')) or 'wall' in t.split('{')[0].rsplit('/', 1)[-1]


def is_floor(tile):
    t = turf(tile).split('{')[0]
    return t.startswith(('/turf/simulated/floor', '/turf/unsimulated/floor')) and not is_wall(tile)


def is_boundary(tile):
    return any(a.startswith(BOUNDARY) for a in tile)


def is_door(tile):
    return any(a.startswith(('/obj/machinery/door/airlock', '/obj/machinery/door/window', '/obj/machinery/door/poddoor', '/obj/machinery/door/unpowered', '/obj/machinery/door/password')) for a in tile)


class Station:
    def __init__(self, dmm):
        self.m = dmm
        self.X, self.Y, _ = dmm.size

    def tile(self, x, y):
        if not (1 <= x <= self.X and 1 <= y <= self.Y):
            return ('/turf/space', '/area/space')
        return self.m.get_tile((x, y, 1))

    def walkable(self, x, y):
        t = self.tile(x, y)
        return is_floor(t) and not is_boundary(t) and area(t).startswith('/area/station')

    def rooms(self):
        seen = set()
        result = []
        for y in range(1, self.Y + 1):
            for x in range(1, self.X + 1):
                if (x, y) in seen or not self.walkable(x, y):
                    continue
                comp = []
                q = deque([(x, y)])
                seen.add((x, y))
                while q:
                    p = q.popleft()
                    comp.append(p)
                    for dx, dy, _ in CARD:
                        n = (p[0] + dx, p[1] + dy)
                        if n not in seen and self.walkable(*n):
                            seen.add(n)
                            q.append(n)
                result.append(comp)
        return result

    def describe(self, comp):
        areas = Counter(area(self.tile(*p)) for p in comp)
        plating = sum('plating' in turf(self.tile(*p)) for p in comp) / len(comp)
        return areas, plating


if __name__ == '__main__':
    s = Station(DMM.from_file(str(MAP)))
    rs = sorted(s.rooms(), key=len, reverse=True)
    for comp in rs[:int(sys.argv[1]) if len(sys.argv) > 1 else 40]:
        areas, plating = s.describe(comp)
        xs = [p[0] for p in comp]; ys = [p[1] for p in comp]
        print(len(comp), (min(xs), min(ys), max(xs), max(ys)), f'plating={plating:.2f}', [(a.replace('/area/station/', ''), n) for a, n in areas.most_common(3)])
    print('rooms', len(rs))
