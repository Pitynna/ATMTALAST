"""Normalise wall-mounted objects on Ulthor to the Delta conventions.

Usage: python tools/ulthor/wallmounts.py [--write]

Without --write only prints a report. Edits the current Ulthor.dmm in place
(incrementally, never regenerating from an old base).

Rules (taken from _maps/map_files/Delta/delta.dmm):
* types that have MAPPING_DIRECTIONAL_HELPERS and that Delta maps through
  them become `<type>/directional/<wall side>` with no dir/pixel vars;
* other wall-mounted types keep their lateral offset, while the offset
  towards the wall is set to the value Delta uses for that type and side;
* cameras pushed into a wall get pixel 0 and look away from that wall,
  as every Delta camera does.
The wall side is read from the existing pixel offset.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
SIDES = {'N': (0, 1), 'S': (0, -1), 'E': (1, 0), 'W': (-1, 0)}
NAME = {'N': 'north', 'S': 'south', 'E': 'east', 'W': 'west'}
DIRNUM = {'N': 1, 'S': 2, 'E': 4, 'W': 8}
OPPOSITE = {'N': 'S', 'S': 'N', 'E': 'W', 'W': 'E'}

# Exact types converted to their /directional/ subtypes (all exist in code).
HELPER = {
    '/obj/item/radio/intercom', '/obj/item/radio/intercom/custom',
    '/obj/item/radio/intercom/department/security', '/obj/item/radio/intercom/locked/confessional',
    '/obj/item/radio/intercom/locked/prison', '/obj/item/radio/intercom/private',
    '/obj/item/radio/intercom/specops',
    '/obj/machinery/alarm', '/obj/machinery/alarm/server',
    '/obj/machinery/firealarm', '/obj/machinery/light_switch',
    '/obj/machinery/newscaster', '/obj/machinery/newscaster/security_unit',
    '/obj/machinery/power/apc', '/obj/machinery/defibrillator_mount/loaded',
    '/obj/structure/closet/walllocker/emerglocker', '/obj/structure/extinguisher_cabinet',
    '/obj/structure/sink', '/obj/structure/sink/kitchen',
}

# type prefix -> (offset towards wall per side, accepted |offset| range)
# Values are the most common ones on Delta for that type and side.
FIXED = [
    ('/obj/machinery/status_display', dict(N=32, S=32, E=32, W=32), (24, 36)),
    ('/obj/machinery/ai_status_display', dict(N=32, S=32, E=32, W=32), (24, 36)),
    ('/obj/machinery/requests_console', dict(N=30, S=32, E=30, W=30), (24, 34)),
    ('/obj/machinery/door_control', dict(N=24, S=24, E=26, W=24), (20, 31)),
    ('/obj/machinery/button', dict(N=24, S=24, E=24, W=24), (20, 31)),
    ('/obj/machinery/keycard_auth', dict(N=24, S=24, E=24, W=24), (20, 31)),
    ('/obj/machinery/flasher_button', None, None),
    ('/obj/machinery/flasher', dict(N=28, S=24, E=24, W=24), (20, 31)),
    ('/obj/machinery/driver_button', dict(N=26, S=26, E=26, W=26), (20, 31)),
    ('/obj/machinery/crema_switch', dict(N=26, S=26, E=26, W=26), (20, 31)),
    ('/obj/machinery/ignition_switch', dict(N=24, S=24, E=24, W=24), (20, 31)),
    ('/obj/machinery/sparker', dict(N=24, S=24, E=25, W=25), (18, 31)),
    ('/obj/machinery/turretid', dict(N=28, S=24, E=32, W=32), (20, 34)),
    ('/obj/machinery/computer/security/wooden_tv', None, None),
    ('/obj/machinery/computer/security/telescreen', dict(N=32, S=32, E=32, W=32), (24, 36)),
    ('/obj/machinery/recharger/wallcharger', dict(N=28, S=28, E=24, W=24), (20, 34)),
    ('/obj/structure/mirror', dict(N=32, S=30, E=26, W=26), (22, 34)),
    ('/obj/structure/noticeboard', dict(N=30, S=30, E=32, W=32), (24, 34)),
    ('/obj/structure/closet/fireaxecabinet', dict(N=32, S=30, E=30, W=30), (24, 34)),
    ('/obj/machinery/computer/guestpass', dict(N=28, S=28, E=28, W=28), (24, 34)),
    ('/obj/machinery/computer/cryopod/robot', dict(N=28, S=28, E=28, W=28), (24, 34)),
    ('/obj/machinery/computer/cryopod', dict(N=32, S=32, E=32, W=32), (24, 34)),
    ('/obj/structure/reagent_dispensers/fueltank/chem', dict(N=30, S=32, E=32, W=32), (24, 34)),
    ('/obj/structure/reagent_dispensers/peppertank', dict(N=30, S=32, E=32, W=32), (24, 34)),
    ('/obj/structure/reagent_dispensers/spacecleanertank', dict(N=30, S=32, E=32, W=32), (24, 34)),
    ('/obj/structure/reagent_dispensers/virusfood', dict(N=30, S=32, E=32, W=32), (24, 34)),
    ('/obj/structure/sign', dict(N=32, S=32, E=32, W=32), (24, 34)),
    ('/obj/machinery/vending/wallmed', dict(N=30, S=30, E=26, W=26), (22, 34)),
    ('/obj/machinery/door_timer', dict(N=32, S=32, E=32, W=32), (24, 34)),
    ('/obj/machinery/atm', dict(N=32, S=32, E=32, W=32), (24, 34)),
    ('/obj/machinery/ticket_machine', dict(N=32, S=32, E=32, W=32), (24, 34)),
    ('/obj/machinery/mineral/labor_claim_console', dict(N=32, S=32, E=32, W=32), (24, 34)),
    ('/obj/structure/closet/secure_closet/medical_wall', dict(N=32, S=32, E=32, W=32), (24, 34)),
]

# Objects whose pixel offset points at no wall, resolved by looking at the map:
# (x, y, text in atom) -> (tile to hang from, wall side | 'desk' for pixel 0 on a table)
MANUAL = {
    (70, 91, 'extinguisher_cabinet'): ((71, 91), 'N'),     # specops shuttle, diagonal offset
    (69, 91, 'wallmed'): ((68, 91), 'N'),
    (114, 133, 'labor_claim_console'): ((114, 134), 'N'),  # labour shuttle, diagonal offset
    (180, 118, 'ai_status_display'): ((181, 118), 'N'),    # diagonal offset
    (91, 134, 'intercom'): ((92, 134), 'S'),               # barber: south wall, APC holds (91,134)
    (104, 165, 'keycard_auth'): ((104, 167), 'W'),         # blueshield: buttons and light already below
    (100, 166, 'EVA Storage CCTV'): ((100, 166), 'N'),     # EVA glass booth
    (101, 166, 'power/apc'): ((102, 166), 'E'),            # EVA booth: east r-wall, cable extended
    (101, 165, 'machinery/alarm'): ((102, 164), 'E'),
    (101, 164, 'firealarm'): ((101, 163), 'S'),
    (113, 174, 'Chemistry Privacy'): ((114, 173), 'E'),    # chemistry: north wall is taken
    (113, 117, 'keycard_auth'): ((113, 116), 'desk'),      # HoS desk
    (123, 164, 'keycard_auth'): ((122, 164), 'desk'),      # bridge desk
    (134, 189, 'viroshutters'): ((134, 189), 'E'),
    (96, 165, 'light_switch'): ((96, 166), 'W'),           # EVA: west wall, fire alarm holds (96,165)
    (186, 169, 'light_switch'): ((186, 168), 'W'),         # toxins launch: west is a door, north wall is full
    (113, 175, 'light_switch'): ((113, 175), 'E'),         # chemistry: the chem tank holds the north wall
    (135, 175, 'light_switch'): ((137, 175), 'E'),         # paramedic: the west wall holds APC and garage button
    (78, 180, 'machinery/alarm'): ((78, 181), 'N'),        # cabin 2: south wall is full
    # AI core: only the three intercoms stay on the AI tile, as on Delta
    (140, 151, 'light_switch'): ((139, 154), 'N'),
    (140, 151, 'requests_console'): ((141, 154), 'N'),
    (140, 151, 'newscaster/security_unit'): ((143, 155), 'E'),
    (76, 95, 'intercom'): ((77, 97), 'E'),                 # arrivals: APC holds the only wall pocket
}
EXTRA_CABLES = [(102, 166)]

# Two mounts on one wall spot: the first listed type that is present moves to the
# nearest free tile along the same wall, in the same area. APCs never move.
MOVABLE = ('/obj/machinery/light_switch', '/obj/item/radio/intercom', '/obj/machinery/newscaster',
           '/obj/structure/extinguisher_cabinet', '/obj/machinery/firealarm', '/obj/machinery/alarm',
           '/obj/machinery/requests_console', '/obj/machinery/keycard_auth')
DSIDE = {'north': 'N', 'south': 'S', 'east': 'E', 'west': 'W'}

WALLISH = ('/turf/simulated/wall', '/turf/unsimulated/wall', '/turf/simulated/mineral',
           '/obj/effect/spawner/window', '/obj/structure/window/full', '/obj/structure/window/reinforced/fulltile',
           '/obj/structure/window/plasmareinforced/fulltile', '/obj/structure/grille', '/obj/structure/falsewall')


def split_atom(atom):
    if '{' not in atom:
        return atom, []
    base, body = atom.split('{', 1)
    body = body[:-1]
    out, cur, quote = [], '', False
    for ch in body:
        if ch == '"':
            quote = not quote
        if ch == ';' and not quote:
            out.append(cur.strip())
            cur = ''
        else:
            cur += ch
    if cur.strip():
        out.append(cur.strip())
    return base, [tuple(p.split(' = ', 1)) for p in out]


def join_atom(base, pairs):
    return base + ('{' + ';'.join(f'{k} = {v}' for k, v in pairs) + '}' if pairs else '')


def getv(pairs, key, default=0):
    for k, v in pairs:
        if k == key:
            return int(v)
    return default


def setv(pairs, key, value):
    pairs = [(k, v) for k, v in pairs if k != key]
    if value:
        pairs.append((key, str(value)))
    return pairs


def side_of(px, py):
    if abs(px) >= abs(py) and px:
        return 'E' if px > 0 else 'W'
    if py:
        return 'N' if py > 0 else 'S'
    return None


def fixed_rule(base):
    for prefix, offs, rng in FIXED:
        if base == prefix or base.startswith(prefix + '/'):
            return offs, rng
    return False


class Fixer:
    def __init__(self, m):
        self.m = m
        self.X, self.Y, _ = m.size
        self.notes = []
        self.moves = []

    def tile(self, x, y):
        if not (1 <= x <= self.X and 1 <= y <= self.Y):
            return ('/turf/space', '/area/space')
        return self.m.get_tile((x, y, 1))

    def wall(self, x, y):
        return any(a.startswith(WALLISH) for a in self.tile(x, y))

    def mountable(self, x, y, s):
        """A wall, a full window or a thin window on that edge."""
        dx, dy = SIDES[s]
        if self.wall(x + dx, y + dy):
            return True
        for ax, ay, d in ((x, y, DIRNUM[s]), (x + dx, y + dy, DIRNUM[OPPOSITE[s]])):
            for a in self.tile(ax, ay):
                b, pairs = split_atom(a)
                if b == '/obj/structure/window/reinforced' and getv(pairs, 'dir', 2) == d:
                    return True
        # a desk window: table under a window door, as at brig desks
        return any(a.startswith('/obj/machinery/door/window') for a in self.tile(x + dx, y + dy))

    def area(self, x, y):
        return self.tile(x, y)[-1]

    def kind(self, base):
        if base in HELPER:
            return 'helper'
        if base == '/obj/machinery/camera':
            return 'camera'
        rule = fixed_rule(base)
        if rule and rule[0] is not None:
            return 'fixed'
        return None

    def side(self, base, pairs):
        px, py = getv(pairs, 'pixel_x'), getv(pairs, 'pixel_y')
        s = side_of(px, py)
        k = self.kind(base)
        if k == 'camera':
            d = getv(pairs, 'dir', 2)
            if s is None or max(abs(px), abs(py)) < 16:
                return None
            if s == 'S' and py == -22 and d in (4, 8):
                return None  # Delta style: looks along the south wall
        elif k == 'fixed':
            offs, (lo, hi) = fixed_rule(base)
            if s is None or not (lo <= (abs(px) if s in 'EW' else abs(py)) <= hi):
                return None
        elif k == 'helper':
            return s
        return s

    def mount(self, base, pairs, s):
        """Atom string for the object hanging on wall side s of its tile."""
        k = self.kind(base)
        px, py = getv(pairs, 'pixel_x'), getv(pairs, 'pixel_y')
        if k == 'helper':
            pairs = [(k2, v) for k2, v in pairs if k2 not in ('dir', 'pixel_x', 'pixel_y')]
            return join_atom(f'{base}/directional/{NAME[s]}', pairs)
        if k == 'camera':
            pairs = setv(setv(pairs, 'pixel_x', 0), 'pixel_y', 0)
            return join_atom(base, setv(pairs, 'dir', DIRNUM[OPPOSITE[s]] if OPPOSITE[s] != 'S' else 0))
        offs, _ = fixed_rule(base)
        lateral = py if s in 'EW' else px
        if abs(lateral) >= 16:
            lateral = 0
        target = offs[s] * (1 if s in 'NE' else -1)
        if s in 'EW':
            pairs = setv(setv(pairs, 'pixel_x', target), 'pixel_y', lateral)
        else:
            pairs = setv(setv(pairs, 'pixel_y', target), 'pixel_x', lateral)
        return join_atom(base, pairs)

    def plan(self):
        """Yield (x, y, index, new_atom, (nx, ny) or None)."""
        out = []
        for (x, y, z), key in sorted(self.m.grid.items()):
            for i, a in enumerate(self.m.dictionary[key]):
                base, pairs = split_atom(a)
                if '/directional/' in base and base.rsplit('/directional/', 1)[0] in HELPER:
                    base = base.rsplit('/directional/', 1)[0]
                if not base.startswith('/obj') or self.kind(base) is None:
                    continue
                manual = next((v for (mx, my, sub), v in MANUAL.items() if (mx, my) == (x, y) and sub in a), None)
                s = self.side(base, pairs)
                if s is None and not manual:
                    continue
                manual = next((v for (mx, my, sub), v in MANUAL.items() if (mx, my) == (x, y) and sub in a), None)
                if manual:
                    dest, ms = manual
                    if ms == 'desk':
                        new = join_atom(base, setv(setv(pairs, 'pixel_x', 0), 'pixel_y', 0))
                    else:
                        new = self.mount(base, pairs, ms)
                    out.append((x, y, i, new, None if dest == (x, y) else dest))
                    self.notes.append((x, y, f'manual: to {dest} {ms}', a))
                    continue
                if self.wall(x, y) and not base.startswith('/obj/structure/sign'):
                    # mounted from inside the wall: hang it from the floor tile of the same room
                    order = [s] + [k for k in 'NSEW' if k != s]
                    cands = [k for k in order if not self.wall(x + SIDES[k][0], y + SIDES[k][1])
                             and not any(t.startswith('/turf/space') for t in self.tile(x + SIDES[k][0], y + SIDES[k][1]))]
                    same = [k for k in cands if self.area(x + SIDES[k][0], y + SIDES[k][1]) == self.area(x, y)]
                    if same or cands:
                        k = (same or cands)[0]
                        nx, ny = x + SIDES[k][0], y + SIDES[k][1]
                        ns = OPPOSITE[k]
                        out.append((x, y, i, self.mount(base, pairs, ns), (nx, ny)))
                        self.notes.append((x, y, f'moved to ({nx},{ny}) wall {ns}', a))
                        continue
                    self.notes.append((x, y, 'on a wall tile', a))
                elif not self.mountable(x, y, s):
                    walls = ''.join(k for k in 'NSEW' if self.mountable(x, y, k))
                    self.notes.append((x, y, f'no wall {s} (walls: {walls or "-"})', a))
                out.append((x, y, i, self.mount(base, pairs, s), None))
        return out

    def run(self, overrides=None):
        changed = 0
        removals, additions, replacements = {}, {}, {}
        for x, y, i, new, dest in self.plan():
            if overrides and (x, y, i) in overrides:
                new, dest = overrides[(x, y, i)]
            old = self.m.get_tile((x, y, 1))[i]
            if dest is None:
                if new != old:
                    replacements[(x, y, i)] = new
                    changed += 1
            else:
                removals.setdefault((x, y), set()).add(i)
                additions.setdefault(dest, []).append(new)
                changed += 1
        tiles = {}
        for (x, y, i), new in replacements.items():
            t = list(tiles.get((x, y), self.m.get_tile((x, y, 1))))
            t[i] = new
            tiles[(x, y)] = t
        for (x, y), idx in removals.items():
            t = list(tiles.get((x, y), self.m.get_tile((x, y, 1))))
            tiles[(x, y)] = [a for j, a in enumerate(t) if j not in idx]
        for (x, y), atoms in additions.items():
            t = list(tiles.get((x, y), self.m.get_tile((x, y, 1))))
            pos = next(j for j, a in enumerate(t) if a.startswith('/turf'))
            tiles[(x, y)] = t[:pos] + atoms + t[pos:]
        for (x, y) in EXTRA_CABLES:
            t = list(tiles.get((x, y), self.m.get_tile((x, y, 1))))
            if '/obj/structure/cable' not in t:
                t.insert(0, '/obj/structure/cable')
                tiles[(x, y)] = t
        for (x, y), t in tiles.items():
            self.m.set_tile((x, y, 1), tuple(t))
        return changed


def mount_spot(fixer, atom):
    """(side, lateral) of a wall-mounted atom, or None."""
    base, pairs = split_atom(atom)
    if not base.startswith('/obj') or base == '/obj/machinery/light' or base.startswith(('/obj/machinery/light/', '/obj/structure/sign', '/obj/machinery/camera', '/obj/structure/sink', '/obj/structure/mirror')):
        return None
    if '/directional/' in base:
        b, d = base.rsplit('/directional/', 1)
        if d in DSIDE and b in HELPER:
            return DSIDE[d], 0, 26
        return None
    if fixer.kind(base) == 'fixed':
        px, py = getv(pairs, 'pixel_x'), getv(pairs, 'pixel_y')
        s = side_of(px, py)
        if s and max(abs(px), abs(py)) >= 20:
            return s, (py if s in 'EW' else px), max(abs(px), abs(py))
    return None


def conflicts(fixer, x, y):
    spots = []
    for a in fixer.tile(x, y):
        sp = mount_spot(fixer, a)
        if sp:
            spots.append((sp, a))
    out = []
    for i in range(len(spots)):
        for j in range(i + 1, len(spots)):
            (s1, l1, p1), a1 = spots[i]
            (s2, l2, p2), a2 = spots[j]
            if s1 == s2 and abs(l1 - l2) < 8 and abs(p1 - p2) < 8:
                out.append((s1, a1, a2))
    return out


def resolve_overlaps(fixer):
    m = fixer.m
    for (x, y, z) in sorted(list(m.grid)):
        for s, a1, a2 in conflicts(fixer, x, y):
            pick = None
            for prefix in MOVABLE:
                pick = next((a for a in (a1, a2) if a.split('{')[0].startswith(prefix)), None)
                if pick:
                    break
            if pick and pick not in fixer.tile(x, y):
                continue  # already moved for another pair
            if not pick:
                fixer.notes.append((x, y, f'overlap {s} unresolved', a1 + ' / ' + a2))
                continue
            dx, dy = SIDES[s]
            along = [(dy, dx), (-dy, -dx)] if s in 'NS' else [(dy, dx), (-dy, -dx)]
            along = [(1, 0), (-1, 0)] if s in 'NS' else [(0, 1), (0, -1)]
            done = False
            for dist in (1, 2):
                for ax, ay in along:
                    nx, ny = x + ax * dist, y + ay * dist
                    if fixer.wall(nx, ny) or fixer.area(nx, ny) != fixer.area(x, y) or not fixer.mountable(nx, ny, s):
                        continue
                    if any(mount_spot(fixer, b) and mount_spot(fixer, b)[0] == s for b in fixer.tile(nx, ny)):
                        continue
                    if any(t.startswith('/obj/machinery/door') for t in fixer.tile(nx, ny)):
                        continue
                    src = list(fixer.tile(x, y))
                    src.remove(pick)
                    m.set_tile((x, y, 1), tuple(src))
                    base, pairs = split_atom(pick)
                    moved = pick
                    if fixer.kind(base) == 'fixed':
                        lat = 'pixel_x' if s in 'NS' else 'pixel_y'
                        moved = join_atom(base, setv(pairs, lat, 0))
                    dst = list(fixer.tile(nx, ny))
                    pos = next(j for j, t in enumerate(dst) if t.startswith('/turf'))
                    m.set_tile((nx, ny, 1), tuple(dst[:pos] + [moved] + dst[pos:]))
                    fixer.notes.append((x, y, f'overlap {s}: moved to ({nx},{ny})', pick))
                    done = True
                    break
                if done:
                    break
            if not done:
                fixer.notes.append((x, y, f'overlap {s} unresolved', a1 + ' / ' + a2))


def main():
    m = DMM.from_file(MAP)
    f = Fixer(m)
    n = f.run()
    resolve_overlaps(f)
    for x, y, why, atom in sorted(f.notes, key=lambda r: (r[2], r[0], r[1])):
        print(f'({x},{y}) {why}: {atom}')
    print(f'changed atoms: {n}')
    if '--write' in sys.argv:
        m.to_file(MAP)
        print('written', MAP)


if __name__ == '__main__':
    main()
