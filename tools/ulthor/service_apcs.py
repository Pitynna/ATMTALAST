"""APCs around the service-south corridor after the user's zone edit (2026-11-17).

* The corridor had two APCs: (85,125) on the west wall and (85,138), which
  pointed north at open floor - an APC hanging in the middle of the room.
  One area takes one APC (test ulthor_power), so the floating one goes.
* The quartermaster's office had none, so nothing in it was powered. It gets
  one on its west wall at (80,122), next to the door, and a cable from it
  through the door to the cargo bay branch at (73,123).

Incremental and idempotent: only these two APCs and eight cable tiles change.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
DROP_APC = (85, 138, 1)
QM_APC = (80, 122, 1)
QM_AREA = '/area/station/command/office/qm'
CABLE = '/obj/structure/cable'
QM_CABLE = [(80, 122), (80, 123), (79, 123), (78, 123), (77, 123), (76, 123), (75, 123), (74, 123)]
WEST_APC = '/obj/machinery/power/apc{dir = 8;pixel_x = -26;pixel_y = 0}'


def is_apc(atom):
    return atom.startswith('/obj/machinery/power/apc')


def main():
    m = DMM.from_file(str(MAP))
    removed = added = 0
    tile = m.get_tile(DROP_APC)
    kept = tuple(t for t in tile if not is_apc(t))
    if kept != tile:
        m.set_tile(DROP_APC, kept)
        removed = 1
    tile = m.get_tile(QM_APC)
    assert tile[-1] == QM_AREA, tile[-1]
    if not any(is_apc(t) for t in tile):
        m.set_tile(QM_APC, (WEST_APC,) + tuple(tile))
        added = 1
    cables = 0
    for x, y in QM_CABLE:
        tile = m.get_tile((x, y, 1))
        if not any(t.split('{')[0] == CABLE for t in tile):
            m.set_tile((x, y, 1), (CABLE,) + tuple(tile))
            cables += 1
    if removed or added or cables:
        m.to_file(str(MAP))
    print('APCs removed:', removed, 'added:', added, 'cable tiles laid:', cables)


if __name__ == '__main__':
    main()
