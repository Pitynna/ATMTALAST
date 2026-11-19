"""CentCom ferry dock at arrivals (user, 2026-11-19).

The admin-driven ferry (mobile "ferry", 12x5, door at its east end, dir 8)
flies to the stationary "ferry_home"; Ulthor had none. Cyberiad keeps it at
arrivals ("port bay 3"), so here it docks at the west door of the arrivals
lounge (64,106): open space x36-63 lies in front of it.

Like Ulthor's other docks (specops, admin) the station side is one external
door with the dock's id_tag, locked until a shuttle docks. Port at (63,106),
dir 8 like the ferry itself (no rotation): the ferry fills x52-63, y104-108.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
PORT = (63, 106)
DOOR_AT = (64, 106)
PORT_ATOM = ('/obj/docking_port/stationary{dir = 8;dwidth = 2;height = 12;id = "ferry_home";'
             'name = "port bay 3";width = 5}')
DOOR = '/obj/machinery/door/airlock/external{id_tag = "ferry_home";locked = 1;name = "Ferry Dock"}'


def main():
    m = DMM.from_file(str(MAP))
    blocked = [(x, y) for x in range(52, 64) for y in range(104, 109)
               if m.get_tile((x, y, 1)) != ('/turf/space', '/area/space')]
    if blocked:
        sys.exit(f'footprint not clear: {blocked[:10]}')
    tile = list(m.get_tile((*DOOR_AT, 1)))
    i = next(i for i, a in enumerate(tile) if a.startswith('/obj/machinery/door/airlock'))
    tile[i] = DOOR
    m.set_tile((*DOOR_AT, 1), tuple(tile))
    m.set_tile((*PORT, 1), (PORT_ATOM, '/turf/space', '/area/space'))
    m.to_file(str(MAP))
    print('ferry_home placed at', PORT)


if __name__ == '__main__':
    main()
