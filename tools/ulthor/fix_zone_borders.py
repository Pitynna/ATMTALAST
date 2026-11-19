"""Move zone borders off open floor onto walls/doors (user, 2026-11-19).

Found with zone_borders.py / zone_view.py, judged on the map:
* medbay: medical/ward had swallowed the blue-trimmed medbay corridor
  (x115-116 y175-191), the lobby edge by the reception and the passage from the
  break room (x110-114 y177-178) - all open floor of the medbay itself, joined
  to it by a staircase border. Ward keeps only the patient rooms behind doors.
* port hall: the theatre access zone covered the port hall's own southern leg
  x86-88 y151-156 (the hall runs down to the bar doors); it keeps the side
  passage to the theatre (x89+).
* entry/aft: the entry hall cut the aft hallway at x81/82 in open corridor; the
  border now continues the library's west wall line (x78/79).
* north maintenance: northwest/northeast passages met in a staircase at
  x143-145 y185-187; the border is now straight across the passage at y187/188.
* (94,140): a single bar tile in the service passage.
Walls follow with wall_areas.py. Only area paths change; refuses to move a
tile that carries an APC.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
sys.path.insert(0, str(Path(__file__).resolve().parent))
from dmm import DMM  # noqa: E402
from rooms import MAP, is_wall  # noqa: E402

S = '/area/station/'
RULES = [
    # (old area, new area, x0, y0, x1, y1)
    (S + 'medical/ward', S + 'medical/medbay', 115, 174, 121, 181),
    (S + 'medical/ward', S + 'medical/medbay', 115, 182, 116, 191),
    (S + 'medical/ward', S + 'medical/medbay', 110, 177, 114, 178),
    (S + 'hallway/ulthor_theatre_access', S + 'hallway/primary/port', 86, 151, 88, 156),
    (S + 'hallway/secondary/entry', S + 'hallway/primary/aft', 79, 104, 81, 108),
    (S + 'maintenance/ulthor_northwest_passage', S + 'maintenance/ulthor_northeast_passage', 143, 185, 145, 187),
    (S + 'service/bar', S + 'maintenance/ulthor_service_passage', 94, 140, 94, 140),
]


def main():
    m = DMM.from_file(str(MAP))
    n = 0
    for (x, y, z) in list(m.grid):
        if z != 1:
            continue
        tile = list(m.get_tile((x, y, z)))
        a = tile[-1].split('{')[0]
        for old, new, x0, y0, x1, y1 in RULES:
            if a == old and x0 <= x <= x1 and y0 <= y <= y1:
                if is_wall(tile):
                    break  # walls are wall_areas.py's job
                if any(t.startswith('/obj/machinery/power/apc') for t in tile):
                    sys.exit(f'APC on {(x, y)} - decide by hand')
                tile[-1] = new
                m.set_tile((x, y, z), tuple(tile))
                n += 1
                break
    m.to_file(str(MAP))
    print('tiles rezoned:', n)


if __name__ == '__main__':
    main()
