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


def west_burn_room(M):
    """Burn room off the west passage: fuel canisters, burn chamber with blast doors, disposal chute.

    The screenshot crosses the fuel and exhaust pipes in one tile; this build cannot, so the
    injector and exhaust swap corners inside the chamber and the fuel line runs under the south wall.
    """
    A = '/area/station/engineering/ulthor_burn_room'
    RW = '/turf/simulated/wall/r_wall'
    AIRLESS = '/turf/simulated/floor/plating/airless'
    FLOOR = '/turf/simulated/floor/plasteel'
    ENGINE = '/turf/simulated/floor/engine'
    pipe = '/obj/machinery/atmospherics/pipe/simple/hidden'
    for x, y in [(63, 160), (63, 161), (63, 162), (64, 162), (65, 162), (66, 162), (69, 162), (66, 163), (67, 163),
                 (68, 163), (69, 163), (61, 159), (62, 159), (63, 159), (64, 159), (65, 159), (65, 156), (65, 158),
                 (60, 155), (61, 155), (62, 155), (63, 155), (64, 155), (65, 155), (66, 155), (67, 155), (68, 155),
                 (68, 156), (68, 158), (69, 158), (69, 159), (69, 160), (69, 161), (60, 160)]:
        M.put(x, y, turf=RW, area=A)
    room = rect(66, 156, 67, 161) + [(64, 161), (65, 161), (65, 160), (64, 160), (68, 159), (68, 160), (68, 161),
                                     (67, 162), (68, 162)]
    for x, y in room:
        M.put(x, y, turf=FLOOR, area=A)
    for x, y in rect(61, 156, 64, 158):
        M.put(x, y, turf=ENGINE, area=A)
    M.put(65, 157, ['/obj/effect/spawner/window/reinforced/plasma'], turf=ENGINE, area=A)
    for y in (156, 157, 158):
        M.put(60, y, ['/obj/machinery/door/poddoor{id_tag = "ulthor_burn_vent";name = "Burn Chamber Vent"}'],
              turf=ENGINE, area=A)
    for x in range(58, 63):
        M.put(x, 160, turf=AIRLESS, area=A)
    M.put(60, 159, turf=AIRLESS, area=A)
    M.put(68, 157, ['/obj/machinery/door/airlock/atmos{name = "Burn Room"}'], turf=FLOOR, area=A)
    # fuel: canisters -> valves -> down x=67 -> under the south wall -> injector at the chamber's south-west
    for x in (67, 68):
        M.add(x, 162, '/obj/machinery/atmospherics/unary/portables_connector{dir = 2}')
        M.add(x, 161, '/obj/machinery/atmospherics/binary/valve')
    M.add(67, 162, '/obj/machinery/portable_atmospherics/canister/toxins')
    M.add(68, 162, '/obj/machinery/portable_atmospherics/canister/oxygen')
    M.add(67, 160, '/obj/machinery/atmospherics/pipe/manifold/hidden{dir = 8}')
    M.add(68, 160, pipe + '{dir = 9}')
    for y in (159, 158, 157, 156):
        M.add(67, y, pipe)
    M.add(67, 159, '/obj/machinery/atmospherics/meter')
    M.add(67, 155, pipe + '{dir = 9}')
    for x in (66, 65, 63, 62):
        M.add(x, 155, pipe + '{dir = 4}')
    M.add(64, 155, '/obj/machinery/atmospherics/binary/valve{dir = 4;name = "fuel injection valve"}')
    M.add(61, 155, pipe + '{dir = 5}')
    M.add(61, 156, '/obj/machinery/atmospherics/unary/outlet_injector/on{dir = 2;id = "ulthor_burn_in"}')
    M.add(61, 157, '/obj/machinery/igniter{id = "ulthor_burn";luminosity = 2}')
    # exhaust: chamber north-west -> valve -> up x=65 -> west along y=160 -> vent to space
    M.add(61, 158, '/obj/machinery/atmospherics/unary/passive_vent{dir = 4}')
    M.add(62, 158, pipe + '{dir = 4}')
    M.add(63, 158, '/obj/machinery/atmospherics/binary/valve{dir = 4;name = "exhaust valve"}')
    M.add(64, 158, pipe + '{dir = 4}')
    M.add(65, 158, pipe + '{dir = 9}')
    M.add(65, 159, pipe)
    M.add(65, 160, pipe + '{dir = 10}')
    for x in (64, 63, 62, 61, 60, 59):
        M.add(x, 160, pipe + '{dir = 4}')
    M.add(58, 160, '/obj/machinery/atmospherics/unary/passive_vent{dir = 4}')
    # disposal chute: bin -> down -> west under the wall -> outlet to space
    M.add(64, 161, '/obj/machinery/disposal', '/obj/structure/disposalpipe/trunk{dir = 2}')
    M.add(64, 160, '/obj/structure/disposalpipe/segment')
    M.add(64, 159, '/obj/structure/disposalpipe/segment{dir = 9}', '/obj/structure/sign/fire')
    for x in (63, 62, 61):
        M.add(x, 159, '/obj/structure/disposalpipe/segment{dir = 4}')
    M.add(62, 159, '/obj/structure/sign/vacuum')
    M.add(60, 159, '/obj/structure/disposalpipe/trunk{dir = 4}', '/obj/structure/disposaloutlet{dir = 8}')
    M.add(65, 159, '/obj/structure/sign/nosmoking_2')
    M.add(64, 155, '/obj/structure/sign/fire')
    # room fittings
    M.add(65, 161, '/obj/machinery/alarm{pixel_y = 24}')
    M.add(66, 161, '/obj/machinery/light{dir = 1}')
    M.add(66, 159, '/obj/machinery/portable_atmospherics/pump')
    M.add(67, 156, '/obj/machinery/portable_atmospherics/scrubber',
          '/obj/machinery/ignition_switch{id = "ulthor_burn";pixel_x = 6;pixel_y = -24}')
    M.add(66, 156, '/obj/machinery/door_control{id = "ulthor_burn_vent";name = "Burn Chamber Vent Control";pixel_x = -4;pixel_y = -24;req_access = list(24)}')
    M.add(67, 158, '/obj/machinery/firealarm{dir = 4;pixel_x = 24}')
    M.add(66, 157, '/obj/machinery/camera{c_tag = "Engineering Burn Room";dir = 4;start_active = 1}')
    M.add(68, 160, '/obj/machinery/power/apc{dir = 4;name = "east bump";pixel_x = 24}', '/obj/structure/cable')
    M.add(63, 157, '/obj/machinery/light/small{dir = 2}')
    M.cable((68, 160), (67, 160), (67, 159), (67, 158), (67, 157), (68, 157))
    M.photo_cables(68, 150, 74, 164)
    # paired heat exchangers in the passage below the chamber
    M.add(61, 154, '/obj/machinery/atmospherics/unary/heat_exchanger{dir = 4}')
    M.add(62, 154, pipe + '{dir = 4}')
    M.add(63, 154, '/obj/machinery/atmospherics/binary/valve{dir = 4}')
    M.add(64, 154, pipe + '{dir = 4}')
    M.add(65, 154, '/obj/machinery/atmospherics/unary/heat_exchanger{dir = 8}')


def disposal(M, x, y, d=None, kind='segment'):
    t = '/obj/structure/disposalpipe/' + kind
    M.remove(x, y, '/obj/structure/disposalpipe')
    M.add(x, y, t if d is None else t + '{dir = %d}' % d)


def disposal_run(M, tiles):
    """Lay a disposal run through consecutive tiles; bends are picked from the neighbours.
    The first and last tiles are left to the caller (trunks, junctions)."""
    vec = {(0, 1): 1, (0, -1): 2, (1, 0): 4, (-1, 0): 8}
    for i in range(1, len(tiles) - 1):
        (px, py), (x, y), (nx, ny) = tiles[i - 1], tiles[i], tiles[i + 1]
        a = vec[(px - x, py - y)]
        b = vec[(nx - x, ny - y)]
        d = a | b
        disposal(M, x, y, {3: 1, 12: 4}.get(d, d))


def hidden_run(M, kind, tiles):
    """Hidden supply/scrubber pipe through consecutive tiles (ends left to the caller)."""
    vec = {(0, 1): 1, (0, -1): 2, (1, 0): 4, (-1, 0): 8}
    for i in range(1, len(tiles) - 1):
        (px, py), (x, y), (nx, ny) = tiles[i - 1], tiles[i], tiles[i + 1]
        d = vec[(px - x, py - y)] | vec[(nx - x, ny - y)]
        d = {3: 2, 12: 4}.get(d, d)
        M.add(x, y, '/obj/machinery/atmospherics/pipe/simple/hidden/%s%s' % (kind, '' if d == 2 else '{dir = %d}' % d))


def manifold(M, x, y, kind, closed):
    M.remove(x, y, '/obj/machinery/atmospherics/pipe/simple/hidden/' + kind,
             '/obj/machinery/atmospherics/pipe/manifold/hidden/' + kind)
    M.add(x, y, '/obj/machinery/atmospherics/pipe/manifold/hidden/%s{dir = %d}' % (kind, closed))


def cargo_mail(M):
    """Cargo bay: mail conveyor into a delivery chute, two bins, longer loading belts,
    bay vents, and the disposal run down to the recycling outlet."""
    # mail line
    belt = '/obj/machinery/conveyor{id = "ulthor_mail";dir = %d}'
    M.add(74, 133, '/obj/structure/closet/crate')
    M.add(74, 132, '/obj/structure/closet/crate')
    for x in range(75, 80):
        M.add(x, 133, belt % 4, '/obj/effect/turf_decal/stripes/line{dir = 2}')
    M.add(75, 132, belt % 1, '/obj/effect/turf_decal/stripes/line{dir = 8}', '/obj/effect/turf_decal/stripes/line{dir = 4}')
    M.add(79, 133, '/obj/structure/plasticflaps')
    M.add(80, 133, '/obj/machinery/disposal/deliveryChute{dir = 8}', '/obj/structure/disposalpipe/trunk{dir = 2}')
    M.add(73, 133, '/obj/machinery/conveyor_switch/oneway{id = "ulthor_mail";name = "mail belt switch"}')
    M.add(76, 133, '/obj/machinery/light{dir = 1}')
    M.add(76, 132, '/obj/structure/chair/stool/bar')
    M.add(75, 131, '/obj/machinery/disposal', '/obj/structure/disposalpipe/trunk{dir = 2}')
    # longer loading belts and the marked unloading spots
    for x in (75, 76):
        M.add(x, 128, '/obj/machinery/conveyor{id = "QMLoad2";dir = 4}', '/obj/effect/turf_decal/stripes/line{dir = 1}')
        M.add(x, 124, '/obj/machinery/conveyor{id = "QMLoad";dir = 8}', '/obj/effect/turf_decal/stripes/line{dir = 1}',
              '/obj/effect/turf_decal/stripes/line{dir = 2}')
    for x in (74, 75, 76):
        for y in (127, 125):
            M.add(x, y, '/obj/effect/turf_decal/delivery/hollow')
    M.add(76, 126, '/obj/machinery/portable_atmospherics/scrubber')
    # quartermaster office bin
    M.add(80, 124, '/obj/machinery/disposal', '/obj/structure/disposalpipe/trunk{dir = 2}')
    # disposal network: chute -> x=80 -> x=78 -> down; bay bin -> x=74 -> y=122 -> x=78; to recycling at x=76
    disposal_run(M, [(80, 133), (80, 132), (80, 131), (80, 130), (80, 129), (80, 128), (79, 128), (78, 128),
                     (78, 127), (78, 126), (78, 125), (78, 124), (78, 123)])
    disposal(M, 78, 123, 2, 'junction/reversed')
    disposal_run(M, [(80, 124), (80, 123), (79, 123), (78, 123)])
    disposal_run(M, [(75, 131), (75, 130), (74, 130), (74, 129), (74, 128), (74, 127), (74, 126), (74, 125),
                     (74, 124), (74, 123), (74, 122), (75, 122), (76, 122), (77, 122), (78, 122)])
    disposal(M, 78, 122, 2, 'junction')
    disposal_run(M, [(78, 122), (78, 121), (78, 120), (77, 120), (76, 120), (76, 119)])
    # bay air: branch both trunks from the x=86 riser along y=127
    M.remove(85, 127, '/obj/machinery/atmospherics/unary/vent_scrubber')
    for kind in ('supply', 'scrubbers'):
        manifold(M, 86, 127, kind, 4)
        manifold(M, 77, 127, kind, 8)
        hidden_run(M, kind, [(86, 127)] + line(85, 127, 78, 127) + [(77, 127)])
    hidden_run(M, 'supply', [(77, 127), (77, 128), (77, 129)])
    manifold(M, 77, 129, 'supply', 4)
    M.add(76, 129, '/obj/machinery/atmospherics/unary/vent_pump/on{dir = 4}')
    hidden_run(M, 'supply', [(77, 129), (77, 130), (77, 131), (77, 132), (78, 132), (79, 132), (80, 132),
                             (81, 132), (82, 132), (82, 133)])
    M.add(82, 133, '/obj/machinery/atmospherics/unary/vent_pump/on{dir = 2}')
    hidden_run(M, 'supply', [(77, 127), (77, 126), (77, 125), (77, 124), (77, 123), (78, 123), (79, 123),
                             (80, 123), (81, 123), (82, 123), (82, 122)])
    M.add(82, 122, '/obj/machinery/atmospherics/unary/vent_pump/on{dir = 1}')
    hidden_run(M, 'scrubbers', [(77, 127), (77, 128), (77, 129), (77, 130), (77, 131), (77, 132), (78, 132),
                                (79, 132), (80, 132), (81, 132), (81, 133)])
    M.add(81, 133, '/obj/machinery/atmospherics/unary/vent_scrubber/on{dir = 2}')
    hidden_run(M, 'scrubbers', [(77, 127), (77, 126), (77, 125), (77, 124), (77, 123)])
    manifold(M, 77, 123, 'scrubbers', 2)
    hidden_run(M, 'scrubbers', [(77, 123), (76, 123), (76, 122)])
    M.add(76, 122, '/obj/machinery/atmospherics/unary/vent_scrubber/on{dir = 1}')
    hidden_run(M, 'scrubbers', [(77, 123), (78, 123), (79, 123), (80, 123), (81, 123), (81, 122)])
    M.add(81, 122, '/obj/machinery/atmospherics/unary/vent_scrubber/on{dir = 1}')
    M.photo_cables(72, 120, 85, 134)


REGIONS = [asylum, north_pod, west_burn_room, cargo_mail]


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
