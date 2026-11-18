"""Print an ASCII view of an Ulthor region: python ascii_view.py x0 y0 x1 y1
# wall, W full window, d door, w thin window, . floor, ' ' space; letters mark wall mounts."""
import sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM
MARK = [('/obj/machinery/power/apc', 'P'), ('/obj/machinery/alarm', 'A'), ('/obj/machinery/firealarm', 'F'),
        ('/obj/machinery/camera', 'C'), ('/obj/machinery/light_switch', 'L'), ('/obj/machinery/door_control', 'B'),
        ('/obj/machinery/keycard_auth', 'K'), ('/obj/item/radio/intercom', 'I'), ('/obj/machinery/newscaster', 'N'),
        ('/obj/structure/extinguisher_cabinet', 'E'), ('/obj/machinery/vending/wallmed', 'M'), ('/obj/structure/table', 't')]
m = DMM.from_file(ROOT / '_maps/map_files/Ulthor/Ulthor.dmm')
x0, y0, x1, y1 = map(int, sys.argv[1:5])
print('    ' + ''.join(str(x % 10) for x in range(x0, x1 + 1)))
for y in range(y1, y0 - 1, -1):
    row = ''
    for x in range(x0, x1 + 1):
        t = m.get_tile((x, y, 1)); b = [a.split('{')[0] for a in t]
        c = '.'
        if any(a.startswith(('/turf/simulated/wall', '/turf/unsimulated/wall', '/turf/simulated/mineral')) for a in b): c = '#'
        elif any(a.startswith(('/obj/effect/spawner/window', '/obj/structure/grille')) or 'fulltile' in a for a in b): c = 'W'
        elif any(a.startswith('/obj/machinery/door') and 'firedoor' not in a for a in b): c = 'd'
        elif any(a.startswith('/turf/space') for a in b): c = ' '
        elif any(a == '/obj/structure/window/reinforced' for a in b): c = 'w'
        for p, ch in MARK:
            if any(a.startswith(p) for a in b): c = ch; break
        row += c
    print(f'{y:3d} {row}')
