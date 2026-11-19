"""Make Ulthor's hallways livelier (user, 2026-11-19). One-time, additive.

Measured on the reference maps (tools/ulthor/decor_norms.py, per 100 hallway
tiles): Delta 17 floor decals, 1.2 posters, 2.3 bench tiles, 0.9 plants;
Cyberiad 13 decals, 0.7 posters, 5.6 plants. Ulthor had 4 decals, no posters,
no benches and flat grey floors (1395 "neutralfull" tiles).

1. Floor trim like Delta: every hallway tile along a wall gets a quarter trim
   (Delta: north/west wall -> top-left, south -> bottom-right, east ->
   top-right). It takes the colour of the department behind that wall; the
   tile in front of a department door gets a half band. Arrivals and
   departures use the "arrival"/"escape" sets. Only flat grey plasteel is
   repainted; user-painted floors stay.
2. Rest nooks: a bench (department colour where there is one) between two
   potted plants, only where the corridor is at least 4 wide so 3 stay free.
   Benches and potted plants are not dense, so nothing blocks movement.
3. Potted plants in inner corners and every ~9 tiles along walls (to about
   the Cyberiad density); flower vases on empty hallway tables.
4. Wall decor on solid walls with a free face: posters, Goon posters, one
   clock per main corridor, department pieces (periodic table and scientist
   portrait at science, accident board at engineering, first aid at medbay...).
5. Goon floor guides in front of one main door of every department.

Never touches maintenance or room interiors: only /area/station/hallway tiles.
"""
import random
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
RNG = random.Random(20261119)
DIRS = {'N': (0, 1, 1), 'S': (0, -1, 2), 'E': (1, 0, 4), 'W': (-1, 0, 8)}
OPP = {'N': 'S', 'S': 'N', 'E': 'W', 'W': 'E'}
PIX = {'N': 'pixel_y = 32', 'S': 'pixel_y = -32', 'E': 'pixel_x = 32', 'W': 'pixel_x = -32'}

# area substring -> (floor colour, bench colour suffix, floor guide, wall pieces)
DEPTS = [
    (('/security/', '/legal/'), 'red', 'security_red', 'security', []),
    (('/medical/',), 'blue', 'medical_blue', 'medbay', ['/obj/structure/sign/goon/iso/first_aid', '/obj/structure/sign/goon/medical_license']),
    (('/science/',), 'purple', 'science_pink', 'science', ['/obj/structure/sign/goon/periodic_table', '/obj/structure/sign/goon/portrait/scientist']),
    (('/engineering/', '/engine', '/atmos'), 'yellow', None, 'engineering', ['/obj/structure/sign/goon/accidents', '/obj/structure/sign/goon/iso/ear_protection']),
    (('/cargo/', '/quartermaster', '/mining', '/supply'), 'brown', None, 'cargo', ['/obj/structure/sign/goon/poster/pack_smart']),
    (('/hydroponics', '/garden'), 'green', None, 'botany', ['/obj/structure/sign/goon/poster/grow_food']),
    (('/service/bar', '/service/kitchen', '/service/theatre', '/service/clown', '/service/mime'), 'orange', None, 'catering', []),
    (('/command/',), None, 'command_blue', 'command', ['/obj/structure/sign/goon/portrait']),
    (('/service/chapel',), None, None, 'chapel', []),
]
GENERIC_WALL = (['/obj/structure/sign/poster/official/random'] * 6 +
                ['/obj/structure/sign/goon/poster/explore', '/obj/structure/sign/goon/poster/bird_up',
                 '/obj/structure/sign/goon/poster/new_you', '/obj/structure/sign/goon/poster/capy_king',
                 '/obj/structure/sign/goon/poster/biodome', '/obj/structure/sign/goon/poster/believe',
                 '/obj/structure/sign/goon/poster/keep_it', '/obj/structure/sign/goon/poster/laser_power',
                 '/obj/structure/sign/goon/frame', '/obj/structure/sign/goon/poster/pack_smart'])
PLANTS = ['/obj/item/twohanded/required/kirbyplants'] * 3 + [
    f'/obj/item/twohanded/required/kirbyplants/goon/{p}' for p in
    ('pot2', 'pot3', 'pot4', 'pot5', 'plant1', 'plant2', 'plant3', 'plant4', 'plant5', 'plant6', 'plant7')]
QUARTER = {'N': 'TL', 'S': 'BR', 'W': 'TL', 'E': 'TR'}
HALF = {'N': {'TL', 'TR'}, 'S': {'BL', 'BR'}, 'W': {'TL', 'BL'}, 'E': {'TR', 'BR'}}
STATE = {  # quarters -> (suffix, dir)
    frozenset({'TL'}): ('corner', 1), frozenset({'BR'}): ('corner', 2), frozenset({'TR'}): ('corner', 4),
    frozenset({'BL'}): ('corner', 8), frozenset({'TL', 'TR'}): ('', 1), frozenset({'BL', 'BR'}): ('', 2),
    frozenset({'TR', 'BR'}): ('', 4), frozenset({'TL', 'BL'}): ('', 8),
    frozenset({'BL', 'BR', 'TR'}): ('', 6), frozenset({'BL', 'BR', 'TL'}): ('', 10),
    frozenset({'TL', 'TR', 'BR'}): ('', 5), frozenset({'TL', 'TR', 'BL'}): ('', 9),
}
DIAG = {frozenset({'TL', 'BR'}): frozenset({'TL', 'TR', 'BR'}), frozenset({'TR', 'BL'}): frozenset({'TL', 'TR', 'BL'})}
SIDE_DIR = {'N': 1, 'S': 2, 'E': 4, 'W': 8}
LOUNGE_STATE = {frozenset('N'): 1, frozenset('S'): 2, frozenset('E'): 4, frozenset('W'): 8,
                frozenset('NE'): 5, frozenset('SE'): 6, frozenset('NW'): 9, frozenset('SW'): 10}


def base(a):
    return a.split('{')[0]


class Map:
    def __init__(self):
        self.m = DMM.from_file(str(MAP))
        self.log = defaultdict(int)

    def tile(self, p):
        x, y = p
        if not (1 <= x <= self.m.size.x and 1 <= y <= self.m.size.y):
            return ('/turf/space', '/area/space')
        return self.m.get_tile((x, y, 1))

    def area(self, p):
        return next(a for a in self.tile(p) if a.startswith('/area'))

    def turf(self, p):
        return next(a for a in self.tile(p) if a.startswith('/turf'))

    def hall(self, p):
        return self.area(p).startswith('/area/station/hallway/')

    def wall(self, p):
        return base(self.turf(p)).startswith(('/turf/simulated/wall', '/turf/simulated/mineral', '/turf/unsimulated/wall'))

    def window(self, p):
        return any(base(a).startswith(('/obj/effect/spawner/window', '/obj/structure/grille', '/obj/structure/window'))
                   for a in self.tile(p))

    def door(self, p):
        return any(base(a).startswith('/obj/machinery/door') and not base(a).startswith(('/obj/machinery/door/firedoor', '/obj/machinery/door_control'))
                   for a in self.tile(p))

    def floor(self, p):
        return base(self.turf(p)).startswith('/turf/simulated/floor') and not self.window(p)

    def add(self, p, atom, what):
        t = list(self.tile(p))
        i = next(i for i, a in enumerate(t) if a.startswith('/turf'))
        t.insert(i, atom)
        self.m.set_tile((p[0], p[1], 1), tuple(t))
        self.log[what] += 1

    def set_turf(self, p, atom):
        t = tuple(atom if a.startswith('/turf') else a for a in self.tile(p))
        self.m.set_tile((p[0], p[1], 1), t)


def dept_of(area):
    for keys, colour, bench, guide, wall in DEPTS:
        if any(k in area for k in keys):
            return keys, colour, bench, guide, wall
    return None


def nb(p, d):
    dx, dy, _ = DIRS[d]
    return (p[0] + dx, p[1] + dy)


def behind(M, p, d):
    """Area of the room across the wall on side d (up to 3 tiles away)."""
    q = p
    for _ in range(3):
        q = nb(q, d)
        if M.floor(q) and not M.door(q) and not M.hall(q):
            return M.area(q)
        if M.floor(q) and M.hall(q):
            return None
    return None


def free_floor(M, p):
    """Hallway floor with nothing standing on it (wall mounts and decals are fine)."""
    if not M.hall(p) or not M.floor(p) or M.door(p):
        return False
    for a in M.tile(p):
        b = base(a)
        if b.startswith(('/turf', '/area', '/obj/effect/turf_decal', '/obj/structure/cable', '/obj/machinery/atmospherics/pipe',
                         '/obj/structure/disposalpipe', '/obj/machinery/light/', '/obj/structure/sign', '/obj/machinery/camera')) or b == '/obj/machinery/light':
            continue
        if '/directional/' in b or re.search(r'pixel_[xy] = -?(1[6-9]|[2-3][0-9])', a):
            return False  # something hangs on the wall here: keep its spot clear
        return False
    return True


def door_near(M, p):
    return any(M.door(nb(p, d)) for d in DIRS)


def width(M, p, d):
    """Free hallway tiles from p away from the wall on side d."""
    n, q = 0, p
    while M.hall(q) and M.floor(q) and n < 12:
        n += 1
        q = nb(q, OPP[d])
    return n


def face_free(M, p, d):
    """The wall on side d of p is solid and nothing hangs on that face yet."""
    w = nb(p, d)
    if not M.wall(w) or 'shuttle' in M.turf(w) or any(base(a).startswith('/obj') for a in M.tile(w)):
        return False
    if M.door(p) or 'shuttle' in M.turf(p) or '/shuttle/' in M.area(p):
        return False
    for a in M.tile(p):
        b = base(a)
        if b.endswith('/directional/' + {'N': 'north', 'S': 'south', 'E': 'east', 'W': 'west'}[d]):
            return False
        px = re.search(r'pixel_x = (-?\d+)', a)
        py = re.search(r'pixel_y = (-?\d+)', a)
        px = int(px[1]) if px else 0
        py = int(py[1]) if py else 0
        if d == 'N' and py >= 16 or d == 'S' and py <= -16 or d == 'E' and px >= 16 or d == 'W' and px <= -16:
            return False
        if b == '/obj/machinery/light' or b.startswith('/obj/machinery/light/'):
            dm = re.search(r'dir = (\d+)', a)
            if (int(dm[1]) if dm else 2) == SIDE_DIR[d]:
                return False
        if b.startswith('/obj/machinery/camera') and not px and not py:
            dm = re.search(r'dir = (\d+)', a)  # a camera in the wall looks away from it
            if (int(dm[1]) if dm else 2) == SIDE_DIR[OPP[d]]:
                return False
    return True


def paint(M, tiles):
    for p in tiles:
        turf = M.turf(p)
        if base(turf) != '/turf/simulated/floor/plasteel':
            continue
        st = re.search(r'icon_state = "([^"]+)"', turf)
        if st and st[1] != 'neutralfull':
            continue
        if re.sub(r'(icon_state = "neutralfull"|dir = \d+);?', '', turf.split('{', 1)[1] if '{' in turf else '}').strip('{} ;'):
            continue  # other custom vars: leave alone
        if M.door(p) or any(base(a).startswith('/obj/machinery/door') for a in M.tile(p)):
            continue  # door and firedoor tiles keep their floor
        area = M.area(p)
        sides = [d for d in DIRS if not (M.hall(nb(p, d)) and M.floor(nb(p, d))) or M.door(nb(p, d))]
        if not sides:
            continue
        if area.endswith(('/hallway/secondary/entry', '/hallway/secondary/exit')):
            key = frozenset(''.join(s for s in sides))
            if key not in LOUNGE_STATE:
                key = next((k for k in LOUNGE_STATE if len(k) == 2 and k <= key), None) or frozenset(sides[0])
            name = 'arrival' if area.endswith('entry') else 'escape'
            d = LOUNGE_STATE[key]
            M.set_turf(p, f'/turf/simulated/floor/plasteel{{{"dir = %d;" % d if d != 2 else ""}icon_state = "{name}"}}')
            M.log['floor: lounge trim'] += 1
            continue
        quarters, colour = set(), None
        for d in sides:
            dep = dept_of(behind(M, p, d) or '')
            if M.door(nb(p, d)):
                q = nb(p, d)
                dep = dept_of(M.area(q)) or dept_of(M.area(nb(q, d))) or dep
            c = dep[1] if dep else None
            if c and colour is None:
                colour = c
            if c and M.door(nb(p, d)):
                quarters |= HALF[d]
            else:
                quarters.add(QUARTER[d])
        q = frozenset(quarters)
        q = DIAG.get(q, q)
        if q not in STATE:
            continue
        suffix, d = STATE[q]
        name = (colour or 'neutral') + suffix
        M.set_turf(p, f'/turf/simulated/floor/plasteel{{{"dir = %d;" % d if d != 2 else ""}icon_state = "{name}"}}')
        M.log['floor: ' + (colour or 'neutral') + ' trim'] += 1


def runs_along(M, tiles, d):
    """Contiguous runs of hallway tiles that have a wall (or window) on side d."""
    edge = sorted(p for p in tiles if (M.wall(nb(p, d)) or M.window(nb(p, d))))
    horiz = d in 'NS'
    key = (lambda p: (p[1], p[0])) if horiz else (lambda p: (p[0], p[1]))
    edge.sort(key=key)
    runs, cur = [], []
    for p in edge:
        if cur and key(p) == (key(cur[-1])[0], key(cur[-1])[1] + 1):
            cur.append(p)
        else:
            if cur:
                runs.append(cur)
            cur = [p]
    if cur:
        runs.append(cur)
    return runs


def bench_atoms(colour_suffix, d, n):
    face = SIDE_DIR[OPP[d]]
    root = '/obj/structure/chair/sofa/bench'
    tail = f'/{colour_suffix}' if colour_suffix else ''
    dirv = f'{{dir = {face}}}' if face != 2 else ''
    parts = ['left'] + ['mid'] * (n - 2) + ['right']
    if d in 'NE':  # seen from the corridor the order flips with the facing
        parts = parts[::-1]
    out = []
    for part in parts:
        path = root + tail if part == 'mid' else f'{root}/{part}{tail}'
        out.append(path + dirv)
    return out


def nooks(M, tiles, plants_at):
    placed = []
    for d in 'NSWE':
        for run in runs_along(M, tiles, d):
            i = 0
            while i + 4 <= len(run):
                seg = run[i:i + 5] if i + 5 <= len(run) else run[i:i + 4]
                ok = all(free_floor(M, p) and not door_near(M, p) and width(M, p, d) >= 4 for p in seg)
                ok = ok and all(abs(seg[len(seg) // 2][0] - q[0]) + abs(seg[len(seg) // 2][1] - q[1]) >= 10 for q in placed)
                if not ok:
                    i += 1
                    continue
                if any('shuttle' in M.turf(p) for p in seg):
                    i += 1
                    continue
                mid = seg[len(seg) // 2]
                dep = dept_of(behind(M, mid, d) or '')
                n = len(seg) - 2
                for p, atom in zip(seg[1:-1], bench_atoms(dep[2] if dep else None, d, n)):
                    M.add(p, atom, 'bench tiles')
                for p in (seg[0], seg[-1]):
                    M.add(p, RNG.choice(PLANTS), 'potted plants')
                    plants_at.append(p)
                placed.append(mid)
                i += len(seg) + 8
    return placed


def corner_plants(M, tiles, plants_at):
    for p in sorted(tiles):
        walls = [d for d in DIRS if M.wall(nb(p, d))]
        if len(walls) != 2 or set(walls) in ({'N', 'S'}, {'E', 'W'}):
            continue
        if not free_floor(M, p) or door_near(M, p):
            continue
        if any(abs(p[0] - q[0]) + abs(p[1] - q[1]) < 7 for q in plants_at):
            continue
        M.add(p, RNG.choice(PLANTS), 'potted plants')
        plants_at.append(p)


def wall_plants(M, tiles, plants_at):
    """Plants along walls (Cyberiad keeps 5.6 per 100 hallway tiles); not dense, so 3-wide corridors stay open."""
    for d in 'NSWE':
        for run in runs_along(M, tiles, d):
            for p in run[2:-2]:
                if not M.wall(nb(p, d)) or not free_floor(M, p) or door_near(M, p) or width(M, p, d) < 3:
                    continue
                if 'shuttle' in M.turf(p) or any(abs(p[0] - q[0]) + abs(p[1] - q[1]) < 9 for q in plants_at):
                    continue
                M.add(p, RNG.choice(PLANTS), 'potted plants')
                plants_at.append(p)


def vases(M, tiles):
    for p in tiles:
        t = M.tile(p)
        if any(base(a).startswith('/obj/structure/table') for a in t) and not any(base(a).startswith('/obj/item') or base(a).startswith('/obj/machinery') for a in t):
            M.add(p, '/obj/item/goon_vase/random', 'vases on hallway tables')


def wall_decor(M, tiles, nook_mids):
    hung = []
    clocks = set()
    for d in 'NSWE':
        for run in runs_along(M, tiles, d):
            k = RNG.randrange(3)
            while k < len(run):
                p = run[k]
                if not (M.wall(nb(p, d)) and face_free(M, p, d)) or any(abs(p[0] - q[0]) + abs(p[1] - q[1]) < 7 for q in hung):
                    k += 1
                    continue
                area = M.area(p)
                dep = dept_of(behind(M, p, d) or '')
                if area not in clocks and len(run) >= 12 and '/primary/' in area:
                    atom = '/obj/structure/goon_clock'
                    clocks.add(area)
                elif dep and dep[4] and RNG.random() < 0.6:
                    atom = RNG.choice(dep[4])
                elif area.endswith('/hallway/secondary/exit'):
                    atom = RNG.choice(['/obj/structure/sign/goon/iso/evacuation', '/obj/structure/sign/poster/official/random'])
                else:
                    atom = RNG.choice(GENERIC_WALL)
                M.add(p, f'{atom}{{{PIX[d]}}}', 'wall decor')
                hung.append(p)
                k += 9


def guides(M, tiles):
    done = set()
    for p in sorted(tiles):
        for d in DIRS:
            q = nb(p, d)
            if not M.door(q):
                continue
            room = nb(q, d) if M.hall(q) else q  # door tile may be zoned as the hallway
            if M.hall(room):
                continue
            dep = dept_of(M.area(room))
            if not dep or dep[3] in done:
                continue
            if not free_floor(M, p) and not M.floor(p):
                continue
            if any(base(a).startswith('/obj/effect/turf_decal') for a in M.tile(p)):
                continue
            M.add(p, f'/obj/effect/turf_decal/goon_guide/{dep[3]}', 'floor guides')
            done.add(dep[3])
            break


def main():
    M = Map()
    tiles = [(x, y) for x in range(1, M.m.size.x + 1) for y in range(1, M.m.size.y + 1)
             if M.hall((x, y)) and M.floor((x, y))]
    if any(base(a).startswith(('/obj/structure/sign/goon/poster', '/obj/structure/goon_clock')) for p in tiles for a in M.tile(p)):
        sys.exit('hallway decor already placed; this script runs once')
    paint(M, tiles)
    plants_at = []
    mids = nooks(M, tiles, plants_at)
    corner_plants(M, tiles, plants_at)
    wall_plants(M, tiles, plants_at)
    vases(M, tiles)
    wall_decor(M, tiles, mids)
    guides(M, tiles)
    M.m.to_file(str(MAP))
    for k, v in sorted(M.log.items()):
        print(f'{k}: {v}')


if __name__ == '__main__':
    main()
