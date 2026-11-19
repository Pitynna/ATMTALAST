"""Find Ulthor wall mounts that hang on a window, a door or thin air.
python mount_audit.py [--all]   (default: skips maintenance, which the user keeps as is)"""
import re
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
import hall_decor as H  # noqa: E402

STANDALONE = ('/obj/item/radio/intercom', '/obj/machinery/firealarm', '/obj/machinery/alarm', '/obj/machinery/power/apc',
              '/obj/machinery/light_switch', '/obj/machinery/newscaster', '/obj/structure/extinguisher_cabinet',
              '/obj/machinery/requests_console', '/obj/machinery/status_display', '/obj/machinery/ai_status_display',
              '/obj/machinery/computer/security/telescreen', '/obj/machinery/door_control')
SIDE = {'north': 'N', 'south': 'S', 'east': 'E', 'west': 'W'}
SKIP = ('/obj/machinery/light', '/obj/machinery/camera', '/obj/effect', '/obj/machinery/atmospherics',
        '/obj/structure/cable', '/obj/structure/disposalpipe', '/obj/item/twohanded', '/obj/structure/chair')


def mount_side(a):
    b = H.base(a)
    m = re.search(r'/directional/(north|south|east|west)$', b)
    if m:
        return SIDE[m[1]]
    if b.startswith(SKIP) or not b.startswith('/obj'):
        return None
    px = re.search(r'pixel_x = (-?\d+)', a)
    py = re.search(r'pixel_y = (-?\d+)', a)
    px = int(px[1]) if px else 0
    py = int(py[1]) if py else 0
    if max(abs(px), abs(py)) < 20:
        return None
    if abs(py) >= abs(px):
        return 'N' if py > 0 else 'S'
    return 'E' if px > 0 else 'W'


def problems(M, include_maint=False):
    out = []
    for (x, y, z), k in sorted(M.m.grid.items()):
        p = (x, y)
        area = M.area(p)
        if not include_maint and '/maintenance/' in area:
            continue
        if area == '/area/space' or '/shuttle/' in area:
            continue
        on_glass = M.window(p)  # on a solid wall tile an object is drawn on the wall: fine
        for a in M.m.dictionary[k]:
            s = mount_side(a)
            if not s and on_glass and H.base(a).startswith(STANDALONE):
                out.append((p, None, a, 'stands on a window tile', area))
                continue
            if not s:
                continue
            w = H.nb(p, s)
            if M.door(w):
                why = 'door'
            elif M.window(w):
                why = 'window'
            elif not M.wall(w):
                why = 'no wall'
            else:
                continue
            out.append((p, s, a, why, area))
    return out


if __name__ == '__main__':
    M = H.Map()
    res = problems(M, '--all' in sys.argv)
    for p, s, a, why, area in res:
        print(p, s, why, area.replace('/area/station/', ''), a[:100])
    print('problems:', len(res))
