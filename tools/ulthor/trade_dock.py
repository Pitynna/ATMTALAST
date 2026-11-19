"""Second dock: the Sol traders' dock at the end of the commons hallway (2026-11-19).

The traders event (EVENT_TRADERS) flies /obj/docking_port/mobile "trade_sol"
(15x18, centcomm) to the stationary port "trade_dock"; Ulthor had none, so
traders could not come. The commons arm the user started (between the pet
store / tool storage / garden) ends in a two-door external airlock facing
south with ~40x30 free space below - the shuttle fits at x97-111, y66-84.

Geometry copied from Cyberiad (dir 8: station doors at port+(1,0) and
port+(1,1)); here the port faces south (dir 2), the shuttle rotates 270
degrees, so the station doors are port+(0,1) and port+(-1,1): port at
(104,83), doors (104,84) and (103,84). The doors get id_tag "trade_dock"
and start locked, as on Cyberiad; the catwalk in the footprint is removed.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
PORT = (104, 83)
PORT_ATOM = ('/obj/docking_port/stationary{dheight = 1;dir = 2;dwidth = 7;height = 18;id = "trade_dock";'
             'name = "trade dock at Ulthor";width = 15}')
DOOR = '/obj/machinery/door/airlock/external{id_tag = "trade_dock";locked = 1;name = "Trade Dock"}'


def main():
    m = DMM.from_file(str(MAP))
    for x in (103, 104):
        tile = list(m.get_tile((x, 84, 1)))
        tile = [DOOR if a.startswith('/obj/machinery/door/airlock/external') else a for a in tile]
        m.set_tile((x, 84, 1), tuple(tile))
        m.set_tile((x, 83, 1), ('/turf/space', '/area/space'))
    m.set_tile((*PORT, 1), (PORT_ATOM, '/turf/space', '/area/space'))
    # the footprint must be empty space (shuttle turfs replace whatever is there)
    blocked = [(x, y) for x in range(97, 112) for y in range(66, 84)
               if m.get_tile((x, y, 1))[-1] != '/area/space'
               or not any(a.startswith('/turf/space') for a in m.get_tile((x, y, 1)))
               or any(a.startswith('/obj/structure/lattice') for a in m.get_tile((x, y, 1)))]
    if blocked:
        sys.exit(f'footprint not clear: {blocked[:10]}')
    m.to_file(str(MAP))
    print('trade_dock placed at', PORT)


if __name__ == '__main__':
    main()
