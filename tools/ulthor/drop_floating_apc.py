"""The service-south corridor had two APCs after the user's zone edit merged
two areas (2026-11-17): (85,125) on the west wall and (85,138), which pointed
north at open floor - an APC hanging in the middle of the room. One area takes
one APC (test ulthor_power), so the floating one goes; its cable stays.

Incremental and idempotent: only that one object is removed.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
DROP_APC = (85, 138, 1)


def main():
    m = DMM.from_file(str(MAP))
    tile = m.get_tile(DROP_APC)
    kept = tuple(t for t in tile if not t.startswith('/obj/machinery/power/apc'))
    if kept != tile:
        m.set_tile(DROP_APC, kept)
        m.to_file(str(MAP))
    print('APCs removed:', len(tile) - len(kept))


if __name__ == '__main__':
    main()
