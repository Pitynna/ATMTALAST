"""Re-lay Ulthor's air distribution (supply / distro) and waste (scrubbers)
pipes as an incremental edit of the current map.

* All hidden supply and scrubber pipes are removed and laid again as two trees
  rooted in atmospherics: distro leaves the "air to distribution" pump through
  the universal adapter at (175,124) -> (175,123); waste returns through the
  universal adapter at (178,124) <- (178,123).
* Every station vent and scrubber is a terminal and is turned to face the
  pipe it is attached to. Vents with an id_tag/frequency (gas tanks, airlock
  cyclers) or attached to their own regular-pipe loop (server, turbine,
  perma) are left untouched.
* Rooms get the Delta/Cyberiad number of vents and scrubbers (thin_air.target); gas chambers (rooms
  with an injector or tank vent) are not counted. Maintenance passages get
  none and lose their vents, scrubbers and air alarms (pipes may still pass).
  Missing ones are added far from the existing ones.
* Every area with vents or scrubbers gets an air alarm: an alarm controls the
  vents and scrubbers whose tile is in its own area
  (code/game/machinery/alarm.dm, alarm_area = get_area(src)).

Routing prefers old pipe runs, maintenance and corridors; pipes enter rooms
through doors and windows, and a solid wall is a last resort. Scrubbers prefer tiles that already carry distro,
so both lines run together. Refuses to run over uncommitted map edits that
are not its own previous output (the user may be editing in StrongDMM).
"""
import hashlib
import heapq
import math
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
sys.path.insert(0, str(Path(__file__).resolve().parent))
from dmm import DMM  # noqa: E402
from rooms import Station, is_floor, is_boundary, is_wall, is_door  # noqa: E402
from check_pipes import parse, DELTA, REV  # noqa: E402
from thin_air import target  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
STAMP = ROOT / 'docs/ulthor_air/last_output.sha256'
ATMOS = '/obj/machinery/atmospherics'
VENT = ATMOS + '/unary/vent_pump'
SCRUB = ATMOS + '/unary/vent_scrubber'
OLD_PIPE = re.compile(r'^/obj/machinery/atmospherics/pipe/(simple|manifold|manifold4w|cap)/hidden/(supply|scrubbers)$')
RESERVED = {(x, y) for x in range(145, 150) for y in range(130, 142)}  # future engine room
ROOTS = {'supply': ((175, 123), 1), 'scrubbers': ((178, 123), 1)}  # tile, forced dir to the adapter
NO_NORM = ('/area/space', '/area/shuttle', '/area/station/solars', '/area/station/engineering/ulthor_engine_room')
TILES_PER_PAIR = 30
WALL_COST = 1000.0
# Maintenance passages have no vents, scrubbers or air alarms (user,
# 2026-11-16); distro and waste pipes may still run through them. The turbine
# room is a machine room, and airlock cycler vents (id_tag) stay.
NO_AIR = '/area/station/maintenance'
NO_AIR_EXCEPT = ('/area/station/maintenance/turbine',)
DIR_BITS = (1, 2, 4, 8)
WALL_MOUNT = ('/obj/machinery/light', '/obj/machinery/alarm', '/obj/machinery/firealarm', '/obj/machinery/power/apc',
              '/obj/machinery/camera', '/obj/machinery/light_switch', '/obj/machinery/status_display',
              '/obj/machinery/newscaster', '/obj/machinery/requests_console', '/obj/machinery/door_control',
              '/obj/item/radio/intercom', '/obj/structure/sign', '/obj/structure/extinguisher_cabinet',
              '/obj/machinery/ai_status_display', '/obj/machinery/keycard_auth', '/obj/machinery/flasher',
              '/obj/structure/closet/fireaxecabinet', '/obj/machinery/button', '/obj/machinery/economy/atm',
              '/obj/structure/noticeboard', '/obj/machinery/firealarm', '/obj/machinery/defibrillator_mount')
FREE_OBJ = ('/obj/effect', '/obj/structure/cable', '/obj/structure/disposalpipe', '/obj/machinery/navbeacon',
            '/obj/item') + WALL_MOUNT
ALARM_PIX = {1: 'pixel_x = 0;pixel_y = 24', 2: 'pixel_x = 0;pixel_y = -24',
             4: 'pixel_x = 24;pixel_y = 0', 8: 'pixel_x = -24;pixel_y = 0'}


def path(a):
    return a.split('{')[0]


def adir(a, default=2):
    m = re.search(r'\bdir = (\d+)', a)
    return int(m[1]) if m else default


def with_dir(a, d):
    if re.search(r'\bdir = \d+', a):
        return re.sub(r'\bdir = \d+', f'dir = {d}', a, count=1)
    if '{' in a:
        return a.replace('{', '{dir = %d;' % d, 1)
    return a + '{dir = %d}' % d


def step(p, d):
    dx, dy = DELTA[d]
    return (p[0] + dx, p[1] + dy)


class Map:
    def __init__(self):
        self.m = DMM.from_file(str(MAP))
        self.st = Station(self.m)
        self.t = {(x, y): list(self.m.get_tile((x, y, 1))) for (x, y, z) in self.m.grid}
        self.orig = {p: tuple(v) for p, v in self.t.items()}

    def area(self, p):
        return self.t[p][-1] if p in self.t else '/area/space'

    def turf(self, p):
        return next(a for a in self.t[p] if a.startswith('/turf'))

    def has(self, p, prefix):
        return any(a.startswith(prefix) for a in self.t.get(p, ()))


def fixed_device(M, p, atom):
    """Vents that are not part of distro/waste: tank and airlock vents, and
    vents attached to a regular pipe loop (they connect to layer 1 too)."""
    if 'id_tag' in atom or 'frequency' in atom:
        return True
    d = adir(atom)
    n = step(p, d)
    if 1 not in parse(atom)[2]:  # connect_types without layer 1
        return False
    for b in M.t.get(n, ()):
        if not b.startswith(ATMOS) or OLD_PIPE.match(path(b)) or path(b).startswith((VENT, SCRUB)):
            continue
        q = parse(b)
        if q is None:
            if path(b).startswith((ATMOS + '/binary', ATMOS + '/trinary', ATMOS + '/unary')):
                return True
            continue
        if q[1] & REV[d] and 1 in q[2]:
            return True
    return False


def station(a):
    """Ulthor also uses /area/hydroponics and /area/janitor for station rooms."""
    return not a.startswith(('/area/space', '/area/shuttle'))


def main():
    if subprocess.run(['git', 'diff', '--quiet', '--', str(MAP)], cwd=ROOT).returncode:
        mine = STAMP.is_file() and STAMP.read_text().strip() == hashlib.sha256(MAP.read_bytes()).hexdigest()
        if not mine:
            sys.exit('Ulthor.dmm has uncommitted edits (StrongDMM?) - commit them first.')
        MAP.write_bytes(subprocess.run(['git', 'show', 'HEAD:_maps/map_files/Ulthor/Ulthor.dmm'], cwd=ROOT,
                                       capture_output=True, check=True).stdout)
    M = Map()
    t = M.t
    report = []

    def no_air(a):
        return a.startswith(NO_AIR) and not a.startswith(NO_AIR_EXCEPT)

    stripped = 0
    for p, tile in t.items():
        if no_air(M.area(p)):
            keep = [a for a in tile if not (path(a).startswith('/obj/machinery/alarm') or
                                            (path(a).startswith((VENT, SCRUB)) and 'id_tag' not in a))]
            stripped += len(tile) - len(keep)
            t[p] = keep

    # ---- inventory --------------------------------------------------------
    old_pipe = {'supply': set(), 'scrubbers': set()}
    old_ends = set()
    for p, tile in t.items():
        for a in tile:
            mm = OLD_PIPE.match(path(a))
            if mm:
                old_pipe[mm[2]].add(p)
                q = parse(a)
                for d in DIR_BITS:
                    if q and q[1] & d:
                        n = step(p, d)
                        if not any((parse(b) or (0, 0, set()))[1] & REV[d] for b in t.get(n, ())):
                            old_ends.add(p)
    terminals = {'supply': [], 'scrubbers': []}
    fixed = []
    for p, tile in t.items():
        if not station(M.area(p)):
            continue
        for a in tile:
            k = 'supply' if path(a).startswith(VENT) else 'scrubbers' if path(a).startswith(SCRUB) else None
            if k:
                (fixed.append(p) if fixed_device(M, p, a) else terminals[k].append(p))

    # Chambers: rooms with an injector or a tank vent are not ventilated.
    chamber = set()
    room_of = {}
    for comp in M.st.rooms():
        cs = set((x, y) for x, y in comp)
        for q in cs:
            room_of[q] = cs
        if any(M.has(q, ATMOS + '/unary/outlet_injector') or q in fixed and 'id_tag' in ' '.join(t[q]) for q in cs):
            chamber |= cs

    # ---- routable tiles ------------------------------------------------------
    def base_ok(p):
        """Pipes may share a tile with other-layer pipes, never with devices."""
        if p in RESERVED or p not in t or not station(M.area(p)):
            return False
        if M.turf(p).startswith('/turf/space'):
            return False
        for a in t[p]:
            if not a.startswith(ATMOS) or path(a).startswith((VENT, SCRUB)) or OLD_PIPE.match(path(a)):
                continue
            q = parse(a)
            if q is None or q[2] & {2, 3}:
                return False
        return True

    def shared(p):
        return any(a.startswith(ATMOS + '/pipe') and not OLD_PIPE.match(path(a)) for a in t[p])

    assigned = {}  # (tile, kind) -> dir chosen while routing

    def attach_ok(p, tm):
        """A vent facing p joins every layer-1 pipe there that points back at
        it, and a vent or scrubber on p that faces it (both use layer 1)."""
        d = next(d for d in DIR_BITS if step(p, d) == tm)
        for a in t[p]:
            if not a.startswith(ATMOS) or OLD_PIPE.match(path(a)):
                continue
            if path(a).startswith((VENT, SCRUB)):
                k = 'supply' if path(a).startswith(VENT) else 'scrubbers'
                e = adir(a) if p in fixed else assigned.get((p, k))
                if e and step(p, e) == tm:
                    return False
            elif (q := parse(a)) and q[1] & d and 1 in q[2]:
                return False
        return True

    reach = set()
    stack = [r for r, _ in ROOTS.values()]
    while stack:
        p = stack.pop()
        if p in reach or not base_ok(p):
            continue
        reach.add(p)
        stack.extend(step(p, d) for d in DIR_BITS)

    # ---- add vents / scrubbers --------------------------------------------
    def free_tile(p, near_door_ok=False):
        if p in RESERVED or p in chamber or p not in t:
            return False
        tile = t[p]
        if not (is_floor(tile) and not is_boundary(tile) and station(M.area(p))):
            return False
        for a in tile:
            if a.startswith(('/turf', '/area')) or OLD_PIPE.match(path(a)):
                continue
            if not a.startswith(FREE_OBJ):
                return False
        if not near_door_ok and any(is_door(t.get(step(p, d), ('/turf/space', '/area/space'))) for d in DIR_BITS):
            return False
        return any(step(p, d) in reach and attach_ok(step(p, d), p) for d in DIR_BITS)

    by_area = defaultdict(list)
    for p in t:
        tile = t[p]
        if is_floor(tile) and not is_boundary(tile) and p not in chamber and p not in RESERVED:
            by_area[M.area(p)].append(p)
    have = {k: defaultdict(list) for k in terminals}
    for k in terminals:
        for p in terminals[k]:
            have[k][M.area(p)].append(p)
    for p in fixed:
        k = 'supply' if M.has(p, VENT) else 'scrubbers'
        have[k][M.area(p)].append(p)

    added = {'supply': [], 'scrubbers': []}
    atom_new = {'supply': VENT + '/on', 'scrubbers': SCRUB + '/on'}
    for a, tiles in sorted(by_area.items()):
        if not station(a) or a.startswith(NO_NORM) or no_air(a):
            continue
        per = TILES_PER_PAIR
        need = target(a, len(tiles))  # Delta/Cyberiad norm, see thin_air.py
        cand = [p for p in tiles if free_tile(p, True)]
        by_door = {p for p in cand if not free_tile(p)}  # last resort in cramped rooms
        for k, other in (('supply', 'scrubbers'), ('scrubbers', 'supply')):
            while len(have[k][a]) < need and cand:
                mine = have[k][a]
                partner = [p for p in have[other][a] if p not in mine]

                def score(p):
                    dmin = min((math.dist(p, q) for q in mine), default=50.0)
                    near_partner = min((math.dist(p, q) for q in partner), default=9.0)
                    pair_bonus = 3.0 if near_partner == 1 and not any(math.dist(q, p) <= 1 for q in mine) else 0
                    return (dmin + (2.0 if p in old_ends else 0) + pair_bonus - 0.05 * near_partner
                            - (100 if p in by_door else 0))
                best = max(cand, key=score)
                cand.remove(best)
                t[best].insert(0, atom_new[k])
                have[k][a].append(best)
                added[k].append(best)
                terminals[k].append(best)

    # ---- air alarms ---------------------------------------------------------
    alarms = defaultdict(list)
    for p, tile in t.items():
        if any(path(a).startswith('/obj/machinery/alarm') for a in tile):
            alarms[M.area(p)].append(p)
    added_alarms = []
    for a in sorted(set(M.area(p) for k in have for ar in have[k] for p in have[k][ar])):
        if alarms[a] or not station(a) or no_air(a):
            continue
        tiles = by_area.get(a, [])
        if not tiles:
            report.append(f'no tile for an air alarm in {a}')
            continue
        cx = sum(p[0] for p in tiles) / len(tiles)
        cy = sum(p[1] for p in tiles) / len(tiles)
        best = None
        for p in tiles:
            if any(b.startswith(WALL_MOUNT) for b in t[p]) or is_door(t[p]):
                continue
            for d in DIR_BITS:
                w = step(p, d)
                wt = t.get(w)
                if not wt or not is_wall(wt) or any(b.startswith('/obj') for b in wt):
                    continue
                c = (math.dist(p, (cx, cy)) + (0 if d == 1 else 0.5), p, d)
                if best is None or c < best:
                    best = c
        if not best:
            report.append(f'no wall for an air alarm in {a}')
            continue
        _, p, d = best
        t[p].insert(0, '/obj/machinery/alarm{dir = %d;%s}' % (d, ALARM_PIX[d]))
        added_alarms.append(p)

    # ---- remove old distro / waste pipes ------------------------------------
    for p in old_pipe['supply'] | old_pipe['scrubbers']:
        t[p] = [a for a in t[p] if not OLD_PIPE.match(path(a))]

    # ---- routing -------------------------------------------------------------

    def cost_fn(k, tree_other):
        own = VENT if k == 'supply' else SCRUB
        foreign = SCRUB if k == 'supply' else VENT

        def c(p):
            if not base_ok(p) or M.has(p, own):
                return None
            tile = t[p]
            a = M.area(p)
            if is_wall(tile):
                # Utilities enter rooms through doors or windows, never through
                # solid walls (user, 2026-11-19); a wall only as a last resort.
                v = WALL_COST
            elif any(b.startswith(('/obj/effect/spawner/window', '/obj/structure/window', '/obj/structure/grille'))
                     for b in tile):
                v = 3.0
            elif is_door(tile):
                v = 1.5
            elif a.startswith('/area/station/maintenance'):
                v = 0.8
            elif a.startswith('/area/station/hallway'):
                v = 1.0
            else:
                v = 2.5
            if p in old_pipe[k]:
                v *= 0.5
            if p in tree_other:
                v *= 0.45
            if M.has(p, foreign):
                v += 2.0
            if shared(p):
                v += 3.0
            return v
        return c

    def grow(k, tree_other):
        root, forced = ROOTS[k]
        cost = cost_fn(k, tree_other)
        assert cost(root) is not None, (k, root, t[root])
        tree = {root}
        edges = set()
        attach = {}  # terminal -> pipe tile
        todo = set(terminals[k])
        while todo:
            heap = []
            best = {}
            prev = {}
            for s in tree:
                best[(s, None)] = 0.0
                heapq.heappush(heap, (0.0, s, None))
            found = None
            while heap:
                c, p, d = heapq.heappop(heap)
                if best.get((p, d), 1e18) < c:
                    continue
                hit = [step(p, e) for e in DIR_BITS if step(p, e) in todo and attach_ok(p, step(p, e))]
                if hit:
                    found = ((p, d), min(hit))
                    break
                for e in DIR_BITS:
                    n = step(p, e)
                    sc = cost(n)
                    if sc is None:
                        continue
                    nc = c + sc + (0.35 if d is not None and d != e else 0)
                    if nc < best.get((n, e), 1e18):
                        best[(n, e)] = nc
                        prev[(n, e)] = (p, d)
                        heapq.heappush(heap, (nc, n, e))
            if not found:
                for tm in sorted(todo):
                    report.append(f'{k}: terminal {tm} {M.area(tm)} unreachable')
                break
            key, tm = found
            chain = [key[0]]
            while key in prev:
                key = prev[key]
                chain.append(key[0])
            for a_, b_ in zip(chain, chain[1:]):
                edges.add(frozenset((a_, b_)))
            tree.update(chain)
            attach[tm] = chain[0]
            assigned[(tm, k)] = next(d for d in DIR_BITS if step(tm, d) == chain[0])
            todo.discard(tm)
        bits = defaultdict(int)
        for e in edges:
            a_, b_ = tuple(e)
            for d in DIR_BITS:
                if step(a_, d) == b_:
                    bits[a_] |= d
                    bits[b_] |= REV[d]
        for tm, p in attach.items():
            for d in DIR_BITS:
                if step(p, d) == tm:
                    bits[p] |= d
        bits[root] |= forced
        return bits, attach

    sup_bits, sup_attach = grow('supply', set())
    scr_bits, scr_attach = grow('scrubbers', set(sup_bits))

    def pipe_atom(k, b):
        n = bin(b).count('1')
        if n == 4:
            return f'{ATMOS}/pipe/manifold4w/hidden/{k}'
        if n == 3:
            missing = 15 & ~b
            return f'{ATMOS}/pipe/manifold/hidden/{k}' + ('' if missing == 2 else '{dir = %d}' % missing)
        if n == 2:
            if b == 3:
                return f'{ATMOS}/pipe/simple/hidden/{k}'
            if b == 12:
                return f'{ATMOS}/pipe/simple/hidden/{k}' + '{dir = 4}'
            return f'{ATMOS}/pipe/simple/hidden/{k}' + '{dir = %d}' % b
        return f'{ATMOS}/pipe/cap/hidden/{k}' + ('' if b == 2 else '{dir = %d}' % b)

    for k, bits in (('supply', sup_bits), ('scrubbers', scr_bits)):
        for p, b in bits.items():
            tile = t[p]
            i = next(i for i, a in enumerate(tile) if a.startswith('/turf'))
            tile.insert(i, pipe_atom(k, b))
    for k, att, prefix in (('supply', sup_attach, VENT), ('scrubbers', scr_attach, SCRUB)):
        for tm, p in att.items():
            d = next(d for d in DIR_BITS if step(tm, d) == p)
            t[tm] = [with_dir(a, d) if path(a).startswith(prefix) else a for a in t[tm]]

    # ---- write ---------------------------------------------------------------
    changed = 0
    for p, tile in t.items():
        if tuple(tile) != M.orig[p]:
            M.m.set_tile((p[0], p[1], 1), tuple(tile))
            changed += 1
    M.m.to_file(str(MAP))
    STAMP.parent.mkdir(exist_ok=True)
    STAMP.write_text(hashlib.sha256(MAP.read_bytes()).hexdigest() + '\n')
    print(f'tiles changed {changed}; supply pipes {len(old_pipe["supply"])} -> {len(sup_bits)}, '
          f'scrubber pipes {len(old_pipe["scrubbers"])} -> {len(scr_bits)}')
    print(f'vents attached {len(sup_attach)}, added {len(added["supply"])}; '
          f'scrubbers attached {len(scr_attach)}, added {len(added["scrubbers"])}; '
          f'air alarms added {len(added_alarms)}; fixed devices left alone {len(fixed)}; '
          f'removed from maintenance {stripped}')
    for r in report:
        print('FAIL', r)
    return 1 if report else 0


if __name__ == '__main__':
    sys.exit(main())
