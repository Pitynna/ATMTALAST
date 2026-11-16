"""Add escape pod docks pod2 (west end of the north corridor) and pod3 (south
wall of the aft plating hall) to Ulthor as an incremental edit of the current
map. Pods themselves live on CentComm and fly to "podN_home" at round start
(code/modules/shuttle/emergency.dm, roundstart_move); the station only needs
the stationary dock, an external airlock next to it and an approach.

A stationary dock covers width 5 x height 6 tiles starting at its own tile and
extending in its dir (away from the station); the pod hatch lands on the dock
tile, right outside the station airlock. Idempotent: does nothing when the
docks are already on the map.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
FORE = '/area/station/hallway/primary/fore'
AFT = '/area/station/hallway/primary/aft'
WEST_MAINT = '/area/station/maintenance/ulthor_west_passage'
FLOOR = '/turf/simulated/floor/plasteel{dir = 8;icon_state = "neutralfull"}'
PLATING = '/turf/simulated/floor/plating'
WALL = '/turf/simulated/wall'
SPACE = '/turf/space'
MAINT_DOOR = '/obj/machinery/door/airlock/maintenance{req_access = list(12);check_one_access = 0}'
SIGN = '/obj/structure/sign/pods'


def dock(n, d):
    return ('/obj/docking_port/stationary{dir = %d;dwidth = 2;height = 6;id = "pod%d_home";'
            'name = "pod%d home dock";width = 5}' % (d, n, n))


def hatch(n, d):
    return ['/obj/machinery/door/airlock/external{name = "Escape Pod Airlock"}',
            '/obj/effect/turf_decal/stripes/line{dir = %d}' % d,
            '/obj/structure/fans/tiny',
            '/obj/effect/landmark/navigate_destination/dockescpod%d' % n]


def footprint(x, y, d):
    """Tiles a 5x6 pod covers for a dock at (x, y) facing d (dwidth 2)."""
    if d == 8:
        return [(i, j) for i in range(x - 5, x + 1) for j in range(y - 2, y + 3)]
    if d == 2:
        return [(i, j) for i in range(x - 2, x + 3) for j in range(y - 5, y + 1)]
    raise ValueError(d)


def main():
    m = DMM.from_file(str(MAP))
    t = {(x, y): list(m.get_tile((x, y, 1))) for (x, y, z) in m.grid}
    if any('pod2_home' in a or 'pod3_home' in a for tile in t.values() for a in tile):
        print('escape pods already present')
        return 0

    def objs(p):
        return [a for a in t[p] if a.startswith('/obj')]

    def put(p, atoms, turf, area):
        t[p] = atoms + [turf, area]

    for (x, y, d) in ((69, 170, 8), (99, 91, 2)):
        for p in footprint(x, y, d):
            assert t[p] == [SPACE, '/area/space'], (p, t[p])

    # pod2: west end of the north corridor. The corridor gets a door through
    # its west wall into a 2x3 lobby cut out of the west maintenance passage;
    # the passage keeps going through maintenance doors north and south of it.
    t[(74, 170)] = [a for a in t[(74, 170)] if not a.startswith('/obj/structure/table')]
    put((73, 170), ['/obj/machinery/door/airlock/public/glass{name = "Escape Pods"}'], FLOOR, FORE)
    for x in (71, 72):
        for y in (169, 170, 171):
            assert not objs((x, y)), ((x, y), t[(x, y)])
            put((x, y), [], FLOOR, FORE)
    put((72, 171), ['/obj/machinery/light{dir = 1}'], FLOOR, FORE)
    put((71, 170), ['/obj/effect/turf_decal/stripes/line{dir = 8}'], FLOOR, FORE)
    # The maintenance air alarm sat on (72,168), which becomes wall.
    alarm = next(a for a in t[(72, 168)] if a.startswith('/obj/machinery/alarm'))
    assert not objs((71, 166)), t[(71, 166)]
    put((71, 166), ['/obj/machinery/alarm{dir = 8;pixel_x = -24;pixel_y = 0}'], PLATING, WEST_MAINT)
    assert alarm
    for y in (168, 172):
        put((71, y), [MAINT_DOOR], PLATING, WEST_MAINT)
        put((72, y), [], WALL, WEST_MAINT)
    put((70, 170), hatch(2, 8), '/turf/simulated/floor/plasteel', FORE)
    put((69, 170), [dock(2, 8)], SPACE, '/area/space')
    t[(73, 171)].insert(0, SIGN)

    # pod3: south wall of the aft plating hall.
    put((99, 92), hatch(3, 2), '/turf/simulated/floor/plasteel', AFT)
    put((99, 91), [dock(3, 2)], SPACE, '/area/space')
    t[(98, 92)].insert(0, SIGN)
    t[(100, 93)].insert(0, '/obj/machinery/light{dir = 2}')

    for (x, y), tile in t.items():
        if tuple(tile) != m.get_tile((x, y, 1)):
            m.set_tile((x, y, 1), tuple(tile))
    m.to_file(str(MAP))
    print('added pod2_home (69,170) and pod3_home (99,91)')
    return 0


if __name__ == '__main__':
    sys.exit(main())
