"""Place the trade freighter and its docks.

Ulthor: trade bay hatch in the west wall of the QM warehouse (73,116) and the
station docking port in space next to it (72,116).
CentCom: the freighter itself, 8x6, parked in open space east of the supply
dock, hatch and ports at (232,84).

Usage: python tools/trade/place_trade_freighter.py          (report only)
       python tools/trade/place_trade_freighter.py --write  (edit the maps)

Edits are incremental on the current map files. The script refuses to write if
a target tile is not what it expects, so it never overwrites other work, and a
second run changes nothing.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM  # noqa: E402

ULTHOR = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
CENTCOM = ROOT / '_maps/map_files/generic/CentComm.dmm'

PORT = 'dir = 8;dwidth = 4;height = 8'
STATION_PORT = '/obj/docking_port/stationary{' + PORT + ';id = "trade_freighter_home";name = "trade bay";width = 6}'
AWAY_PORT = '/obj/docking_port/stationary{' + PORT + ';id = "trade_freighter_away";name = "trade freighter bay";width = 6}'
MOBILE_PORT = '/obj/docking_port/mobile/trade_freighter'

SPACE = ('/turf/space', '/area/space')
AREA = '/area/shuttle/trade_freighter'
WALL = '/turf/simulated/wall/shuttle'
FLOOR = '/turf/simulated/floor/shuttle'
PLATING = '/turf/simulated/floor/shuttle/plating'


def freighter_tile(lx, ly):
    """Tile of the freighter at local coords, x 0..7 west to east, y 0..5 south to north."""
    if lx == 0:
        if ly in (0, 5):
            return None  # corners stay space
        return ('/obj/structure/shuttle/engine/propulsion{dir = 8}', PLATING, AREA)
    if ly in (0, 5):
        return (WALL, AREA)
    if lx == 1:
        return ('/obj/structure/window/reinforced{dir = 4}', '/obj/structure/shuttle/engine/heater{dir = 8}', PLATING, AREA)
    if lx == 7:
        if ly == 4:
            return ('/obj/machinery/door/airlock/external/trade_freighter', MOBILE_PORT, AWAY_PORT, FLOOR, AREA)
        return (WALL, AREA)
    if (lx, ly) == (4, 4):
        return ('/obj/machinery/light/spot{dir = 1}', FLOOR, AREA)
    if (lx, ly) == (4, 1):
        return ('/obj/machinery/light/spot', FLOOR, AREA)
    return (FLOOR, AREA)


def plan_ulthor(m):
    edits = []
    hatch = (73, 116, 1)
    expected = ('/turf/simulated/wall', '/area/station/cargo/storage')
    wanted = ('/obj/machinery/door/firedoor', '/obj/machinery/door/airlock/external/trade_bay', '/turf/simulated/floor/plating', '/area/station/cargo/storage')
    edits.append((hatch, expected, wanted))
    port = (72, 116, 1)
    edits.append((port, SPACE, (STATION_PORT,) + SPACE))
    # The freighter needs free space where it docks.
    for x in range(65, 73):
        for y in range(112, 118):
            if (x, y) == (72, 116):
                continue
            edits.append(((x, y, 1), SPACE, SPACE))
    return edits


def plan_centcom(m):
    edits = []
    for lx in range(8):
        for ly in range(6):
            coord = (225 + lx, 80 + ly, 1)
            wanted = freighter_tile(lx, ly)
            edits.append((coord, SPACE, wanted or SPACE))
    return edits


def apply(path, planner, write):
    m = DMM.from_file(path)
    changed = 0
    for coord, expected, wanted in planner(m):
        current = tuple(m.get_tile(coord))
        if current == tuple(wanted):
            continue
        if current != tuple(expected):
            print(f'{path.name} {coord[:2]}: unexpected {current}, refusing to write')
            return False
        changed += 1
        print(f'{path.name} {coord[:2]}: {current} -> {wanted}')
        m.set_tile(coord, tuple(wanted))
    if write and changed:
        m.to_file(path)
    print(f'{path.name}: {changed} tile(s) {"written" if write else "to change"}')
    return True


def main():
    write = '--write' in sys.argv
    ok = apply(ULTHOR, plan_ulthor, False) and apply(CENTCOM, plan_centcom, False)
    if not ok:
        sys.exit(1)
    if write:
        apply(ULTHOR, plan_ulthor, True)
        apply(CENTCOM, plan_centcom, True)


if __name__ == '__main__':
    main()
