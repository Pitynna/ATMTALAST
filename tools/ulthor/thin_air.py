"""Bring Ulthor's vent/scrubber counts to Delta/Cyberiad levels (user, 2026-11-19).

Measured on delta.dmm and cyberiad.dmm (z1, station areas):
* hallways: one vent + one scrubber per ~50-70 floor tiles, pairs 13-18 tiles
  apart along the corridor, vent and scrubber of a pair 1-2 tiles apart;
* rooms: 20-40 tiles -> 1 pair, 40-70 -> 1-2, 70-120 -> 2, 120-200 -> 3.
Ulthor had one pair per 30 tiles everywhere and clusters where two corridor
zones met.

The script edits the current map in place (never regenerates):
* in each area it keeps the target number of vent+scrubber pairs, chosen to
  be spread as far apart as possible, and removes the rest together with the
  pipe branch that only fed them (the branch is cut back to the junction;
  a manifold there becomes a straight pipe);
* areas that have fewer pairs than needed get new ones on free floor next to
  a passing distro / waste pipe (the pipe becomes a manifold).
Fixed devices (id_tag / frequency, chamber vents) and special rooms are left
alone.

    python tools/ulthor/thin_air.py --dry
    python tools/ulthor/thin_air.py
"""
import math
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
sys.path.insert(0, str(Path(__file__).resolve().parent))
from dmm import DMM  # noqa: E402
from check_pipes import parse, DELTA, REV  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
ATMOS = '/obj/machinery/atmospherics'
VENT = ATMOS + '/unary/vent_pump'
SCRUB = ATMOS + '/unary/vent_scrubber'
HIDDEN = re.compile(r'^/obj/machinery/atmospherics/pipe/(simple|manifold|manifold4w|cap)/hidden/(supply|scrubbers)$')
LAYER = {'supply': 2, 'scrubbers': 3}
HALL_TILES = 55
ROOM_TILES = 45
# Rooms whose vents serve a purpose of their own (chambers, pens, cells,
# machine rooms) keep everything.
SKIP = ('/area/station/engineering/atmos', '/area/station/engineering/engine', '/area/station/science/xenobiology',
        '/area/station/science/toxins', '/area/station/security/prison', '/area/station/medical/virology',
        '/area/station/science/server', '/area/station/command/server', '/area/station/telecomms',
        '/area/station/ai', '/area/station/maintenance', '/area/station/solars', '/area/station/engineering/ulthor_engine_room',
        '/area/station/science/explab/chamber', '/area/station/science/ulthor_coldroom',
        '/area/station/service/ulthor_kitchen_coldroom', '/area/station/engineering/ulthor_burn_room')
WALL_MOUNT_OK = ('/obj/effect', '/obj/structure/cable', '/obj/structure/disposalpipe', '/obj/machinery/navbeacon',
                 '/obj/machinery/light', '/obj/machinery/alarm', '/obj/machinery/firealarm', '/obj/machinery/power/apc',
                 '/obj/machinery/camera', '/obj/machinery/light_switch', '/obj/machinery/status_display',
                 '/obj/machinery/newscaster', '/obj/item/radio/intercom', '/obj/structure/sign',
                 '/obj/structure/extinguisher_cabinet', '/obj/machinery/ai_status_display',
                 '/obj/machinery/door_control', '/obj/machinery/requests_console', '/obj/machinery/economy/atm',
                 '/obj/structure/noticeboard', '/obj/machinery/button')


def path(a):
    return a.split('{')[0]


def adir(a):
    m = re.search(r'\bdir = (\d+)', a)
    return int(m[1]) if m else 2


def step(p, d):
    return (p[0] + DELTA[d][0], p[1] + DELTA[d][1])


def bits_of(a):
    q = parse(a)
    return q[1] if q else 0


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


class Air:
    def __init__(self):
        self.m = DMM.from_file(str(MAP))
        self.t = {(x, y): list(self.m.get_tile((x, y, 1))) for (x, y, z) in self.m.grid}
        self.orig = {p: tuple(v) for p, v in self.t.items()}
        self.log = []

    def area(self, p):
        return self.t[p][-1] if p in self.t else '/area/space'

    def hidden(self, p, k):
        for i, a in enumerate(self.t.get(p, ())):
            mm = HIDDEN.match(path(a))
            if mm and mm[2] == k:
                return i, a
        return None, None

    def floor(self, p):
        tile = self.t.get(p, ())
        return any(a.startswith('/turf/simulated/floor') for a in tile) and not any(
            a.startswith(('/turf/simulated/wall', '/obj/effect/spawner/window', '/obj/structure/grille',
                          '/obj/machinery/door', '/obj/structure/window')) for a in tile)

    # -- removal -------------------------------------------------------------
    def feed(self, p, a):
        """(kind, pipe tile) the device at p is attached to, or None."""
        k = 'supply' if path(a).startswith(VENT) else 'scrubbers'
        if 'id_tag' in a or 'frequency' in a:
            return None
        q = step(p, adir(a))
        i, pa = self.hidden(q, k)
        if pa is None or not bits_of(pa) & REV[adir(a)]:
            return None
        return k, q

    def cut(self, k, q, d):
        """Drop the link of the hidden k pipe on q in direction d; prune dead ends."""
        while True:
            i, pa = self.hidden(q, k)
            if pa is None:
                return
            b = bits_of(pa) & ~d
            n = bin(b).count('1')
            if n >= 2:
                self.t[q][i] = pipe_atom(k, b)
                return
            del self.t[q][i]
            if n == 0:
                return
            nd = b
            nxt = step(q, nd)
            # The remaining neighbour must be a hidden pipe of the same kind
            # pointing back; anything else (a device, a valve) keeps a cap.
            j, na = self.hidden(nxt, k)
            if na is None or not bits_of(na) & REV[nd]:
                self.t[q].insert(i, pipe_atom(k, nd))
                return
            q, d = nxt, REV[nd]

    def remove(self, p, a):
        k, q = self.feed(p, a)
        self.t[p].remove(a)
        self.cut(k, q, REV[adir(a)])

    # -- adding --------------------------------------------------------------
    def free(self, p):
        if not self.floor(p):
            return False
        for a in self.t[p]:
            if a.startswith(('/turf', '/area')):
                continue
            if not a.startswith(WALL_MOUNT_OK):
                return False
        return True

    def add(self, p, k):
        for d in (1, 2, 4, 8):
            q = step(p, d)
            i, pa = self.hidden(q, k)
            if pa is None or bits_of(pa) & REV[d] or bin(bits_of(pa)).count('1') != 2:
                continue
            # the other layer's device must not also face that pipe tile
            self.t[q][i] = pipe_atom(k, bits_of(pa) | REV[d])
            atom = (VENT if k == 'supply' else SCRUB) + '/on' + ('' if d == 2 else '{dir = %d}' % d)
            self.t[p].insert(0, atom)
            return True
        return False

    def can_add(self, p, k):
        if not self.free(p):
            return False
        for d in (1, 2, 4, 8):
            q = step(p, d)
            i, pa = self.hidden(q, k)
            if pa is not None and not bits_of(pa) & REV[d] and bin(bits_of(pa)).count('1') == 2:
                return True
        return False


def target(a, tiles):
    per = HALL_TILES if '/hallway' in a else ROOM_TILES
    return max(1, round(tiles / per))


NEAR = 6  # a pair this close to one already kept (any hallway) is a cluster


def spread(items, n, anchors=()):
    """Pick up to n points spread as far apart as possible (farthest-point
    order), never closer than NEAR to the anchors or to each other unless
    nothing else is left for the first one."""
    items = list(items)
    if not items or n <= 0:
        return []
    keep = []
    while len(keep) < n:
        rest = [p for p in items if p not in keep]
        if not rest:
            break
        ref = list(anchors) + keep
        if not ref:
            cx = sum(p[0] for p in items) / len(items)
            cy = sum(p[1] for p in items) / len(items)
            keep.append(max(rest, key=lambda p: math.dist(p, (cx, cy))))
            continue
        best = max(rest, key=lambda p: min(math.dist(p, k) for k in ref))
        if min(math.dist(best, k) for k in ref) < NEAR and keep:
            break
        keep.append(best)
    return keep


def main():
    dry = '--dry' in sys.argv
    A = Air()
    t = A.t
    floor_n = defaultdict(int)
    dev = defaultdict(lambda: {'supply': [], 'scrubbers': []})
    for p, tile in t.items():
        a = A.area(p)
        if not a.startswith('/area/station') and not a.startswith(('/area/hydroponics', '/area/janitor')):
            continue
        if any(x.startswith('/turf/simulated/floor') for x in tile):
            floor_n[a] += 1
        for x in tile:
            if path(x).startswith((VENT, SCRUB)) and A.feed(p, x):
                dev[a]['supply' if path(x).startswith(VENT) else 'scrubbers'].append(p)
    removed, added = defaultdict(int), defaultdict(int)
    hall_anchor = []  # devices kept in hallways processed so far
    order = sorted(floor_n, key=lambda a: ('/hallway' not in a, -floor_n[a], a))
    for a in order:
        if a.startswith(SKIP):
            continue
        hall = '/hallway' in a
        need = target(a, floor_n[a])
        vs, ss = dev[a]['supply'], dev[a]['scrubbers']
        # pair each vent with the nearest free scrubber (pairs sit 1-2 apart)
        pairs, used = [], set()
        for v in sorted(vs, key=lambda v: min((math.dist(v, s) for s in ss), default=99)):
            cand = [s for s in ss if s not in used and math.dist(v, s) <= 2.9]
            if cand:
                s = min(cand, key=lambda s: math.dist(v, s))
                used.add(s)
                pairs.append((v, s))
        mid = {((v[0] + s[0]) / 2, (v[1] + s[1]) / 2): (v, s) for v, s in pairs}
        keep_pairs = [mid[c] for c in spread(list(mid), need, hall_anchor if hall else ())]
        keep = {p for pr in keep_pairs for p in pr}
        # A lone device stays only when its kind is short and it stands well
        # away from every kept pair (no vent-next-to-vent clusters).
        lone_v = [v for v in vs if v not in keep and not any(v == pr[0] for pr in pairs)]
        lone_s = [s for s in ss if s not in keep and s not in used]
        for lst, kind in ((lone_v, vs), (lone_s, ss)):
            have = sum(1 for p in keep if p in kind)
            for p in spread(lst, max(0, need - have), list(keep) + (hall_anchor if hall else [])):
                keep.add(p)
        if hall:
            hall_anchor += list(keep)
        for k, lst in (('supply', vs), ('scrubbers', ss)):
            for p in lst:
                if p in keep:
                    continue
                atom = next(x for x in t[p] if path(x).startswith(VENT if k == 'supply' else SCRUB))
                if not dry:
                    A.remove(p, atom)
                removed[a] += 1
        # add pairs where the area has fewer than needed (only hallways: rooms
        # without air are left to be laid by hand)
        if '/hallway' in a:
            nv = sum(1 for p in vs if p in keep)
            ns = sum(1 for p in ss if p in keep)
            missing = need - min(nv, ns)
            if missing > 0:
                tiles = [p for p in t if A.area(p) == a and A.free(p)]
                anchors = list(keep) + hall_anchor
                for _ in range(missing):
                    best = None
                    for p in tiles:
                        if not A.can_add(p, 'supply'):
                            continue
                        for d in (1, 2, 4, 8):
                            for d2 in (d,):
                                s = step(step(p, d2), d2)  # scrubber two tiles away
                                if s in t and A.area(s) == a and A.can_add(s, 'scrubbers'):
                                    sc = min((math.dist(p, q) for q in anchors), default=50)
                                    if best is None or sc > best[0]:
                                        best = (sc, p, s)
                    if not best:
                        A.log.append(f'no room for a new pair in {a}')
                        break
                    _, p, s = best
                    if not dry:
                        A.add(p, 'supply')
                        A.add(s, 'scrubbers')
                    anchors += [p, s]
                    hall_anchor += [p, s]
                    tiles = [q for q in tiles if q not in (p, s)]
                    added[a] += 2
        if removed[a] or added[a]:
            print(f'{floor_n[a]:4d} tiles  need {need}  had v{len(vs)} s{len(ss)}  -{removed[a]} +{added[a]}  {a}')
    print('removed', sum(removed.values()), 'added', sum(added.values()))
    for line in A.log:
        print('NOTE', line)
    if dry:
        return
    changed = 0
    for p, tile in t.items():
        if tuple(tile) != A.orig[p]:
            A.m.set_tile((p[0], p[1], 1), tuple(tile))
            changed += 1
    A.m.to_file(str(MAP))
    print('tiles changed', changed)


if __name__ == '__main__':
    main()
