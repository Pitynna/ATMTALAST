"""Four main corridors on Ulthor (user, 2026-11-19).

North = primary/fore, West = primary/port, South = primary/aft,
East = primary/starboard. Short side corridors are named after the
department they serve (legal, security, service ...). Only area paths of the
listed tiles change; the map is edited in place, never regenerated.

    python tools/ulthor/main_corridors.py          # apply
    python tools/ulthor/main_corridors.py --dry    # report only
"""
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
H = '/area/station/hallway/'
FORE, PORT, AFT, STARBOARD = H + 'primary/fore', H + 'primary/port', H + 'primary/aft', H + 'primary/starboard'
LEGAL, SECURITY = H + 'ulthor_legal', H + 'ulthor_security'


def area(t):
    return t[-1]


def has(t, *prefixes):
    return any(a.startswith(prefixes) for a in t)


def tiled_floor(t):
    return has(t, '/turf/simulated/floor') and not has(t, '/turf/simulated/floor/plating')


def blocked(t):
    return has(t, '/turf/simulated/wall', '/obj/effect/spawner/window', '/obj/structure/grille',
               '/obj/machinery/door/airlock', '/obj/machinery/door/window')


def plan(m):
    tiles = {(x, y): m.get_tile((x, y, z)) for (x, y, z) in m.grid}
    new = {}
    # West: the column from the south corridor up to the north one.
    for p, t in tiles.items():
        a = area(t)
        if a in (H + 'ulthor_service_south', H + 'ulthor_service_center', H + 'ulthor_eva_access'):
            new[p] = PORT
    # South: one band y104-108 from the west corridor to the departures hall.
    for (x, y), t in tiles.items():
        a = area(t)
        if 104 <= y <= 108 and 81 <= x <= 166 and a in (H + 'secondary/entry', H + 'primary/aft', H + 'secondary/exit'):
            new[(x, y)] = AFT
    # Legal: the branch west of the courtroom, down from the south corridor.
    for (x, y), t in tiles.items():
        if area(t) == AFT and 110 <= x <= 120 and y <= 103:
            new[(x, y)] = LEGAL
    # Security: the strip east of the courtroom down to the pod bay.
    for (x, y), t in tiles.items():
        if area(t) == '/area/station/security/lobby' and y <= 103:
            new[(x, y)] = SECURITY
    # East: tiled corridor zoned as maintenance, between the departures hall
    # and the north corridor, plus the glass airlocks at both ends.
    seen, stack = set(), [(162, 135)]
    while stack:
        p = stack.pop()
        if p in seen or p not in tiles:
            continue
        t = tiles[p]
        if not tiled_floor(t) or blocked(t) or not area(t).startswith('/area/station/maintenance'):
            continue
        seen.add(p)
        stack += [(p[0] + 1, p[1]), (p[0] - 1, p[1]), (p[0], p[1] + 1), (p[0], p[1] - 1)]
    for p in seen | {(161, 166), (162, 166), (163, 166), (163, 119), (164, 119), (165, 119)}:
        new[p] = STARBOARD
    return {p: a for p, a in new.items() if area(tiles[p]) != a}


def main():
    m = DMM.from_file(str(MAP))
    changes = plan(m)
    before = Counter()
    for p, a in changes.items():
        before[(area(m.get_tile((*p, 1))).split('/area/station/')[-1], a.split('/area/station/')[-1])] += 1
    for (old, a), n in sorted(before.items()):
        print(f'{n:4d}  {old} -> {a}')
    if '--dry' in sys.argv:
        return
    for (x, y), a in changes.items():
        t = list(m.get_tile((x, y, 1)))
        t[-1] = a
        m.set_tile((x, y, 1), t)
    m.to_file(str(MAP))
    print('changed', len(changes), 'tiles')


if __name__ == '__main__':
    main()
