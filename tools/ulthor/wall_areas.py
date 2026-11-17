"""Walls and windows belong to the room they enclose (user, 2026-11-17).

A wall/window tile (doors excluded) whose area does not touch any floor of
that same area - e.g. the outer wall of a maintenance hall left in the
detective's office zone - gets the area of the floor it does touch (8
neighbours) - the room it is a side of; a wall that only touches rooms by a
corner follows its wall neighbours. Between two rooms the one with more touching floor wins; on a
tie maintenance wins (it owns walls towards space and towards departments).
Walls that touch no floor at all (outer corners) follow their wall
neighbours. Only area paths change. Shuttles and space are left alone.
"""
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
sys.path.insert(0, str(Path(__file__).resolve().parent))
from dmm import DMM  # noqa: E402
from rooms import Station, MAP, area, is_wall, is_floor, is_boundary, is_door  # noqa: E402

N8 = [(dx, dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1) if dx or dy]
N4 = [(1, 0), (-1, 0), (0, 1), (0, -1)]


def station(a):
    return not a.startswith(('/area/space', '/area/shuttle'))


def solid(t):
    return (is_wall(t) or is_boundary(t)) and not is_door(t)


def open_floor(t):
    return is_floor(t) and not is_boundary(t) and not is_wall(t)


def main():
    m = DMM.from_file(str(MAP))
    st = Station(m)
    cur = {(x, y): area(m.get_tile((x, y, z))) for (x, y, z) in m.grid}
    walls = [(x, y) for (x, y, z) in m.grid if solid(m.get_tile((x, y, z))) and station(cur[(x, y)])]
    changed = {}

    def floor_areas(p, around=N8):
        c = Counter()
        for dx, dy in around:
            q = (p[0] + dx, p[1] + dy)
            t = st.tile(*q)
            if open_floor(t) and station(area(t)):
                c[area(t)] += 1
        return c

    def pick(c):
        top = max(c.values())
        best = sorted(a for a, n in c.items() if n == top)
        maint = [a for a in best if a.startswith('/area/station/maintenance')]
        return (maint or best)[0]

    corners = []
    for p in walls:
        if cur[p] in floor_areas(p):
            continue
        side = floor_areas(p, N4)  # rooms it is a side of, not just a corner of
        if side:
            changed[p] = pick(side)
        else:
            corners.append(p)
    cur.update(changed)
    for _ in range(3):  # corners follow neighbouring walls
        for p in corners:
            c = Counter(cur[(p[0] + dx, p[1] + dy)] for dx, dy in N8
                        if (p[0] + dx, p[1] + dy) in cur and solid(st.tile(p[0] + dx, p[1] + dy))
                        and station(cur[(p[0] + dx, p[1] + dy)]))
            if c and cur[p] not in c:
                cur[p] = changed[p] = pick(c)
    before = {p: area(m.get_tile((p[0], p[1], 1))) for p in changed}
    for (x, y), a in changed.items():
        tile = list(m.get_tile((x, y, 1)))
        tile[-1] = a
        m.set_tile((x, y, 1), tuple(tile))
    m.to_file(str(MAP))
    print('walls re-assigned:', len(changed))
    moves = Counter((before[p].split('station/')[-1], a.split('station/')[-1]) for p, a in changed.items())
    for (a, b), n in moves.most_common():
        print(f'  {n:3} {a} -> {b}')


if __name__ == '__main__':
    main()
