"""Repair Ulthor decor directions (user, 2026-11-20). Incremental and idempotent.

1. Hallway floors: the floor trim of 1eb6608c (hall_decor.py) is reverted -
   a hallway tile whose turf is still exactly what that commit painted gets its
   turf from before the commit back. Floors repainted since stay.
2. Sofas and benches: ends follow the reference maps (Delta, Cyberiad):
   "left" is the viewer's left looking at the seat - facing south the left end
   is west, facing north east, facing east south, facing west north. A seat
   that faces a wall while its back is open is turned round.
3. Wall planters (Goon ppot1-5, /kirbyplants/goon and /goon/pot2-5) hang on a
   wall: dir by the wall side as their sprites are drawn - wall east 4, west 8,
   north 1, south 2. One standing free in a room becomes a floor plant.
4. Wall disposal bins face their mounting side. East and west shift by
   pixel_x +24 and -24 respectively, north lifts by pixel_y 16, and south
   stays at its default offset. Wall mounts on the bin's face move along the wall.
5. Posters: random and most Goon posters become concrete Nanotrasen posters
   (contraband in the bar, arcade, theatre and similar), so the map shows
   what hangs where; department Goon signs stay.
"""
import hashlib
import re
import subprocess
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
sys.path.insert(0, str(Path(__file__).resolve().parent))
from dmm import DMM  # noqa: E402
from check_disposals import WALL_BIN_APPEARANCE  # noqa: E402
from rooms import MAP, is_wall, is_floor, is_boundary  # noqa: E402

DECOR_COMMIT = '1eb6608c'
N4 = {'N': (0, 1), 'S': (0, -1), 'E': (1, 0), 'W': (-1, 0)}
DIRN = {1: 'N', 2: 'S', 4: 'E', 8: 'W'}
NDIR = {v: k for k, v in DIRN.items()}
OPP = {'N': 'S', 'S': 'N', 'E': 'W', 'W': 'E'}
STATS = Counter()

OFFICIAL = ['nanotrasen_logo', 'cleanliness', 'help_others', 'build', 'bless_this_spess', 'here_for_your_safety',
            'safety_report', 'work_for_a_future', 'ian', 'love_ian', 'obey', 'keepcalm', 'fruit_bowl', 'healthy',
            'fitness', 'hardwork', 'report_crimes', 'do_not_question', 'walk', 'state_laws', 'space_a', 'space_b',
            'the_owl', 'corploveyou', 'get_your_legs', 'pda_ad', 'mr_cheng', 'breakfast', 'tell_all_the_people',
            'safety_internals', 'safety_eye_protection', 'explosionsafe', 'clearstation', 'assist_pride', 'enlist',
            'soft_cap_pop_art', 'anniversary_vintage_reprint', 'sweet_ginger_green']
CONTRA = ['lamarr', 'lusty_xenomorph', 'red_rum', 'eat', 'have_a_puff', 'smoke', 'kss13', 'cc64k_ad', 'donut_corp',
          'clown', 'night_cat_blues', 'the_griffin', 'rip_badger', 'lostcat', 'missing_gloves', 'cattraction',
          'bread', 'free_tonto', 'kerberos_show', 'ambrosia_vulgaris', 'power_people', 'fun_police']
FUN_AREAS = ('/service/bar', '/commons/arcade', '/service/theatre', '/service/clown', '/service/mime',
             '/commons/pet_store', '/maintenance/')
GOON_KEEP = ('pack_smart', 'grow_food', 'rat', 'new_you', 'capy_king')  # tied to the room they hang in
PLANTER = re.compile(r'^/obj/item/twohanded/required/kirbyplants/goon(/pot[2-5])?$')
FLOOR_PLANTS = ['/obj/item/twohanded/required/kirbyplants/goon/plant%d' % i for i in range(1, 8)]
MOUNTS = ('/obj/machinery/alarm', '/obj/machinery/firealarm', '/obj/item/radio/intercom', '/obj/machinery/light_switch',
          '/obj/machinery/newscaster', '/obj/structure/extinguisher_cabinet', '/obj/machinery/camera',
          '/obj/structure/sign', '/obj/machinery/status_display', '/obj/machinery/requests_console')


def base(a):
    return a.split('{')[0]


def var(a, name):
    m = re.search(r'\b%s = (-?\d+)' % name, a)
    return int(m[1]) if m else None


def setvars(a, **kw):
    b = base(a)
    body = a[len(b) + 1:-1] if '{' in a else ''
    items = [s.strip() for s in body.split(';') if s.strip()]
    items = [s for s in items if s.split('=')[0].strip() not in kw]
    items += [f'{k} = {v}' for k, v in kw.items() if v is not None]
    return b + ('{' + '; '.join(items).replace('; ', ';') + '}' if items else '')


def pick(seq, key):
    return seq[int(hashlib.md5(key.encode()).hexdigest(), 16) % len(seq)]


def defined_types():
    out = set()
    for f in (ROOT / 'code').rglob('*.dm'):
        for line in f.read_text(encoding='utf-8', errors='ignore').splitlines():
            if line.startswith('/obj/structure/chair/sofa') or line.startswith('/obj/structure/sign/poster'):
                out.add(line.strip())
    return out


class Map:
    def __init__(self, m):
        self.m = m
        self.X, self.Y, _ = m.size

    def tile(self, p):
        x, y = p
        if not (1 <= x <= self.X and 1 <= y <= self.Y):
            return ('/turf/space', '/area/space')
        return self.m.get_tile((x, y, 1))

    def set(self, p, tile):
        self.m.set_tile((p[0], p[1], 1), tuple(tile))

    def area(self, p):
        return base(self.tile(p)[-1])

    def wall(self, p):
        t = self.tile(p)
        return is_wall(t) and not is_boundary(t)

    def open(self, p):
        t = self.tile(p)
        return is_floor(t) and not is_wall(t) and not is_boundary(t)


def nb(p, d):
    return (p[0] + N4[d][0], p[1] + N4[d][1])


def git_map(rev):
    data = subprocess.run(['git', 'show', f'{rev}:_maps/map_files/Ulthor/Ulthor.dmm'], cwd=ROOT,
                          capture_output=True, check=True).stdout
    tmp = Path(__file__).resolve().parent / f'_decor_repair_{rev.replace("^", "p")}.dmm'
    tmp.write_bytes(data)
    try:
        return DMM.from_file(str(tmp))
    finally:
        tmp.unlink()


def turf_of(tile):
    return next(a for a in tile if a.startswith('/turf'))


def revert_floors(M):
    pre, post = git_map(DECOR_COMMIT + '^'), git_map(DECOR_COMMIT)
    for (x, y, z) in M.m.grid:
        if z != 1 or '/area/station/hallway/' not in M.area((x, y)):
            continue
        cur = list(M.tile((x, y)))
        try:
            a, b = turf_of(pre.get_tile((x, y, 1))), turf_of(post.get_tile((x, y, 1)))
        except (KeyError, StopIteration):
            continue
        c = turf_of(cur)
        if c == b and a != b:
            cur[cur.index(c)] = a
            M.set((x, y), cur)
            STATS['hallway floors restored'] += 1


def sofa_parts(a):
    segs = base(a)[len('/obj/structure/chair/sofa'):].strip('/').split('/')
    segs = [s for s in segs if s]
    part = next((s for s in segs if s in ('left', 'right', 'corner', 'solo')), 'mid')
    fam = tuple(s for s in segs if s not in ('left', 'right', 'corner', 'solo'))
    return fam, part


def sofa_path(fam, part):
    segs = list(fam)
    if part != 'mid':
        if segs and segs[0] == 'bench':
            segs = ['bench', part] + segs[1:]
        else:
            segs = segs + [part]
    return '/obj/structure/chair/sofa' + ''.join('/' + s for s in segs)


def corner(M, p, fam):
    return any(base(a).startswith('/obj/structure/chair/sofa') and sofa_parts(a) == (fam, 'corner') for a in M.tile(p))


def fix_sofas(M, types):
    seats = {}
    for (x, y, z) in M.m.grid:
        if z != 1:
            continue
        for i, a in enumerate(M.tile((x, y))):
            if base(a).startswith('/obj/structure/chair/sofa'):
                fam, part = sofa_parts(a)
                if part != 'corner':
                    seats[(x, y)] = [i, a, fam, var(a, 'dir') or 2]
    # turn seats that face a wall with an open back
    for p, s in seats.items():
        d = DIRN.get(s[3])
        if d and M.wall(nb(p, d)) and M.open(nb(p, OPP[d])):
            s[3] = NDIR[OPP[d]]
            STATS['seats turned from a wall'] += 1
    done = set()
    for p, s in seats.items():
        if p in done:
            continue
        d = DIRN.get(s[3])
        if not d:
            continue
        axis = 'EW' if d in 'NS' else 'NS'
        run = [p]
        for step in axis:
            q = nb(p, step)
            while q in seats and seats[q][2] == s[2] and seats[q][3] == s[3]:
                run.append(q)
                q = nb(q, step)
        run.sort()
        done.update(run)
        # viewer's left end: facing S -> west (min x), N -> east, E -> south (min y), W -> north
        if d in 'NW':
            run = run[::-1]
        # an end that joins a corner piece has no armrest
        step = (run[-1][0] - run[0][0], run[-1][1] - run[0][1]) if len(run) > 1 else None
        ends = []
        for q, sign in ((run[0], -1), (run[-1], 1)):
            dirs = [k for k in axis] if not step else [k for k in axis if (N4[k][0] * step[0] + N4[k][1] * step[1]) * sign > 0]
            ends.append(any(corner(M, nb(q, k), s[2]) for k in dirs))
        if len(run) == 1:
            ends = [False, False]
            left_k = 'W' if d == 'S' else 'E' if d == 'N' else 'S' if d == 'E' else 'N'
            right_k = OPP[left_k]
            ends = [corner(M, nb(run[0], left_k), s[2]), corner(M, nb(run[0], right_k), s[2])]
        for k, q in enumerate(run):
            first, last = k == 0, k == len(run) - 1
            if first and last:
                part = 'mid' if all(ends) else 'right' if ends[0] else 'left' if ends[1] else 'solo'
            elif first:
                part = 'mid' if ends[0] else 'left'
            elif last:
                part = 'mid' if ends[1] else 'right'
            else:
                part = 'mid'
            path = sofa_path(s[2], part)
            if path not in types:
                path = sofa_path(s[2], 'mid') if part == 'solo' else None
            if not path or path not in types:
                continue
            i, a, fam, dirv = seats[q]
            new = setvars(path + (a[len(base(a)):]), dir=(dirv if dirv != 2 else None))
            if new != a:
                tile = list(M.tile(q))
                tile[i] = new
                M.set(q, tile)
                STATS['sofa/bench tiles fixed'] += 1


def wall_side(M, p, prefer):
    walls = [d for d in prefer if M.wall(nb(p, d))]
    return walls[0] if walls else None


def fix_planters(M):
    for (x, y, z) in list(M.m.grid):
        if z != 1:
            continue
        p = (x, y)
        tile = list(M.tile(p))
        for i, a in enumerate(tile):
            if not PLANTER.match(base(a)):
                continue
            cur = DIRN.get(var(a, 'dir') or 2)
            if M.wall(nb(p, cur)):
                continue  # already hangs on its wall
            side = wall_side(M, p, 'NEWS')
            if side:
                new = setvars(a, dir=(NDIR[side] if side != 'S' else None), pixel_x=None, pixel_y=None)
                STATS['wall planters turned to their wall'] += 1
            else:
                new = pick(FLOOR_PLANTS, f'{x},{y}')
                STATS['free-standing planters -> floor plants'] += 1
            tile[i] = new
            M.set(p, tile)


def mount_face(a):
    b = base(a)
    m = re.search(r'/directional/(north|south|east|west)', b)
    if m:
        return m[1][0].upper()
    px, py = var(a, 'pixel_x') or 0, var(a, 'pixel_y') or 0
    if max(abs(px), abs(py)) >= 20:
        return 'E' if px >= 20 else 'W' if px <= -20 else 'N' if py >= 20 else 'S'
    if b.startswith('/obj/machinery/camera'):
        d = DIRN.get(var(a, 'dir') or 2)
        return OPP[d] if d else None  # a camera looks away from its wall
    return None


def fix_bins(M):
    for (x, y, z) in list(M.m.grid):
        if z != 1:
            continue
        p = (x, y)
        tile = list(M.tile(p))
        for i, a in enumerate(tile):
            if not base(a).startswith('/obj/machinery/disposal/wall'):
                continue
            side = wall_side(M, p, 'NSEW')
            if not side:
                print('wall bin without a wall', p)
                continue
            direction, pixel_x, pixel_y = WALL_BIN_APPEARANCE[NDIR[side]]
            new = setvars('/obj/machinery/disposal/wall' + a[len(base(a)):],
                          dir=direction if side != 'S' else None,
                          pixel_x=pixel_x or None, pixel_y=pixel_y or None)
            if new != a:
                tile[i] = new
                M.set(p, tile)
                STATS['wall bins on their wall frame'] += 1
            for j, m in reversed(list(enumerate(tile))):
                if j == i or not base(m).startswith(MOUNTS) or mount_face(m) != side:
                    continue
                dest = free_face(M, p, side)
                if not dest:
                    print('no free wall face for', base(m), 'at bin', p)
                    continue
                tile = list(M.tile(p))
                tile.remove(m)
                M.set(p, tile)
                t2 = list(M.tile(dest))
                t2.insert(len(t2) - 2, m)
                M.set(dest, t2)
                STATS['wall mounts moved off bins'] += 1
            break


def free_face(M, p, side):
    along = 'EW' if side in 'NS' else 'NS'
    for k in range(1, 5):
        for d in along:
            q = p
            for _ in range(k):
                q = nb(q, d)
            if not M.open(q) or not M.wall(nb(q, side)):
                continue
            busy = any(mount_face(a) == side for a in M.tile(q) if base(a).startswith(MOUNTS + ('/obj/machinery/disposal/wall', '/obj/machinery/power/apc', '/obj/machinery/light')))
            busy = busy or any(base(a).startswith('/obj/machinery/disposal/wall') for a in M.tile(q))
            if not busy:
                return q
    return None


def fix_posters(M, types):
    for (x, y, z) in list(M.m.grid):
        if z != 1:
            continue
        p = (x, y)
        tile = list(M.tile(p))
        changed = False
        for i, a in enumerate(tile):
            b = base(a)
            fun = any(k in M.area(p) for k in FUN_AREAS)
            if b in ('/obj/structure/sign/poster/official/random', '/obj/structure/sign/poster/random',
                     '/obj/structure/sign/poster/contraband/random'):
                pool = 'contraband' if (fun or 'contraband' in b) else 'official'
            elif b.startswith('/obj/structure/sign/goon/poster/') and b.rsplit('/', 1)[-1] not in GOON_KEEP:
                if int(hashlib.md5(f'{x},{y}'.encode()).hexdigest(), 16) % 3 == 0:
                    continue  # every third Goon poster stays for the mix
                pool = 'contraband' if fun else 'official'
            else:
                continue
            name = pick(CONTRA if pool == 'contraband' else OFFICIAL, f'{x},{y},{i}')
            path = f'/obj/structure/sign/poster/{pool}/{name}'
            if path not in types:
                continue
            tile[i] = path + a[len(b):]
            changed = True
            STATS[f'posters -> {pool}'] += 1
        if changed:
            M.set(p, tile)


def main():
    types = defined_types()
    M = Map(DMM.from_file(str(MAP)))
    revert_floors(M)
    fix_sofas(M, types)
    fix_planters(M)
    fix_bins(M)
    fix_posters(M, types)
    M.m.to_file(str(MAP))
    for k, v in STATS.items():
        print(f'{v:5}  {k}')


if __name__ == '__main__':
    main()
