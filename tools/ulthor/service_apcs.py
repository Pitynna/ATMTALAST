"""APCs around the service-south corridor after the user's zone edit (2026-11-17).

* The corridor had two APCs: (85,125) on the west wall and (85,138), which
  pointed north at open floor - an APC hanging in the middle of the room.
  One area takes one APC (test ulthor_power), so the floating one goes.
* The quartermaster's office had none, so nothing in it was powered. It gets
  one on its west wall at (80,122), next to the door; rewire_power.py then
  branches a cable to it.

Incremental and idempotent: only these two objects change.
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
    if removed or added:
        m.to_file(str(MAP))
    print('APCs removed:', removed, 'added:', added)


if __name__ == '__main__':
    main()
