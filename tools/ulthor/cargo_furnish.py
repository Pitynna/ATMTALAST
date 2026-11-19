"""Furnish Ulthor's cargo office and bay (2026-11-19) as an incremental edit.

* Floors: plasteel tiles of the office and the bay get the brown cargo trim
  along walls and windows (corners and inner corners included), as on Delta.
  Plating, conveyor tiles and tiles with floor decals are left alone.
* Equipment the reference maps have and Ulthor lacked: requests console,
  supply display, tagger / wrap / labeler, autolathe, photocopier, water
  cooler, cargo shelves, an internals crate, the cargo clothesmate and
  mulebots parked on the QM delivery beacons.
* Every dense object placed must keep a free walkable neighbour reachable
  from the office door, and the room floor must stay connected; otherwise
  the script refuses to write.

Refuses to run over uncommitted map edits (the user may be in StrongDMM).
Usage: python tools/ulthor/cargo_furnish.py [--write]
"""
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
AREA = '/area/station/cargo/storage'
PLASTEEL = '/turf/simulated/floor/plasteel'
DELTA = {1: (0, 1), 2: (0, -1), 4: (1, 0), 8: (-1, 0)}
DIAG = {5: (1, 1), 6: (1, -1), 9: (-1, 1), 10: (-1, -1)}
# browncorner dir -> diagonal it trims (Ulthor lobby: dir 4 = NE, dir 2 = SE)
CORNER = {4: 5, 2: 6, 8: 10, 1: 9}

# tile -> atoms to add (inserted above the turf, in order)
PLACE = {
    # office
    (83, 132): ['/obj/item/destTagger{pixel_x = -4;pixel_y = 6}',
                '/obj/item/stack/packageWrap{pixel_x = 4;pixel_y = 2}',
                '/obj/item/hand_labeler{pixel_x = -2;pixel_y = -4}'],
    (78, 133): ['/obj/machinery/requests_console{department = "Cargo Bay";departmentType = 2;'
                'name = "Cargo Requests Console";pixel_y = 30}'],
    (76, 134): ['/obj/machinery/status_display/supply_display'],
    (81, 134): ['/obj/machinery/photocopier'],
    (82, 134): ['/obj/structure/reagent_dispensers/water_cooler'],
    (83, 134): ['/obj/item/twohanded/required/kirbyplants'],
    (74, 131): ['/obj/machinery/autolathe'],
    (73, 129): ['/obj/machinery/vending/department_clothesmate/cargo'],
    # bay
    (78, 126): ['/obj/structure/cargo_shelf'],
    (78, 125): ['/obj/structure/cargo_shelf'],
    (73, 123): ['/obj/structure/closet/crate/internals'],
    # warehouse: mulebots wait on their home beacons
    (76, 117): ['/mob/living/simple_animal/bot/mulebot{home_destination = "QM #1";suffix = "#1"}'],
    (77, 117): ['/mob/living/simple_animal/bot/mulebot{home_destination = "QM #2";suffix = "#2"}'],
    (74, 116): ['/mob/living/simple_animal/bot/mulebot{home_destination = "QM #3";suffix = "#3"}'],
}
WALL_TILE = {(76, 134)}  # supply display sits in the wall, as on Delta
DENSE = ('/obj/machinery/autolathe', '/obj/machinery/photocopier', '/obj/structure/reagent_dispensers',
         '/obj/machinery/vending', '/obj/structure/cargo_shelf', '/obj/structure/closet',
         '/obj/item/twohanded/required/kirbyplants', '/obj/machinery/computer', '/obj/structure/table',
         '/obj/machinery/mineral', '/obj/structure/rack', '/obj/machinery/disposal',
         '/obj/machinery/portable_atmospherics', '/obj/structure/plasticflaps', '/obj/structure/window',
         '/obj/effect/spawner/window', '/obj/machinery/door/window')
OFFICE_DOOR = (79, 127)


def path(a):
    return a.split('{')[0]


def step(p, d):
    return p[0] + DELTA[d][0], p[1] + DELTA[d][1]


def main():
    write = '--write' in sys.argv
    if subprocess.run(['git', 'diff', '--quiet', '--', str(MAP)], cwd=ROOT).returncode:
        sys.exit('Ulthor.dmm has uncommitted edits (StrongDMM?) - commit them first.')
    m = DMM.from_file(str(MAP))
    t = {(x, y): list(m.get_tile((x, y, 1))) for (x, y, z) in m.grid}
    orig = {p: tuple(v) for p, v in t.items()}

    def turf(p):
        return next(a for a in t[p] if a.startswith('/turf'))

    def is_wallish(p):
        if p not in t:
            return True
        tile = t[p]
        return turf(p).startswith(('/turf/simulated/wall', '/turf/space')) or any(
            path(a).startswith(('/obj/effect/spawner/window', '/obj/structure/grille')) for a in tile)

    def floor(p):
        return p in t and turf(p).startswith('/turf/simulated/floor') and not is_wallish(p)

    def dense(p):
        return any(path(a).startswith(DENSE) for a in t[p])  # airlocks open, so they count as walkable

    # ---- place objects ----------------------------------------------------
    for p, atoms in PLACE.items():
        if p in WALL_TILE:
            assert turf(p).startswith('/turf/simulated/wall') and not any(a.startswith('/obj') for a in t[p]), p
        else:
            assert floor(p), (p, t[p])
            body = [a for a in atoms if path(a).startswith(DENSE)]
            assert not (body and dense(p)), ('already occupied', p, t[p])
        i = next(i for i, a in enumerate(t[p]) if a.startswith('/turf'))
        for a in reversed(atoms):
            if a not in t[p]:
                t[p].insert(i, a)

    # ---- reachability -----------------------------------------------------
    region = {p for p in t if t[p][-1] == AREA and floor(p)} | {p for p in t if t[p][-1] == '/area/station/cargo/qm' and floor(p)}
    walk = {p for p in region if not dense(p)}
    seen, stack = set(), [OFFICE_DOOR]
    while stack:
        p = stack.pop()
        if p in seen or p not in walk:
            continue
        seen.add(p)
        stack.extend(step(p, d) for d in DELTA)
    problems = []
    for p, atoms in PLACE.items():
        if p in WALL_TILE or not any(path(a).startswith(DENSE) for a in atoms):
            continue
        near = [(p[0] + dx, p[1] + dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1) if dx or dy]
        if not any(q in seen for q in near):
            problems.append(f'{p}: no reachable free neighbour')
    lost = sorted(p for p in walk if p not in seen and p[1] >= 119)
    if lost:
        problems.append(f'floor cut off from the office door: {lost}')
    for p in [(78, 133)]:  # wall mount must face a reachable tile
        if p not in seen:
            problems.append(f'{p}: requests console tile unreachable')

    # ---- floor trim -------------------------------------------------------
    def paintable(p):
        x, y = p
        if t[p][-1] != AREA or not (73 <= x <= 83 and 119 <= y <= 134):
            return False
        if x >= 80 and y <= 129:  # cargo lobby already has its trim
            return False
        if path(turf(p)) != PLASTEEL:
            return False
        return not any(path(a).startswith(('/obj/machinery/conveyor', '/obj/effect/turf_decal',
                                            '/obj/machinery/door')) for a in t[p])

    painted = 0
    for p in sorted(t):
        if not paintable(p):
            continue
        sides = [d for d in DELTA if is_wallish(step(p, d)) or dense_edge(t, step(p, d))]
        if len(sides) == 1:
            atom = PLASTEEL + ('{icon_state = "brown"}' if sides[0] == 2 else
                               '{dir = %d;icon_state = "brown"}' % sides[0])
        elif len(sides) == 2 and sum(sides) in (5, 6, 9, 10):
            atom = PLASTEEL + '{dir = %d;icon_state = "brown"}' % sum(sides)
        elif not sides:
            corners = [c for c, dg in CORNER.items() if is_wallish((p[0] + DIAG[dg][0], p[1] + DIAG[dg][1]))]
            atom = PLASTEEL if len(corners) != 1 else PLASTEEL + (
                '{icon_state = "browncorner"}' if corners[0] == 2 else
                '{dir = %d;icon_state = "browncorner"}' % corners[0])
        else:
            atom = PLASTEEL
        i = next(i for i, a in enumerate(t[p]) if a.startswith('/turf'))
        if t[p][i] != atom:
            t[p][i] = atom
            painted += 1

    changed = [p for p in t if tuple(t[p]) != orig[p]]
    print(f'tiles changed {len(changed)}, floors repainted {painted}, reachable floor {len(seen)}')
    for pr in problems:
        print('FAIL', pr)
    if problems:
        return 1
    if write:
        for p in changed:
            m.set_tile((p[0], p[1], 1), tuple(t[p]))
        m.to_file(str(MAP))
        print('written')
    return 0


def dense_edge(t, p):
    """The cargo counter (table + windoor) reads as a wall for the trim."""
    return p in t and any(path(a) == '/obj/structure/table/reinforced' for a in t[p]) and any(
        path(a).startswith('/obj/machinery/door/window') for a in t[p])


if __name__ == '__main__':
    sys.exit(main())
