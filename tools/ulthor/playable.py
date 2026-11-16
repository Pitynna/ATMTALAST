"""Make Ulthor playable: gravity generator room, job spawns, lighting, holopads, bot beacons.

Run from the repository root:  python -I tools/ulthor/playable.py
Always rebuilds from the map at BASE, so it is safe to re-run after editing a stage.
Writes _maps/map_files/Ulthor/Ulthor.dmm and docs/ulthor_playable/report.json.
"""
from collections import Counter, deque
import json
import math
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
sys.path.insert(0, str(ROOT / 'tools/ulthor'))
from dmm import DMM  # noqa: E402
from rooms import Station, CARD, is_floor, is_wall, is_door, turf, area  # noqa: E402

MAP = '_maps/map_files/Ulthor/Ulthor.dmm'
BASE = '73b00e65'
REPORT = ROOT / 'docs/ulthor_playable/report.json'
DIRNAME = {1: 'north', 2: 'south', 4: 'east', 8: 'west'}
DELTA = {1: (0, 1), 2: (0, -1), 4: (1, 0), 8: (-1, 0)}
report = {}


# ---------------------------------------------------------------- map access
class Map(Station):
    def get(self, x, y):
        return list(self.m.get_tile((x, y, 1)))

    def set(self, x, y, atoms):
        self.m.set_tile((x, y, 1), tuple(atoms))

    def add(self, x, y, *objs):
        old = self.get(x, y)
        self.set(x, y, [a for a in objs if a not in old] + old)

    def remove(self, x, y, *prefixes):
        self.set(x, y, [a for a in self.get(x, y) if a.startswith(('/turf', '/area')) or not a.startswith(prefixes)])

    def set_turf(self, x, y, t):
        self.set(x, y, [a for a in self.get(x, y) if not a.startswith('/turf')][:-1] + [t, self.get(x, y)[-1]])

    def set_area(self, x, y, a):
        self.set(x, y, self.get(x, y)[:-1] + [a])


# ------------------------------------------------------------ gravity room
GRAV_AREA = '/area/station/engineering/gravity_generator'
DARK = '/turf/simulated/floor/plasteel{icon_state = "dark"}'
PLASTEEL = '/turf/simulated/floor/plasteel'
WALL = '/turf/simulated/wall'
RWALL = '/turf/simulated/wall/r_wall'
SUP = '/obj/machinery/atmospherics/pipe/simple/hidden/supply'
SCR = '/obj/machinery/atmospherics/pipe/simple/hidden/scrubbers'


def vault(d):
    return '/turf/simulated/floor/plasteel{dir = %d;icon_state = "vault"}' % d


def gravity_room(M):
    """Cyberiad's gravity generator room, turned to open east onto the x=160 corridor.

    Chamber x151-155, control room x157-158, partition x156, all y97-103, inside the
    empty plating block south of security processing. The plating strip x145-149
    keeps the detective and processing maintenance doors connected.
    """
    for y in range(96, 105):  # outer walls on y=96/104 and x=159 already exist
        for x in (150, 159):
            assert is_wall(M.get(x, y)) or x == 150, (x, y)
    for y in range(97, 104):
        assert 'plating' in turf(M.get(150, y)) and len(M.get(150, y)) == 2, M.get(150, y)
        M.set(150, y, [WALL, GRAV_AREA])
        for x in range(151, 159):
            assert len(M.get(x, y)) == 2, ('site not empty', x, y, M.get(x, y))
            M.set(x, y, [DARK if x <= 155 else PLASTEEL, GRAV_AREA])
    # generator 3x3 on Cyberiad's vault pattern (main is bottom middle)
    pattern = {(152, 101): 1, (153, 101): 8, (154, 101): 4, (152, 100): 8, (154, 100): 8,
               (152, 99): 4, (153, 99): 8, (154, 99): 1}
    for (x, y), d in pattern.items():
        M.set_turf(x, y, vault(d))
    M.add(153, 99, '/obj/machinery/gravity_generator/main/station')
    # partition
    for y in (97, 103):
        M.set(156, y, [RWALL, GRAV_AREA])
    for y in (98, 99, 101, 102):
        M.set(156, y, ['/obj/effect/spawner/window/reinforced', '/turf/simulated/floor/plating', GRAV_AREA])
    M.set(156, 100, ['/obj/machinery/door/firedoor',
                     '/obj/machinery/door/airlock/engineering/glass{name = "Gravity Generator Chamber";req_access = list(10)}',
                     DARK, GRAV_AREA])
    M.add(156, 103, '/obj/structure/sign/radiation')
    M.add(156, 97, '/obj/structure/sign/electricshock')
    # entrance from the corridor
    M.set(159, 100, ['/obj/machinery/door/firedoor',
                     '/obj/machinery/door/airlock/engineering{name = "Gravity Generator";req_access = list(10,30)}',
                     '/obj/effect/landmark/navigate_destination/gravity_generator', DARK, GRAV_AREA])
    # restore the intended supply/scrubber run along y=102 (both ends were open)
    for x in range(145, 160):
        if x in (152, 155, 157, 158):
            continue
        M.add(x, 102, SUP + '{dir = 4}', SCR + '{dir = 4}')
    M.remove(160, 102, SUP, SCR)
    M.add(160, 102, SUP + '{dir = 10}', SCR + '{dir = 10}')
    # taps: manifold closed side = south, device to the north
    for x, kind, dev in ((155, 'supply', '/obj/machinery/atmospherics/unary/vent_pump/on{dir = 2}'),
                         (152, 'scrubbers', '/obj/machinery/atmospherics/unary/vent_scrubber/on{dir = 2}'),
                         (158, 'supply', '/obj/machinery/atmospherics/unary/vent_pump/on{dir = 2}'),
                         (157, 'scrubbers', '/obj/machinery/atmospherics/unary/vent_scrubber/on{dir = 2}')):
        other = SCR if kind == 'supply' else SUP
        M.add(x, 102, '/obj/machinery/atmospherics/pipe/manifold/hidden/%s{dir = 2}' % kind, other + '{dir = 4}')
        M.add(x, 103, dev)
    # power: corridor grid -> wall -> APC on the control room's south wall
    for p in ((159, 98), (158, 98), (158, 97)):
        M.add(*p, '/obj/structure/cable')
    M.add(158, 97, '/obj/machinery/power/apc/directional/south')
    # lighting and wall devices (Cyberiad set, rotated)
    M.add(153, 103, '/obj/machinery/light{dir = 1}')
    M.add(153, 97, '/obj/machinery/light{dir = 2}')
    M.add(151, 100, '/obj/machinery/light{dir = 8}')
    M.add(151, 98, '/obj/machinery/firealarm/directional/west')
    M.add(151, 102, '/obj/machinery/camera{c_tag = "Gravity Generator Chamber";dir = 4;start_active = 1}')
    M.add(152, 103, '/obj/machinery/alarm/directional/north')
    M.add(154, 103, '/obj/machinery/status_display{layer = 4;pixel_y = 32}')
    M.add(152, 97, '/obj/machinery/ai_status_display{pixel_y = -32}')
    M.add(155, 101, '/obj/machinery/hologram/holopad')
    M.add(157, 103, '/obj/machinery/light{dir = 1}')
    M.add(158, 103, '/obj/machinery/firealarm/directional/north')
    M.add(157, 97, '/obj/machinery/light{dir = 2}')
    M.add(158, 98, '/obj/machinery/alarm/directional/east')
    M.add(158, 99, '/obj/item/radio/intercom/directional/east')
    M.add(158, 101, '/obj/machinery/light_switch/directional/east')
    M.add(158, 102, '/obj/machinery/camera{c_tag = "Gravity Generator Control";dir = 8;start_active = 1}')
    M.add(157, 101, '/obj/structure/chair/office/dark{dir = 4}')
    M.add(157, 99, '/obj/structure/table', '/obj/item/paper', '/obj/item/pen')
    report['gravity_room'] = {'chamber': [151, 97, 155, 103], 'control': [157, 97, 158, 103], 'generator_main': [153, 99]}


# ------------------------------------------------------------------ fixups
def fixups(M):
    """Small reliability fixes: every mapped camera starts working (no 3% random
    cut wires) and every door button stays on its own Z-level."""
    cams = buttons = 0
    for y in range(1, M.Y + 1):
        for x in range(1, M.X + 1):
            t = M.get(x, y)
            new = []
            for a in t:
                if a.startswith('/obj/machinery/camera') and not a.startswith('/obj/machinery/camera_') and 'start_active' not in a:
                    a = a[:-1] + ';start_active = 1}' if a.endswith('}') else a + '{start_active = 1}'
                    cams += 1
                if a.startswith('/obj/machinery/door_control') and 'safety_z_check' not in a:
                    a = a[:-1] + ';safety_z_check = 1}' if a.endswith('}') else a + '{safety_z_check = 1}'
                    buttons += 1
                new.append(a)
            if new != t:
                M.set(x, y, new)
    report['fixups'] = {'cameras_start_active': cams, 'buttons_z_check': buttons}
    print('  fixups:', report['fixups'])


# ------------------------------------------------------------------- zones
# Hand corrections: the whole sub-room containing the tile becomes this area.
ROOM_OVERRIDES = [
    ((166, 145), '/area/station/engineering/atmos'),  # atmospherics control room (camera, manuals)
]


def rezone(M):
    """Make area borders follow walls instead of straight-line distance to APCs.

    Sub-rooms: floor split at walls, doors, windows, one-tile doorways and the
    edge between plating and tiled floor. Inside a sub-room the area spreads by
    walking distance from its APCs (one APC: the whole sub-room). Corridors take
    the hallway areas found in them; sub-rooms without an APC take their
    majority area. Doorways, doors and walls take the area of their neighbours.
    """
    from zones import pinch, local_width
    pinches = {(x, y) for y in range(1, M.Y + 1) for x in range(1, M.X + 1) if pinch(M, x, y)}
    plating = lambda p: 'plating' in turf(M.tile(*p))
    apc = {}
    for y in range(1, M.Y + 1):
        for x in range(1, M.X + 1):
            if any(a.startswith('/obj/machinery/power/apc') for a in M.get(x, y)):
                apc[(x, y)] = area(M.tile(x, y))
    before_apc_areas = Counter(apc.values())
    old = {(x, y): area(M.tile(x, y)) for y in range(1, M.Y + 1) for x in range(1, M.X + 1)}
    new = {}
    seen = set(pinches)
    subs = []
    for y in range(1, M.Y + 1):
        for x in range(1, M.X + 1):
            if (x, y) in seen or not M.walkable(x, y):
                continue
            comp, q = [], deque([(x, y)])
            seen.add((x, y))
            while q:
                p = q.popleft()
                comp.append(p)
                for dx, dy, _ in CARD:
                    n = (p[0] + dx, p[1] + dy)
                    if n not in seen and M.walkable(*n) and plating(n) == plating(p):
                        seen.add(n)
                        q.append(n)
            subs.append(comp)

    def spread(comp, seeds):
        """Multi-source BFS inside comp; seeds: {tile: area}."""
        cs = set(comp)
        q = deque(seeds)
        for p, a in seeds.items():
            new[p] = a
        while q:
            p = q.popleft()
            for dx, dy, _ in CARD:
                n = (p[0] + dx, p[1] + dy)
                if n in cs and n not in new:
                    new[n] = new[p]
                    q.append(n)

    kinds = Counter()
    forced = {}
    for tile, a in ROOM_OVERRIDES:
        for comp in subs:
            if tile in comp:
                forced[id(comp)] = a
    for comp in subs:
        if id(comp) in forced:
            for p in comp:
                new[p] = forced[id(comp)]
            kinds['override'] += 1
            continue
        areas = Counter(old[p] for p in comp)
        hall = {p: old[p] for p in comp if '/hallway/' in old[p]}
        widths = sorted(local_width(M, *p) for p in comp)
        corridor = not plating(comp[0]) and (len(hall) > len(comp) / 2 or (len(comp) >= 25 and widths[len(widths) // 2] <= 3))
        seeds = {p: apc[p] for p in comp if p in apc}
        if corridor and hall:
            hall_apcs = {p: a for p, a in seeds.items() if '/hallway/' in a}
            for p, a in seeds.items():  # room APCs on a corridor wall keep their own tile
                new[p] = a
            spread(comp, hall_apcs or hall)
            kinds['corridor'] += 1
        elif seeds:
            # an APC only claims floor for an area that already had a real share of this
            # sub-room; one mounted on the far side of a wall keeps just its own tile
            share = {a: n / len(comp) for a, n in areas.items()}
            maint = plating(comp[0])
            grow = {p: a for p, a in seeds.items() if share.get(a, 0) >= 0.25 or '/hallway/' in a or (maint and '/maintenance' in a)}
            big = {a for a, sh in share.items() if sh >= 0.25}
            if not maint and len(big | set(grow.values())) >= 2:
                # open-plan room shared by several real areas (bar and theatre): keep
                # their hand-made borders, absorb only the small leftovers
                grow = {p: old[p] for p in comp if old[p] in big | set(grow.values())}
            for p, a in seeds.items():
                new[p] = a
            if grow:
                spread(comp, grow)
                kinds['apc'] += 1
            else:
                maj = areas.most_common(1)[0][0]
                for p in comp:
                    new.setdefault(p, maj)
                kinds['majority'] += 1
        else:
            maj = areas.most_common(1)[0][0]
            for p in comp:
                new[p] = maj
            kinds['majority'] += 1
    for p in pinches:
        around = Counter(new[n] for n in ((p[0] + 1, p[1]), (p[0] - 1, p[1]), (p[0], p[1] + 1), (p[0], p[1] - 1)) if n in new)
        new[p] = around.most_common(1)[0][0] if around else old[p]
    # doors, windows, walls: majority of neighbouring floor (8-neighbourhood)
    for (x, y), a in old.items():
        if (x, y) in new or not a.startswith('/area/station'):
            continue
        around = Counter(new[(x + dx, y + dy)] for dx in (-1, 0, 1) for dy in (-1, 0, 1) if (x + dx, y + dy) in new)
        if around:
            best = max(around.values())
            new[(x, y)] = a if around.get(a) == best else around.most_common(1)[0][0]
    for p, a in apc.items():  # an APC always stays inside the area it powers
        new[p] = a
    changed = 0
    for p, a in new.items():
        if a != old[p]:
            M.set_area(*p, a)
            changed += 1
    after = Counter(area(M.tile(*p)) for p in apc)
    lost = [a for a in before_apc_areas if a not in after]
    tiles_after = Counter(area(M.tile(x, y)) for y in range(1, M.Y + 1) for x in range(1, M.X + 1))
    vanished = sorted(a for a in set(old.values()) if a not in tiles_after)
    unpowered = sorted(a for a in tiles_after if a.startswith('/area/station') and a not in after)
    report['rezone'] = {'changed_tiles': changed, 'subrooms': dict(kinds), 'apc_area_lost': lost,
                        'vanished_areas': vanished, 'areas_without_apc': unpowered}
    print('  rezone:', changed, 'tiles;', dict(kinds), 'vanished', vanished, 'unpowered', len(unpowered))


# --------------------------------------------------------------- job starts
CHAIR = ('/obj/structure/chair', '/obj/structure/bed', '/obj/structure/stool')
FREE_OK = ('/obj/structure/cable', '/obj/machinery/atmospherics/pipe', '/obj/structure/disposalpipe', '/obj/effect/decal',
           '/obj/effect/turf_decal', '/obj/machinery/light', '/obj/machinery/camera', '/obj/machinery/alarm',
           '/obj/machinery/firealarm', '/obj/item/radio/intercom', '/obj/machinery/power/apc', '/obj/machinery/status_display',
           '/obj/machinery/ai_status_display', '/obj/machinery/newscaster', '/obj/machinery/requests_console',
           '/obj/structure/extinguisher_cabinet', '/obj/machinery/light_switch', '/obj/structure/sign', '/obj/machinery/door/firedoor',
           '/obj/machinery/hologram/holopad', '/obj/machinery/atmospherics/unary/vent', '/obj/item/', '/obj/machinery/door_control',
           '/obj/machinery/button', '/obj/structure/curtain') + CHAIR

# job: (target total, area substrings)
JOBS = {
    'engineer': (5, ['engineering/ulthor_151_130', 'engineering/ulthor_158_119', 'engineering/ulthor_monitoring']),
    'trainee_engineer': (3, ['engineering/ulthor_151_130', 'engineering/ulthor_158_119', 'engineering/ulthor_monitoring']),
    'atmospheric': (3, ['engineering/atmos']),
    'doctor': (5, ['medical/ulthor_124_179', 'medical/break_room', 'medical/ulthor_108_176']),
    'intern': (4, ['medical/ulthor_124_179', 'medical/break_room', 'medical/ulthor_108_176']),
    'coroner': (1, ['medical/ulthor_113_186']),
    'chemist': (2, ['medical/ulthor_110_175']),
    'scientist': (6, ['science/rnd', 'science/genetics', 'science/explab', 'science/ulthor_186_169', 'science/toxins']),
    'student_sientist': (4, ['science/rnd', 'science/genetics', 'science/explab']),
    'roboticist': (2, ['science/robotics/ulthor']),
    'explorer': (3, ['command/ulthor_100_175']),
    'detective': (2, ['security/detectives_office']),
    'security_officer': (6, ['security/main', 'security/processing', 'security/lobby', 'security/brig']),
    'security_pod_pilot': (1, ['security/podbay']),
    'cargo_technician': (3, ['cargo/storage', 'cargo/office']),
    'shaft_miner': (8, ['cargo/miningdock']),
    'botanist': (2, ['service/ulthor_82_155']),
    'civilian': (16, ['commons/ulthor_81_165', 'service/ulthor_80_150', 'commons/locker', 'hallway/primary', 'service/library']),
    'prisoner': (8, ['security/prison/perma']),
    'hangover': (40, ['service/ulthor_80_150', 'commons/', 'service/ulthor_theatre', 'service/library', 'hallway/', 'service/barber']),
}


def free_tile(M, x, y, allow_chair=True):
    t = M.get(x, y)
    if not M.walkable(x, y) or 'plating' in turf(t):
        return False
    objs = [a for a in t if a.startswith(('/obj', '/mob'))]
    if any(a.startswith('/obj/effect/landmark') for a in objs):
        return False
    return all(a.startswith(FREE_OK) for a in objs)


def job_starts(M):
    tiles_by_area = {}
    landmarks = Counter()
    for y in range(1, M.Y + 1):
        for x in range(1, M.X + 1):
            t = M.get(x, y)
            tiles_by_area.setdefault(area(t), []).append((x, y))
            for a in t:
                if a.startswith('/obj/effect/landmark/start/'):
                    landmarks[a.split('{')[0].rsplit('/', 1)[-1]] += 1
    added = {}
    for job, (target, patterns) in JOBS.items():
        need = target - landmarks[job]
        if need <= 0:
            continue
        pool = [p for a, ps in tiles_by_area.items() if any(s in a for s in patterns) for p in ps if free_tile(M, *p)]
        if not pool:
            print('  ! no tiles for', job)
            continue
        chairs = [p for p in pool if any(a.startswith(CHAIR) for a in M.get(*p))]
        rest = [p for p in pool if p not in chairs]
        # spread picks: chairs first, then tiles farthest from already chosen starts
        chosen = []
        for _ in range(need):
            cand = chairs or rest
            if not cand:
                break
            if chosen:
                cand = sorted(cand, key=lambda p: -min(abs(p[0] - c[0]) + abs(p[1] - c[1]) for c in chosen))
            else:
                cand = sorted(cand)
            pick = cand[0] if not chosen else cand[0]
            # pick deterministically but not the extreme corner: middle of the best third
            chosen.append(pick)
            (chairs if pick in chairs else rest).remove(pick)
        for p in chosen:
            M.add(*p, '/obj/effect/landmark/start/' + job)
        added[job] = [list(p) for p in chosen]
        if len(chosen) < need:
            print('  ! only', len(chosen), 'of', need, 'for', job)
    # latejoin prisoner points in perma
    perma = [p for a, ps in tiles_by_area.items() if 'security/prison/perma' in a for p in ps if free_tile(M, *p)]
    for p in perma[len(perma) // 2: len(perma) // 2 + 2]:
        M.add(*p, '/obj/effect/landmark/spawner/late/prisoner')
    added['latejoin_prisoner'] = [list(p) for p in perma[len(perma) // 2: len(perma) // 2 + 2]]
    report['job_starts'] = added


# -------------------------------------------------------------------- cameras
def area_names():
    names = {}
    for f in (ROOT / 'code/game/area').rglob('*.dm'):
        cur = None
        for line in f.read_text(encoding='utf-8', errors='replace').splitlines():
            if line.startswith('/area'):
                cur = line.split('//')[0].strip()
            elif cur and re.match(r'	name = "', line):
                names[cur] = re.search(r'name = "([^"]*)"', line)[1]
    return names


def cameras_stage(M):
    """Add wall cameras until every watched room tile is seen (gain >= 5 per camera)."""
    from camera_coverage import Vision, cameras, watched
    names = area_names()
    v = Vision(M)
    seen = set()
    for cx, cy in cameras(M.m):
        seen |= v.sees(cx, cy)
    targets, cand_tiles, room_area = set(), [], {}
    for comp in M.rooms():
        a = Counter(area(M.tile(*p)) for p in comp).most_common(1)[0][0]
        for p in comp:
            room_area[p] = a
        plating = sum('plating' in turf(M.tile(*p)) for p in comp) / len(comp)
        if not watched(a, comp, plating):
            continue
        blind = [p for p in comp if p not in seen]
        if blind:
            targets |= set(blind)
            cand_tiles += comp
    cover = {}
    for p in cand_tiles:
        if wall_faces_free(M, p) and not is_door(M.tile(*p)):
            g = v.sees(*p, targets)
            if len(g) >= 5:
                cover[p] = g
    used = Counter()
    for t in M.m.dictionary.values():
        for a in t:
            m = re.search(r'c_tag = "([^"]*)"', a)
            if m:
                used[m[1]] += 1
    added = []
    while cover:
        best = max(cover, key=lambda p: (len(cover[p] & targets), -p[1], -p[0]))
        gain = cover[best] & targets
        if len(gain) < 5:
            break
        face = wall_faces_free(M, best)[0]
        a = Counter(area(M.tile(*q)) for q in cover[best] | {best} if q in room_area).most_common(1)[0][0]
        base = names.get(a.split('{')[0], a.rsplit('/', 1)[-1].replace('_', ' ').title())
        n = 1
        while f'{base} #{n}' in used or (n == 1 and base in used):
            n += 1
        tag = base if n == 1 else f'{base} #{n}'
        used[tag] += 1
        back = {1: 2, 2: 1, 4: 8, 8: 4}[face]
        M.add(*best, '/obj/machinery/camera{c_tag = "%s";dir = %d;start_active = 1}' % (tag, back))
        added.append([tag, *best])
        targets -= gain
        del cover[best]
    report['cameras'] = {'added': len(added), 'left_blind': len(targets), 'list': added}
    print('  cameras: +%d, blind tiles left %d' % (len(added), len(targets)))


# ------------------------------------------------------------------ lighting
WALLMOUNT = ('/obj/machinery/power/apc', '/obj/machinery/alarm', '/obj/machinery/firealarm', '/obj/item/radio/intercom',
             '/obj/structure/extinguisher_cabinet', '/obj/machinery/newscaster', '/obj/machinery/status_display',
             '/obj/machinery/ai_status_display', '/obj/machinery/light_switch', '/obj/machinery/requests_console',
             '/obj/machinery/camera', '/obj/machinery/light', '/obj/machinery/door_control', '/obj/machinery/button',
             '/obj/machinery/vending/wallmed', '/obj/structure/closet/walllocker', '/obj/machinery/flasher',
             '/obj/machinery/keycard_auth', '/obj/machinery/computer/security/telescreen', '/obj/structure/sign',
             '/obj/machinery/recharger/wallcharger', '/obj/machinery/defibrillator_mount', '/obj/structure/noticeboard',
             '/obj/machinery/disposal/wall', '/obj/structure/disposalholder', '/obj/machinery/turretid',
             '/obj/machinery/embedded_controller', '/obj/machinery/access_button', '/obj/machinery/airlock_sensor',
             '/obj/machinery/mass_driver_button', '/obj/machinery/driver_button', '/obj/machinery/ignition_switch',
             '/obj/machinery/holosign_switch', '/obj/structure/fireaxecabinet', '/obj/machinery/atm', '/obj/structure/mirror',
             '/obj/machinery/shower', '/obj/structure/sink', '/obj/machinery/station_map', '/obj/machinery/fishtank/wall',
             '/obj/machinery/computer/security/wooden_tv', '/obj/machinery/magnetic_controller')
LIGHTS = ('/obj/machinery/light', '/obj/machinery/light/small', '/obj/machinery/light/spot', '/obj/machinery/light/floor')


def faces(atom):
    """Wall faces (1/2/4/8) an existing wall-mounted atom occupies; all four when unknown."""
    path = atom.split('{')[0]
    m = re.search(r'/directional/(north|south|east|west)$', path)
    if m:
        return {next(k for k, v in DIRNAME.items() if v == m[1])}
    px = re.search(r'pixel_x = (-?\d+)', atom)
    py = re.search(r'pixel_y = (-?\d+)', atom)
    px = int(px[1]) if px else 0
    py = int(py[1]) if py else 0
    if abs(px) >= 10 or abs(py) >= 10:
        return {1 if py >= 10 else 2 if py <= -10 else 4 if px >= 10 else 8}
    if path.startswith('/obj/machinery/light') and not path.startswith(('/obj/machinery/light_switch', '/obj/machinery/light_construct')):
        d = re.search(r'dir = (\d+)', atom)
        return {int(d[1]) if d else 2}
    return {1, 2, 4, 8}


def bfs_within(room_set, start, radius):
    """8-connected steps inside a room (no corner cutting), up to radius."""
    dist = {start: 0}
    q = deque([start])
    while q:
        p = q.popleft()
        if dist[p] >= radius:
            continue
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                if not dx and not dy:
                    continue
                n = (p[0] + dx, p[1] + dy)
                if n in dist or n not in room_set:
                    continue
                if dx and dy and ((p[0] + dx, p[1]) not in room_set or (p[0], p[1] + dy) not in room_set):
                    continue
                dist[n] = dist[p] + 1
                q.append(n)
    return dist


def wall_faces_free(M, p):
    used = set()
    for a in M.get(*p):
        if a.startswith(WALLMOUNT):
            used |= faces(a)
    out = []
    for d, (dx, dy) in DELTA.items():
        if d in used:
            continue
        n = M.tile(p[0] + dx, p[1] + dy)
        if is_wall(n) and not is_door(n):
            out.append(d)
    return out


def skip_room(M, comp):
    areas = Counter(area(M.tile(*p)) for p in comp)
    a = areas.most_common(1)[0][0]
    return len(comp) < 4 or '/solars/' in a or a.startswith('/area/station/solars')


def lighting(M):
    added = Counter()
    switches = []
    rooms = M.rooms()
    for comp in rooms:
        if skip_room(M, comp):
            continue
        room = set(comp)
        plating = sum('plating' in turf(M.tile(*p)) for p in comp) / len(comp)
        maint = plating >= 0.5 or Counter('/maintenance' in area(M.tile(*p)) for p in comp)[True] > len(comp) / 2
        radius = 5 if maint else 4
        kind = '/obj/machinery/light/small' if maint else '/obj/machinery/light'
        lit = set()
        for p in comp:
            if any(a.startswith(LIGHTS) and not a.startswith(('/obj/machinery/light_switch', '/obj/machinery/light_construct')) for a in M.get(*p)):
                lit |= set(bfs_within(room, p, radius))
        uncovered = room - lit
        cover = {}
        for p in comp:
            if wall_faces_free(M, p) and not any(a.startswith('/obj/machinery/door') for a in M.get(*p)):
                cover[p] = set(bfs_within(room, p, radius))
        while uncovered and cover:
            best = max(cover, key=lambda p: (len(cover[p] & uncovered), -p[1], -p[0]))
            gain = cover[best] & uncovered
            if not gain:
                break
            d = wall_faces_free(M, best)[0]
            M.add(*best, '%s{dir = %d}' % (kind, d))
            added[kind] += 1
            uncovered -= gain
            del cover[best]
            # do not crowd: drop candidates right next to the new light
            for q in list(cover):
                if max(abs(q[0] - best[0]), abs(q[1] - best[1])) <= 1:
                    del cover[q]
    # light switch per area that has none (rooms only; not halls/maintenance)
    have = set()
    tiles_by_area = {}
    for y in range(1, M.Y + 1):
        for x in range(1, M.X + 1):
            t = M.get(x, y)
            tiles_by_area.setdefault(area(t), []).append((x, y))
            if any(a.startswith('/obj/machinery/light_switch') for a in t):
                have.add(area(t))
    for a, ps in tiles_by_area.items():
        if a in have or not a.startswith('/area/station') or any(s in a for s in ('/hallway', '/maintenance', '/solars')):
            continue
        floor = [p for p in ps if M.walkable(*p)]
        if len(floor) < 6 or sum('plating' in turf(M.tile(*p)) for p in floor) > len(floor) / 2:
            continue
        # beside a door into the area, else any free wall face
        doors = [p for p in ps if is_door(M.tile(*p))]
        cands = sorted(floor, key=lambda p: min((abs(p[0] - d[0]) + abs(p[1] - d[1]) for d in doors), default=0))
        for p in cands:
            free = wall_faces_free(M, p)
            if free:
                M.add(*p, '/obj/machinery/light_switch/directional/' + DIRNAME[free[0]])
                switches.append([*p])
                break
    report['lighting'] = {'added': dict(added), 'switches': len(switches)}


# ------------------------------------------------------------------- holopads
def holopads(M):
    added = []
    for comp in M.rooms():
        if skip_room(M, comp) or len(comp) < 9:
            continue
        plating = sum('plating' in turf(M.tile(*p)) for p in comp) / len(comp)
        if plating >= 0.5 or Counter('/maintenance' in area(M.tile(*p)) for p in comp)[True] > len(comp) / 2:
            continue
        room = set(comp)
        covered = set()
        for p in comp:
            if any(a.startswith('/obj/machinery/hologram/holopad') for a in M.get(*p)):
                covered |= set(bfs_within(room, p, 8))
        free = [p for p in comp if free_tile(M, *p) and not any(a.startswith(CHAIR) for a in M.get(*p))]
        while room - covered and free:
            todo = room - covered
            cx = sum(p[0] for p in todo) / len(todo)
            cy = sum(p[1] for p in todo) / len(todo)
            # most coverage, then closest to the centre of what is still uncovered
            best = max(free, key=lambda p: (len(set(bfs_within(room, p, 8)) & todo), -math.hypot(p[0] - cx, p[1] - cy)))
            gain = set(bfs_within(room, best, 8)) & todo
            if len(gain) < 6:
                break
            M.add(*best, '/obj/machinery/hologram/holopad')
            added.append(list(best))
            covered |= gain
            free.remove(best)
    report['holopads'] = len(added)


# ------------------------------------------------------------------ bot beacons
DELIVERY = [  # location, area substrings of the department side
    ('Bar', ['service/ulthor_80_150']), ('Kitchen', ['service/ulthor_72_141']), ('Hydroponics', ['service/ulthor_82_155']),
    ('Medbay', ['medical/ulthor_124_179', 'medical/ulthor_135_176']), ('Chemistry', ['medical/ulthor_110_175']),
    ('Research Division', ['science/rnd', 'science/genetics']), ('Robotics', ['science/robotics/ulthor']),
    ('Security', ['security/lobby', 'security/main']), ('Engineering', ['engineering/ulthor_151_130', 'engineering/ulthor_158_119']),
    ('Atmospherics', ['engineering/atmos']), ('Tool Storage', ['commons/storage/primary']),
    ('Janitor', ['commons/ulthor_87_165']), ('Bridge', ['command/bridge']), ('Library', ['service/library']),
    ('Chapel', ['service/ulthor_91_176', 'service/ulthor_86_180']), ('Mechanic', ['engineering/ulthor_163_93']),
]


def pathable(M, x, y):
    t = M.tile(x, y)
    return area(t).startswith('/area/station') and is_floor(t) and not any(
        a.startswith(('/obj/effect/spawner/window', '/obj/structure/window/full', '/obj/structure/grille', '/obj/structure/falsewall'))
        for a in t)


def bfs_path(M, start, limit=None):
    dist = {start: 0}
    q = deque([start])
    while q:
        p = q.popleft()
        if limit and dist[p] >= limit:
            continue
        for dx, dy, _ in CARD:
            n = (p[0] + dx, p[1] + dy)
            if n not in dist and pathable(M, *n):
                dist[n] = dist[p] + 1
                q.append(n)
    return dist


def beacons(M):
    rooms = M.rooms()
    halls = []
    for comp in rooms:
        hall = sum('/hallway/' in area(M.tile(*p)) for p in comp)
        plating = sum('plating' in turf(M.tile(*p)) for p in comp) / len(comp)
        if hall >= 10 and plating < 0.5:
            halls.append(comp)
    hall_tiles = set(p for c in halls for p in c)
    usable = [p for p in hall_tiles if free_tile(M, *p) and not any(a.startswith(CHAIR) for a in M.get(*p))]
    # patrol waypoints: farthest-point cover of hallway tiles, radius 9
    remaining = set(hall_tiles)
    points = []
    while remaining:
        if points:
            seed = max(remaining, key=lambda p: (min(abs(p[0] - q[0]) + abs(p[1] - q[1]) for q in points), p))
        else:
            seed = min(remaining)
        best = min(usable, key=lambda p: (abs(p[0] - seed[0]) + abs(p[1] - seed[1]), p))
        points.append(best)
        remaining -= set(bfs_within(hall_tiles, best, 9))
        remaining.discard(seed)
    # tour: nearest neighbour by walking distance, then 2-opt
    dists = {p: bfs_path(M, p) for p in points}
    big = 10 ** 6
    order = [points[0]]
    left = set(points[1:])
    while left:
        cur = order[-1]
        nxt = min(left, key=lambda p: (dists[cur].get(p, big), p))
        order.append(nxt)
        left.remove(nxt)
    def d(a, b):
        return dists[a].get(b, big)
    improved = True
    while improved:
        improved = False
        for i in range(1, len(order) - 1):
            for j in range(i + 1, len(order)):
                a, b, c, e = order[i - 1], order[i], order[j], order[(j + 1) % len(order)]
                if d(a, c) + d(b, e) < d(a, b) + d(c, e):
                    order[i:j + 1] = reversed(order[i:j + 1])
                    improved = True
    names = ['U%d' % (i + 1) for i in range(len(order))]
    legs = []
    for i, p in enumerate(order):
        nxt = names[(i + 1) % len(order)]
        M.add(*p, '/obj/machinery/navbeacon{codes_txt = "patrol;next_patrol=%s";location = "%s"}' % (nxt, names[i]))
        legs.append(d(p, order[(i + 1) % len(order)]))
    # delivery beacons: hallway-side tile in front of a department door
    deliveries = []
    walk = set(p for c in rooms for p in c)
    doors = [(x, y) for y in range(1, M.Y + 1) for x in range(1, M.X + 1) if is_door(M.tile(x, y))]
    for name, patterns in DELIVERY:
        cands = []
        for x, y in doors:
            for dd, (dx, dy) in DELTA.items():
                inside = (x + dx, y + dy)
                outside = (x - dx, y - dy)
                if inside not in walk or outside not in walk or not any(s in area(M.tile(*inside)) for s in patterns):
                    continue
                dept = lambda p: area(M.tile(*p)).split('/')[3] if area(M.tile(*p)).count('/') >= 3 else ''
                if outside not in hall_tiles and (dept(outside) == dept(inside) or any(s in area(M.tile(*outside)) for s in patterns)):
                    continue
                objs = [a for a in M.get(*outside) if a.startswith(('/obj', '/mob'))]
                if not all(a.startswith(FREE_OK) for a in objs) or any(a.startswith(('/obj/effect/landmark', '/obj/machinery/navbeacon')) for a in objs):
                    continue
                rank = 0 if outside in hall_tiles else 1 if 'plating' not in turf(M.tile(*outside)) else 2
                cands.append((rank, outside, dd))
        if not cands:  # department opens straight onto a hallway (bar counter)
            for p in sorted(hall_tiles):
                if any(s in area(M.tile(*p)) for s in patterns) or not free_tile(M, *p):
                    continue
                for dd, (dx, dy) in DELTA.items():
                    q = (p[0] + dx, p[1] + dy)
                    if q in walk and any(s in area(M.tile(*q)) for s in patterns):
                        cands.append((0, p, dd))
        if not cands:
            print('  ! no outer door for delivery beacon', name)
            continue
        rank, outside, dd = min(cands)
        M.add(*outside, '/obj/machinery/navbeacon{codes_txt = "delivery;dir=%d";dir = %d;location = "%s"}' % (dd, dd, name))
        deliveries.append([name, *outside])
    # cargo bay drop points
    bay = [p for p in walk if 'cargo/storage' in area(M.tile(*p)) and free_tile(M, *p)]
    bay.sort(key=lambda p: (-p[1], p[0]))
    for i, p in enumerate(bay[:4]):
        M.add(*p, '/obj/machinery/navbeacon{codes_txt = "delivery";location = "QM #%d"}' % (i + 1))
        deliveries.append(['QM #%d' % (i + 1), *p])
    report['beacons'] = {'patrol': len(order), 'longest_leg': max(legs), 'unreachable_legs': sum(l >= big for l in legs),
                         'delivery': deliveries}


STAGES = [gravity_room, fixups, rezone, job_starts, cameras_stage, lighting, holopads, beacons]


def main():
    raw = subprocess.check_output(['git', 'show', f'{BASE}:{MAP}'], cwd=ROOT)
    with tempfile.NamedTemporaryFile(suffix='.dmm', delete=False) as f:
        f.write(raw)
        name = f.name
    M = Map(DMM.from_file(name))
    Path(name).unlink()
    for stage in STAGES:
        stage(M)
        print('applied', stage.__name__)
    M.m.to_file(str(ROOT / MAP))
    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text(json.dumps(report, indent=1, ensure_ascii=False), encoding='utf-8')
    print(json.dumps({k: v for k, v in report.items() if k != 'job_starts'}, ensure_ascii=False)[:2000])
    print({k: len(v) for k, v in report['job_starts'].items()})


if __name__ == '__main__':
    main()
