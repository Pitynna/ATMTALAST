"""Restore Ulthor details from the author's 2 May 2024 StrongDMM screenshot.

The screenshot (Z:/ATMTA/ULTHOR/StrongDMM-2024-05-02_23.05.10.png) is newer than
the 29 April map the port started from. Each region below re-creates one room or
area seen on it, on top of the current map, keeping our later fixes (areas,
APCs, alarms, cameras, cables) unless the region explicitly replaces them.

Run from the repository root:  python tools/ulthor/photo_restore.py
The script always starts from the map committed at RESTORE_BASE so it can be
re-run safely after editing a region.
"""
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM  # noqa: E402

MAP = '_maps/map_files/Ulthor/Ulthor.dmm'
PHOTO_LINES = __import__('json').loads((ROOT / 'tools/ulthor/photo_lines.json').read_text())
RESTORE_BASE = '541a0de'

INFRA = ('/obj/structure/cable', '/obj/machinery/atmospherics', '/obj/machinery/power/apc', '/obj/machinery/alarm',
         '/obj/machinery/firealarm', '/obj/machinery/camera', '/obj/item/radio/intercom', '/obj/machinery/light',
         '/obj/structure/disposalpipe', '/obj/machinery/status_display', '/obj/machinery/ai_status_display',
         '/obj/machinery/newscaster', '/obj/machinery/requests_console', '/obj/structure/extinguisher_cabinet',
         '/obj/effect/landmark', '/obj/docking_port')


class Map:
    def __init__(self, dmm):
        self.m = dmm

    def get(self, x, y):
        return list(self.m.get_tile((x, y, 1)))

    def set(self, x, y, atoms):
        self.m.set_tile((x, y, 1), tuple(atoms))

    def area(self, x, y):
        return next(a for a in self.get(x, y) if a.startswith('/area'))

    def turf(self, x, y):
        return next(a for a in self.get(x, y) if a.startswith('/turf'))

    def put(self, x, y, objs=(), turf=None, area=None, keep=INFRA, wipe=True):
        """Replace a tile's contents. Infrastructure is kept unless the new turf is a wall."""
        old = self.get(x, y)
        turf = turf or self.turf(x, y)
        area = area or self.area(x, y)
        wall = '/wall' in turf
        kept = [] if not wipe else [a for a in old if not a.startswith(('/turf', '/area')) and a.startswith(keep) and not wall]
        if not wipe:
            kept = [a for a in old if not a.startswith(('/turf', '/area'))]
        new = kept + [o for o in objs if o not in kept] + [turf, area]
        self.set(x, y, new)

    def add(self, x, y, *objs):
        old = self.get(x, y)
        new = [a for a in objs if a not in old] + old
        self.set(x, y, new)

    def remove(self, x, y, *prefixes):
        self.set(x, y, [a for a in self.get(x, y) if a.startswith(('/turf', '/area')) or not a.startswith(prefixes)])

    def set_area(self, tiles, area):
        for x, y in tiles:
            self.set(x, y, [a for a in self.get(x, y) if not a.startswith('/area')] + [area])

    def photo_cables(self, x0, y0, x1, y1):
        """Add every cable tile the screenshot shows inside the box (auto-connecting cables)."""
        for x, y in rect(x0, y0, x1, y1):
            if 'cable' in PHOTO_LINES.get(f'{x},{y}', {}) and '/wall' not in self.turf(x, y):
                self.cable((x, y))

    def cable(self, *path):
        """Lay one continuous cable run through consecutive tiles."""
        for x, y in path:
            if not any(a.startswith('/obj/structure/cable') for a in self.get(x, y)):
                self.add(x, y, '/obj/structure/cable')


def rect(x0, y0, x1, y1):
    return [(x, y) for x in range(x0, x1 + 1) for y in range(y0, y1 + 1)]


def line(x0, y0, x1, y1):
    if x0 == x1:
        s = 1 if y1 >= y0 else -1
        return [(x0, y) for y in range(y0, y1 + s, s)]
    s = 1 if x1 >= x0 else -1
    return [(x, y0) for x in range(x0, x1 + s, s)]


WALL = '/turf/simulated/wall'
PLATING = '/turf/simulated/floor/plating'
WOOD = '/turf/simulated/floor/wood'


def wood_broken(n):
    return '/turf/simulated/floor/wood{icon_state = "wood-broken%s"}' % ('' if n == 1 else n)


# ---------------------------------------------------------------- regions

def asylum(M):
    """Maintenance micro-asylum north of genetics: orderly poster, haloperidol on the floor."""
    A = '/area/station/maintenance/ulthor_asylum'
    room = rect(125, 191, 128, 192)
    M.set_area(room + [(126, 193)], A)
    for x, y in room:
        M.put(x, y, turf=WOOD)
    for (x, y), n in {(125, 192): 3, (127, 192): 5, (126, 191): 2, (128, 191): 6}.items():
        M.put(x, y, turf=wood_broken(n))
    for x, y in [(125, 193), (127, 193), (128, 193)]:
        M.put(x, y, turf=WALL)
    M.put(126, 193, ['/obj/machinery/door/airlock/maintenance{name = "Abandoned Ward"}',
                     '/obj/structure/barricade/wooden'], turf=PLATING, area=A)
    pill = '/obj/item/reagent_containers/food/pill/haloperidol'
    M.add(125, 192, '/obj/structure/sign/poster/contraband/ulthor_orderly{pixel_y = 32}',
          '/obj/effect/decal/cleanable/cobweb', '/obj/machinery/power/apc{dir = 8;name = "west bump";pixel_x = -24}',
          '/obj/structure/cable')
    M.add(126, 192, '/obj/effect/decal/cleanable/cobweb2', pill + '{pixel_x = 6;pixel_y = -6}')
    M.add(127, 192, '/obj/machinery/light/small{dir = 1}', pill + '{pixel_x = -2;pixel_y = -2}',
          '/obj/machinery/firealarm{pixel_y = 24}')
    M.add(128, 192, '/obj/machinery/iv_drip', pill + '{pixel_x = -6;pixel_y = -4}', pill + '{pixel_y = -6}',
          '/obj/machinery/alarm{dir = 8;pixel_x = 24}')
    M.add(125, 191, '/obj/structure/bed/roller', pill + '{pixel_y = 4}', pill + '{pixel_x = 2;pixel_y = -12}')
    M.add(126, 191, '/obj/item/clothing/suit/straight_jacket', pill + '{pixel_x = -6;pixel_y = -10}',
          pill + '{pixel_x = 6;pixel_y = -10}')
    M.add(127, 191, '/obj/effect/decal/cleanable/cobweb2', pill + '{pixel_y = 2}',
          '/obj/item/storage/pill_bottle{pixel_x = 8;pixel_y = -8}')
    M.add(128, 191, '/obj/item/stack/rods{amount = 2}', pill + '{pixel_x = -8;pixel_y = -10}',
          '/obj/machinery/camera{c_tag = "Maintenance Abandoned Ward";dir = 8;start_active = 1}')
    # APC feed: up through the barricaded door to the maintenance loop the screenshot shows
    M.cable((125, 192), (126, 192), (126, 193), (126, 194), (126, 195))
    M.photo_cables(108, 190, 145, 195)


def north_pod(M):
    """Escape pod 1 berth north of the port solar passage, plus the nitrogen rig beside it."""
    hall = M.area(102, 189)
    M.put(102, 190, ['/obj/machinery/door/airlock/external{name = "Escape Pod Airlock"}',
                     '/obj/effect/turf_decal/stripes/line{dir = 1}', '/obj/structure/fans/tiny',
                     '/obj/effect/landmark/navigate_destination/dockescpod1'], turf='/turf/simulated/floor/plasteel', area=hall)
    M.add(103, 190, '/obj/structure/sign/pods')
    for x in (101, 103):
        M.put(x, 191, turf=WALL, area=hall)
    M.put(102, 191, ['/obj/effect/turf_decal/stripes/line{dir = 1}', '/obj/machinery/light/small{dir = 8}'],
          turf='/turf/simulated/floor/plasteel', area=hall)
    M.add(102, 192, '/obj/docking_port/stationary{dwidth = 2;height = 6;id = "pod1_home";name = "pod1 home dock";width = 5}')
    # Nitrogen rig (screenshot 103-105, 182-186). Left unconnected to distro on purpose.
    cyan = '/obj/machinery/atmospherics/pipe/simple/visible/cyan'
    M.add(103, 186, '/obj/item/tank/internals/oxygen/yellow')
    M.add(103, 185, '/obj/item/tank/internals/oxygen')
    M.add(104, 186, cyan + '{dir = 6}')
    M.add(105, 186, '/obj/machinery/atmospherics/unary/portables_connector{dir = 8}',
          '/obj/machinery/portable_atmospherics/canister/nitrogen')
    M.add(104, 185, '/obj/machinery/atmospherics/pipe/manifold/visible/cyan{dir = 8}', '/obj/machinery/atmospherics/meter')
    M.add(105, 185, '/obj/machinery/atmospherics/unary/portables_connector{dir = 8}',
          '/obj/machinery/portable_atmospherics/canister/nitrogen')
    M.add(104, 184, '/obj/machinery/atmospherics/binary/valve')
    M.add(105, 184, '/obj/item/stack/rods{amount = 3}')
    M.add(104, 183, cyan, '/obj/machinery/atmospherics/meter')
    M.add(105, 183, '/obj/machinery/portable_atmospherics/pump')
    M.add(104, 182, '/obj/machinery/atmospherics/binary/pump{dir = 2}')


REGIONS = [asylum, north_pod]


def main():
    raw = subprocess.check_output(['git', 'show', f'{RESTORE_BASE}:{MAP}'], cwd=ROOT)
    import tempfile
    fd, name = tempfile.mkstemp(suffix='.dmm')
    with open(fd, 'wb') as f:
        f.write(raw)
    M = Map(DMM.from_file(name))
    Path(name).unlink()
    for region in REGIONS:
        region(M)
        print('applied', region.__name__)
    M.m.to_file(str(ROOT / MAP))


if __name__ == '__main__':
    main()
