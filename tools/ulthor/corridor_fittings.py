"""Wall fittings after the four-corridor rezone (2026-11-19).

One area takes one APC (test ulthor_power). Merging three west hallway zones
left the west corridor with three APCs and four air alarms; the south
corridor, the security strip and what is left of engineering maintenance
lost theirs; the east corridor was maintenance and has no lamps or alarms.

* extra APCs / air alarms in the west corridor are removed;
* areas without an APC get one on a floor tile that already carries a cable
  (cables auto-connect), against a solid wall, near the middle of the area;
* hallway areas with vents but no air alarm get one; hallways without a fire
  alarm get one per ~25 tiles of length (at least one);
* the east corridor gets tube lights on alternate walls every ~7 tiles
  (maintenance stays dark: user rule 2026-11-16).
Incremental: only the tiles listed in the report change.
"""
import math
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
H = '/area/station/hallway/'
PORT, AFT, STARBOARD = H + 'primary/port', H + 'primary/aft', H + 'primary/starboard'
SIDE = {1: ('north', (0, 1)), 2: ('south', (0, -1)), 4: ('east', (1, 0)), 8: ('west', (-1, 0))}
MOUNTS = ('/obj/machinery/light', '/obj/machinery/alarm', '/obj/machinery/firealarm', '/obj/machinery/power/apc',
          '/obj/machinery/camera', '/obj/machinery/light_switch', '/obj/machinery/status_display',
          '/obj/machinery/newscaster', '/obj/machinery/requests_console', '/obj/machinery/door_control',
          '/obj/item/radio/intercom', '/obj/structure/sign', '/obj/structure/extinguisher_cabinet',
          '/obj/machinery/ai_status_display', '/obj/machinery/keycard_auth', '/obj/machinery/economy/atm',
          '/obj/structure/noticeboard', '/obj/machinery/button', '/obj/machinery/vending/wallmed',
          '/obj/machinery/defibrillator_mount', '/obj/structure/closet/fireaxecabinet', '/obj/machinery/flasher')
DROP = {(83, 161): '/obj/machinery/power/apc', (84, 157): '/obj/machinery/power/apc',
        (85, 153): '/obj/machinery/alarm', (87, 131): '/obj/machinery/alarm'}


def has(tile, *pre):
    return any(a.startswith(pre) for a in tile)


class Fit:
    def __init__(self):
        self.m = DMM.from_file(str(MAP))
        self.t = {(x, y): list(self.m.get_tile((x, y, 1))) for (x, y, z) in self.m.grid}
        self.orig = {p: tuple(v) for p, v in self.t.items()}
        self.log = []

    def area(self, p):
        return self.t[p][-1] if p in self.t else '/area/space'

    def tiles(self, a):
        return [p for p in self.t if self.area(p) == a]

    def floor(self, p):
        tile = self.t[p]
        return has(tile, '/turf/simulated/floor') and not has(
            tile, '/turf/simulated/wall', '/obj/effect/spawner/window', '/obj/structure/grille', '/obj/machinery/door',
            '/obj/structure/window')

    def wall(self, p):
        tile = self.t.get(p, ())
        return has(tile, '/turf/simulated/wall') and not has(tile, '/obj')

    def spots(self, a, need_cable=False):
        """(floor tile, wall dir) where a fitting can hang."""
        out = []
        for p in self.tiles(a):
            if not self.floor(p) or has(self.t[p], *MOUNTS):
                continue
            if need_cable and not has(self.t[p], '/obj/structure/cable'):
                continue
            for d, (_, (dx, dy)) in SIDE.items():
                if self.wall((p[0] + dx, p[1] + dy)):
                    out.append((p, d))
        return out

    def count(self, a, pre):
        return [p for p in self.tiles(a) if has(self.t[p], pre)]

    def put(self, p, atom, why):
        self.t[p].insert(0, atom)
        self.log.append(f'{p} + {atom}  ({why})')


def centre(ps):
    return (sum(p[0] for p in ps) / len(ps), sum(p[1] for p in ps) / len(ps))


def main():
    F = Fit()
    t = F.t
    for p, pre in DROP.items():
        if F.area(p) == PORT:
            for a in [a for a in t[p] if a.startswith(pre)]:
                t[p].remove(a)
                F.log.append(f'{p} - {a}  (west corridor keeps one)')

    # The engineering maintenance left east of the corridor lost its APC to
    # the corridor; it gets one on the west wall inside its door, fed through
    # that door from the corridor cable at x163.
    eng = '/area/station/maintenance/ulthor_engineering_passage'
    if not F.count(eng, '/obj/machinery/power/apc') and F.area((167, 122)) == eng:
        F.put((167, 122), '/obj/machinery/power/apc/directional/west', f'APC for {eng}')
        for p in ((164, 121), (165, 121), (166, 121), (167, 121), (167, 122)):
            if not has(t[p], '/obj/structure/cable'):
                F.put(p, '/obj/structure/cable', 'feed for the maintenance APC')

    areas = sorted({F.area(p) for p in t if F.area(p).startswith('/area/station') or
                    F.area(p).startswith(('/area/hydroponics', '/area/janitor'))})
    # APCs for areas that have none
    for a in (AFT, H + 'ulthor_security', '/area/station/maintenance/ulthor_engineering_passage'):
        if F.count(a, '/obj/machinery/power/apc'):
            continue
        floor = [p for p in F.tiles(a) if F.floor(p)]
        c = centre(floor)
        cand = F.spots(a, need_cable=True)
        if not cand:
            F.log.append(f'NO APC SPOT in {a}')
            continue
        p, d = min(cand, key=lambda s: (math.dist(s[0], c), s[1]))
        F.put(p, f'/obj/machinery/power/apc/directional/{SIDE[d][0]}', f'APC for {a}')

    for a in areas:
        if not a.startswith(H):
            continue
        floor = [p for p in F.tiles(a) if F.floor(p)]
        if not floor:
            continue
        vents = F.count(a, '/obj/machinery/atmospherics/unary/vent')
        if vents and not F.count(a, '/obj/machinery/alarm'):
            c = centre(vents)
            p, d = min(F.spots(a), key=lambda s: (math.dist(s[0], c), s[1]))
            F.put(p, f'/obj/machinery/alarm/directional/{SIDE[d][0]}', f'air alarm for {a}')
        length = max(max(p[0] for p in floor) - min(p[0] for p in floor),
                     max(p[1] for p in floor) - min(p[1] for p in floor)) + 1
        want = max(1, round(length / 25))
        have = F.count(a, '/obj/machinery/firealarm')
        for _ in range(want - len(have)):
            ref = have or [centre(floor)]
            spots = F.spots(a)
            if not spots:
                break
            if have:
                p, d = max(spots, key=lambda s: (min(math.dist(s[0], q) for q in ref), -s[1]))
            else:
                p, d = min(spots, key=lambda s: (math.dist(s[0], ref[0]), s[1]))
            F.put(p, f'/obj/machinery/firealarm/directional/{SIDE[d][0]}', f'fire alarm for {a}')
            have.append(p)

    # East corridor lamps: walk it from south to north, a tube every ~7 tiles,
    # alternating walls.
    lamps = F.count(STARBOARD, '/obj/machinery/light')
    if len(lamps) < 3:
        spots = F.spots(STARBOARD)
        placed = list(lamps)
        last_side = None
        for y in range(min(p[1] for p, _ in spots), max(p[1] for p, _ in spots) + 1):
            if placed and min(abs(y - q[1]) for q in placed) < 7:
                continue
            row = [s for s in spots if s[0][1] == y and s[1] in (4, 8)]
            if not row:
                continue
            row.sort(key=lambda s: (s[1] == last_side, s[1]))
            p, d = row[0]
            F.put(p, '/obj/machinery/light' + ('' if d == 2 else '{dir = %d}' % d), 'east corridor lamp')
            placed.append(p)
            last_side = d
            spots = [s for s in spots if s[0] != p]

    changed = 0
    for p, tile in t.items():
        if tuple(tile) != F.orig[p]:
            F.m.set_tile((p[0], p[1], 1), tuple(tile))
            changed += 1
    if '--dry' not in sys.argv:
        F.m.to_file(str(MAP))
    print('\n'.join(F.log))
    print('tiles changed', changed)


if __name__ == '__main__':
    main()
