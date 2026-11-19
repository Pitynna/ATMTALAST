"""Public rooms south of the south corridor (user layout, 2026-11-19).

The user built the shells in StrongDMM (still /area/space): a 4x4 and a 6x4
room with shop windows on the south corridor, a grass room, and a corridor
that runs from the south corridor to an open end in space, with a side
branch to the legal hallway and a small alcove. Content follows the old
ATMTA (excidium) pet store and auxiliary tool storage and Cyberiad's public
garden:

* Pet Store (x90-93) - Critter Care vendor, fish bowls, plant;
* Auxiliary Tool Storage (x95-100) - tool closets, material racks, tanks;
* Garden (x105-111) - soil plots, seed vendors, extractor, biogenerator;
* Commons Hallway - the corridor; the alcove holds emergency closets; the
  open end becomes a two-door external airlock with a catwalk outside.
Doors, zones (walls follow their room), APCs fed from the corridor cable
through the doors, one vent+scrubber pair per room on a branch tapped from
the south corridor trunk at (101,107) and run along y105 through the doors,
air/fire alarms, tube lamps, cameras.
Incremental: refuses to touch a tile that is no longer what it expects.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
sys.path.insert(0, str(Path(__file__).resolve().parent))
from dmm import DMM  # noqa: E402
from thin_air import pipe_atom, HIDDEN, path, bits_of  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
N, S, E, W = 1, 2, 4, 8
PET = '/area/station/commons/pet_store'
TOOLS = '/area/station/commons/storage/tools'
GARDEN = '/area/station/hallway/secondary/garden'
HALL = '/area/station/hallway/ulthor_commons'
SPACE = '/area/space'

ROOMS = {
    PET: [(x, y) for x in range(90, 94) for y in range(100, 104)],
    TOOLS: [(x, y) for x in range(95, 101) for y in range(100, 104)],
}
VENT = '/obj/machinery/atmospherics/unary/vent_pump/on'
SCRUB = '/obj/machinery/atmospherics/unary/vent_scrubber/on'
GLASS_DOOR = '/obj/machinery/door/airlock/public/glass{name = "%s"}'
FIREDOOR = '/obj/machinery/door/firedoor'
EXT = '/obj/machinery/door/airlock/external{name = "External Airlock"}'
CABLE = '/obj/structure/cable'


class Ed:
    def __init__(self):
        self.m = DMM.from_file(str(MAP))
        self.t = {(x, y): list(self.m.get_tile((x, y, 1))) for (x, y, z) in self.m.grid}
        self.orig = {p: tuple(v) for p, v in self.t.items()}

    def has(self, p, *pre):
        return any(a.startswith(pre) for a in self.t[p])

    def area(self, p):
        return self.t[p][-1]

    def set_area(self, p, a):
        self.t[p][-1] = a

    def put(self, p, *atoms):
        for atom in atoms:
            if atom not in self.t[p]:
                self.t[p].insert(0, atom)

    def turf(self, p, turf):
        i = next(i for i, a in enumerate(self.t[p]) if a.startswith('/turf'))
        self.t[p][i] = turf

    def pipe(self, p, k, add_bits):
        """Lay or extend the hidden k pipe on p by add_bits."""
        tile = self.t[p]
        for i, a in enumerate(tile):
            mm = HIDDEN.match(path(a))
            if mm and mm[2] == k:
                tile[i] = pipe_atom(k, bits_of(a) | add_bits)
                return
        i = next(i for i, a in enumerate(tile) if a.startswith('/turf'))
        tile.insert(i, pipe_atom(k, add_bits))

    def run(self, k, tiles):
        """Pipe along a 4-connected chain of tiles (each joined to the next)."""
        for a, b in zip(tiles, tiles[1:]):
            d = {(0, 1): N, (0, -1): S, (1, 0): E, (-1, 0): W}[(b[0] - a[0], b[1] - a[1])]
            rev = {N: S, S: N, E: W, W: E}[d]
            self.pipe(a, k, d)
            self.pipe(b, k, rev)

    def device(self, p, atom, toward):
        d = {(0, 1): N, (0, -1): S, (1, 0): E, (-1, 0): W}[(toward[0] - p[0], toward[1] - p[1])]
        self.put(p, atom + ('' if d == S else '{dir = %d}' % d))
        k = 'supply' if 'vent_pump' in atom else 'scrubbers'
        self.pipe(toward, k, {N: S, S: N, E: W, W: E}[d])

    def cable(self, tiles):
        for p in tiles:
            if not any(a.startswith(CABLE) and a.split('{')[0] == CABLE for a in self.t[p]):
                self.put(p, CABLE)


def main():
    E_ = Ed()
    t = E_.t
    if E_.area((92, 101)) != SPACE:
        sys.exit('Pet store shell already zoned - nothing to do (or the layout changed).')
    hall_floor, garden = [], []
    for p, tile in t.items():
        if E_.area(p) != SPACE or not E_.has(p, '/turf/simulated/floor'):
            continue
        if E_.has(p, '/turf/simulated/floor/grass'):
            garden.append(p)
        elif 102 <= p[0] <= 111 and 83 <= p[1] <= 104 and p not in ROOMS[PET] + ROOMS[TOOLS]:
            hall_floor.append(p)
    for a, ps in ROOMS.items():
        for p in ps:
            E_.set_area(p, a)
    for p in garden:
        E_.set_area(p, GARDEN)
    for p in hall_floor:
        E_.set_area(p, HALL)
    # Floors: pet store wood, tool storage plain steel.
    for p in ROOMS[PET]:
        E_.turf(p, '/turf/simulated/floor/wood')
    for p in ROOMS[TOOLS]:
        E_.turf(p, '/turf/simulated/floor/plasteel')

    # ---- external airlock at the open end ---------------------------------
    for p in [(102, y) for y in (84, 85, 86)] + [(105, y) for y in (84, 85, 86)]:
        t[p] = ['/turf/simulated/wall/r_wall', HALL]
    for x in (103, 104):
        E_.put((x, 87), EXT)
        E_.put((x, 84), EXT)
        for y in (84, 85, 86):
            E_.turf((x, y), '/turf/simulated/floor/plating')
        t[(x, 83)] = ['/obj/structure/lattice/catwalk', '/turf/space', SPACE]

    # ---- doors -------------------------------------------------------------
    E_.put((91, 104), GLASS_DOOR % 'Pet Store', FIREDOOR)
    E_.set_area((91, 104), PET)
    E_.put((97, 104), GLASS_DOOR % 'Auxiliary Tool Storage', FIREDOOR)
    E_.set_area((97, 104), TOOLS)
    for p in ((102, 104), (103, 104), (111, 95), (111, 96)):
        E_.put(p, FIREDOOR)

    # ---- air: tap the south corridor trunk at (101,107) --------------------
    for k in ('supply', 'scrubbers'):
        tile = t[(101, 107)]
        a = next(a for a in tile if (mm := HIDDEN.match(path(a))) and mm[2] == k)
        assert bits_of(a) == E | W, (k, a)
        E_.run(k, [(101, 107), (101, 106), (101, 105)])
        E_.run(k, [(101, 105)] + [(x, 105) for x in range(100, 90, -1)])  # west to the pet store
        E_.run(k, [(91, 105), (91, 104), (91, 103)])
        E_.run(k, [(97, 105), (97, 104), (97, 103)])
        E_.run(k, [(101, 105)] + [(x, 105) for x in range(102, 110)])  # east to the garden
        E_.run(k, [(109, 105), (109, 104), (109, 103)])
        E_.run(k, [(102, 105), (102, 104), (102, 103), (102, 102), (102, 101), (102, 100), (102, 99),
                   (103, 99), (103, 98), (103, 97), (103, 96)])
    for vent, scrub, end in (((91, 102), (90, 103), (91, 103)), ((97, 102), (98, 103), (97, 103)),
                             ((109, 102), (110, 103), (109, 103)), ((103, 95), (104, 96), (103, 96))):
        E_.device(vent, VENT, end)
        E_.device(scrub, SCRUB, end)

    # ---- power: cables from the y106 corridor cable through the doors -------
    E_.cable([(91, 105), (91, 104), (91, 103), (91, 102), (91, 101), (90, 101)])
    E_.cable([(97, 105), (97, 104), (97, 103), (96, 103), (95, 103), (95, 102), (95, 101)])
    E_.cable([(109, 105), (109, 104), (109, 103), (110, 103), (111, 103), (111, 102), (111, 101)])
    E_.cable([(102, 105), (102, 104), (102, 103), (102, 102), (102, 101), (102, 100)])

    P = E_.put
    # ---- Pet Store ---------------------------------------------------------
    P((90, 101), '/obj/machinery/power/apc/directional/west')
    P((90, 102), '/obj/machinery/light_switch/directional/west')
    P((92, 100), '/obj/machinery/alarm/directional/south')
    P((93, 101), '/obj/machinery/firealarm/directional/east')
    P((91, 100), '/obj/machinery/light')
    P((93, 103), '/obj/machinery/fishtank/bowl', '/obj/structure/table/wood')
    P((93, 102), '/obj/machinery/fishtank/bowl', '/obj/structure/table/wood')
    P((93, 100), '/obj/machinery/vending/crittercare')
    P((90, 100), '/obj/item/twohanded/required/kirbyplants')
    P((92, 102), '/obj/item/reagent_containers/cup/bucket')

    # ---- Auxiliary Tool Storage ---------------------------------------------
    P((95, 101), '/obj/machinery/power/apc/directional/west')
    P((95, 100), '/obj/machinery/light_switch/directional/west')
    P((96, 100), '/obj/machinery/alarm/directional/south')
    P((99, 100), '/obj/machinery/firealarm/directional/south')
    P((98, 100), '/obj/machinery/light')
    P((100, 100), '/obj/machinery/camera{c_tag = "Auxiliary Tool Storage";dir = 1;start_active = 1}')
    P((95, 103), '/obj/structure/extinguisher_cabinet/directional/west')
    P((95, 103), '/obj/structure/closet/toolcloset')
    P((95, 102), '/obj/structure/closet/toolcloset')
    P((100, 103), '/obj/item/stack/sheet/glass{amount = 20}', '/obj/item/stack/sheet/metal{amount = 30}',
      '/obj/structure/rack')
    P((100, 102), '/obj/item/stack/tape_roll', '/obj/item/stack/tape_roll', '/obj/item/stack/rods{amount = 25}',
      '/obj/structure/rack')
    P((96, 100), '/obj/item/storage/box/lights/mixed', '/obj/item/storage/toolbox/emergency', '/obj/structure/table')
    P((97, 100), '/obj/item/airlock_electronics', '/obj/item/apc_electronics', '/obj/item/multitool',
      '/obj/structure/table')
    P((98, 100), '/obj/item/clothing/gloves/color/fyellow', '/obj/item/clothing/suit/storage/hazardvest',
      '/obj/structure/table')
    P((99, 100), '/obj/structure/reagent_dispensers/watertank')
    P((100, 101), '/obj/structure/reagent_dispensers/fueltank')
    P((98, 102), '/obj/machinery/hologram/holopad')

    # ---- Garden ------------------------------------------------------------
    P((111, 101), '/obj/machinery/power/apc/directional/east')
    P((111, 102), '/obj/machinery/light_switch/directional/east')
    P((105, 101), '/obj/machinery/alarm/directional/west')
    P((106, 100), '/obj/machinery/firealarm/directional/west')
    P((110, 98), '/obj/machinery/light')
    P((105, 103), '/obj/machinery/light{dir = 8}')
    P((111, 98), '/obj/machinery/camera{c_tag = "Garden";dir = 1;start_active = 1}')
    for p in ((106, 101), (107, 101), (106, 100), (107, 100), (106, 99), (107, 99)):
        P(p, '/obj/machinery/hydroponics/soil')
    P((105, 103), '/obj/machinery/vending/hydroseeds')
    P((105, 102), '/obj/machinery/vending/hydronutrients')
    P((110, 98), '/obj/machinery/seed_extractor')
    P((109, 98), '/obj/machinery/biogenerator')
    P((108, 98), '/obj/structure/reagent_dispensers/watertank/high')
    P((111, 103), '/obj/item/plant_analyzer', '/obj/item/reagent_containers/cup/bottle/nutrient/l4z',
      '/obj/item/reagent_containers/cup/bottle/nutrient/ez', '/obj/structure/table')
    P((111, 102), '/obj/item/reagent_containers/spray/pestspray', '/obj/item/reagent_containers/spray/plantbgone',
      '/obj/item/shovel/spade', '/obj/item/cultivator', '/obj/item/storage/bag/plants/portaseeder',
      '/obj/structure/table')
    P((106, 98), '/obj/structure/flora/ausbushes/grassybush')
    P((107, 98), '/obj/structure/flora/ausbushes/ywflowers')
    P((106, 103), '/obj/structure/flora/ausbushes/ppflowers')
    P((108, 102), '/obj/item/reagent_containers/cup/bucket')

    # ---- Commons Hallway -----------------------------------------------------
    P((102, 100), '/obj/machinery/power/apc/directional/west')
    P((104, 98), '/obj/machinery/alarm/directional/east')
    P((103, 91), '/obj/machinery/firealarm/directional/west')
    P((103, 102), '/obj/machinery/light{dir = 4}')
    P((104, 93), '/obj/machinery/light{dir = 4}')
    P((110, 96), '/obj/machinery/light{dir = 1}')
    P((104, 88), '/obj/machinery/light{dir = 4}')
    P((103, 89), '/obj/machinery/camera{c_tag = "Commons Hallway South";dir = 4;start_active = 1}')
    P((106, 90), '/obj/structure/closet/emcloset')
    P((107, 90), '/obj/structure/closet/emcloset')
    P((108, 90), '/obj/structure/closet/firecloset')
    P((108, 92), '/obj/machinery/light{dir = 4}')

    # ---- walls follow the room they enclose ----------------------------------
    owner = {}
    for p, tile in t.items():
        a = tile[-1]
        if a in (PET, TOOLS, GARDEN, HALL) and not E_.has(p, '/turf/simulated/wall', '/obj/effect/spawner/window'):
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    q = (p[0] + dx, p[1] + dy)
                    if q in t and t[q][-1] == SPACE and E_.has(q, '/turf/simulated/wall', '/obj/effect/spawner/window'):
                        rank = {PET: 0, TOOLS: 0, GARDEN: 0, HALL: 1}[a]
                        if q not in owner or rank < owner[q][0]:
                            owner[q] = (rank, a)
    for q, (_, a) in owner.items():
        t[q][-1] = a

    changed = 0
    for p, tile in t.items():
        if tuple(tile) != E_.orig[p]:
            E_.m.set_tile((p[0], p[1], 1), tuple(tile))
            changed += 1
    E_.m.to_file(str(MAP))
    print('tiles changed', changed, '; walls zoned', len(owner))


if __name__ == '__main__':
    main()
