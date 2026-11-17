"""Plating halls that were zoned as corridors are maintenance (user, 2026-11-17).

Judged on the map, not by area names: bare plating, no fittings, and every
entrance is a maintenance airlock.
* aft plating hall x90-114 y88-104 (escape pod 3 dock) -> south maintenance;
* plating passage between the service rooms (hallway/ulthor_service_east)
  -> service maintenance; its APC (99,135) goes, the passage APC stays.
Incremental and idempotent: only area paths and that one APC change.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
sys.path.insert(0, str(Path(__file__).resolve().parent))
from dmm import DMM  # noqa: E402
from rooms import is_wall  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
AFT = '/area/station/hallway/primary/aft'
SERVICE_EAST = '/area/station/hallway/ulthor_service_east'
SOUTH_MAINT = '/area/station/maintenance/ulthor_south_passage'
SERVICE_MAINT = '/area/station/maintenance/ulthor_service_passage'
DROP_APC = (99, 135, 1)


def main():
    m = DMM.from_file(str(MAP))
    n = 0
    for p in list(m.grid):
        x, y, _ = p
        tile = list(m.get_tile(p))
        a = tile[-1]
        turf = next(t for t in tile if t.startswith('/turf'))
        new = a
        if a == AFT and 90 <= x <= 114 and 88 <= y <= 104 and 'plating' in turf and not is_wall(tile):
            new = SOUTH_MAINT
        elif a == SERVICE_EAST:
            new = SERVICE_MAINT
        if p == DROP_APC:
            tile = [t for t in tile if not t.startswith('/obj/machinery/power/apc')]
        if new != a or tuple(tile) != m.get_tile(p):
            tile[-1] = new
            m.set_tile(p, tuple(tile))
            n += 1
    m.to_file(str(MAP))
    print('tiles rezoned:', n)


if __name__ == '__main__':
    main()
