"""Point fixes after the user's 2026-11-19 SDMM edits. Edits single atoms only.

1. The user's south maintenance space exit (x111, y83-86): the chamber and its
   window frame were left in /area/space, so the doors and the cycling
   controller had no power and the chamber no gravity or air. Area set to
   the adjacent South Maintenance.
2. Maintenance gets no intercoms and no fire alarms (user rule). The turbine
   is an engine room, not maintenance, and keeps its own.
3. The bar was split into bar + theatre without being asked; the user merged
   the area back. The theatre's duplicate APC, light switch and air alarm
   now sit in the bar area (one APC per area), so they go; theatre camera
   names are renamed to bar ones.
4. The user removed both departures checkpoint shutters (CPEX/CPIN); their
   two buttons at (169,111) controlled nothing and are removed.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
SOUTH = '/area/station/maintenance/ulthor_south_passage'
MAINT_DROP = ('/obj/item/radio/intercom', '/obj/machinery/firealarm')
BAR_DROP = {(94, 140): ('/obj/machinery/power/apc', '/obj/machinery/light_switch'),
            (96, 149): ('/obj/machinery/alarm',),
            (169, 111): ('/obj/machinery/door_control',)}
RENAME = {'"Ulthor Theatre CCTV"': '"Bar Stage"', '"Ulthor Costume Storage CCTV"': '"Bar Wardrobe"'}


def area(tile):
    return next(a for a in tile if a.startswith('/area'))


def main():
    m = DMM.from_file(str(MAP))
    log = []
    for x in range(110, 113):
        for y in range(83, 87):
            t = m.get_tile((x, y, 1))
            if area(t) != '/area/space':
                sys.exit(f'unexpected area at {(x, y)}: {area(t)}')
            m.set_tile((x, y, 1), tuple(SOUTH if a == '/area/space' else a for a in t))
    log.append('airlock chamber x110-112 y83-86 -> South Maintenance')
    for x in range(1, m.size.x + 1):
        for y in range(1, m.size.y + 1):
            t = m.get_tile((x, y, 1))
            a = area(t)
            drop = ()
            if '/maintenance/' in a and not a.endswith('/turbine'):
                drop = MAINT_DROP
            drop += BAR_DROP.get((x, y), ())
            if a.endswith('/service/bar'):
                new = []
                for o in t:
                    for k, v in RENAME.items():
                        if o.startswith('/obj/machinery/camera') and k in o:
                            o = o.replace(k, v)
                            log.append(f'{(x, y)} camera -> {v}')
                    new.append(o)
                t = tuple(new)
            kept = tuple(o for o in t if not o.split('{')[0].startswith(drop)) if drop else t
            for o in set(t) - set(kept):
                log.append(f'{(x, y)} {a.split("/")[-1]}: removed {o.split("{")[0]}')
            if kept != m.get_tile((x, y, 1)):
                m.set_tile((x, y, 1), kept)
    m.to_file(str(MAP))
    print('\n'.join(log))


if __name__ == '__main__':
    main()
