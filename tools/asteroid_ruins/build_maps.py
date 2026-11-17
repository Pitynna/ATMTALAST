"""Writes the first version of the asteroid ruin maps from the ASCII layouts below.

Run from the repository root:  python tools/asteroid_ruins/build_maps.py
It refuses to touch a map that already exists: once a map has been opened in an editor,
change it there (or by hand), never by regenerating it. --force is for a deliberate reset only.
"""
import os
import sys

OUT = "_maps/map_files/RandomRuins/AsteroidRuins"
NOOP = ("/turf/template_noop", "/area/template_noop")

HIDEOUT = "/area/ruin/asteroid/saddam_hideout"
APPROACH = "/area/ruin/asteroid/saddam_hideout/approach"
WALL = "/turf/simulated/wall/indestructible/reinforced"
PLATING = "/turf/simulated/floor/plating"
PIT = "/turf/simulated/floor/plating/asteroid"
CAVE = "/turf/simulated/floor/plating/asteroid/airless"

# The L of the pit repeats the diagram: the shaft, the fan at its bottom, the man lying beyond it.
SADDAM_LAYOUT = """
~#######~
~#sSF###~
~###g###~
~#cT..B#~
~#dt..L#~
~#r....#~
~###D###~
~,,,R,,,~
~~,,,,,~~
"""
SADDAM_KEY = {
    "~": NOOP,
    "#": (WALL, HIDEOUT),
    ".": (PLATING, HIDEOUT),
    "s": ("/obj/item/bedsheet/brown", PIT, HIDEOUT),
    "S": ("/mob/living/simple_animal/saddam", PIT, HIDEOUT),
    "F": ("/obj/item/toy/desk/fan/saddam", PIT, HIDEOUT),
    "g": ("/obj/effect/decal/cleanable/dirt", PIT, HIDEOUT),
    "c": ("/obj/structure/chair/wood{\n\tdir = 4\n\t}", PLATING, HIDEOUT),
    "d": ("/obj/structure/chair/wood{\n\tdir = 4\n\t}", "/obj/effect/decal/cleanable/dirt", PLATING, HIDEOUT),
    "T": ("/obj/structure/table/wood", "/obj/item/flashlight/lantern", PLATING, HIDEOUT),
    "t": ("/obj/structure/table/wood", "/obj/item/paper/fluff/ruins/saddam_hideout", PLATING, HIDEOUT),
    "B": ("/obj/structure/bed", "/obj/item/bedsheet/brown", PLATING, HIDEOUT),
    "L": ("/obj/structure/closet/crate", PLATING, HIDEOUT),
    "r": ("/obj/structure/rack", "/obj/effect/decal/cleanable/cobweb", PLATING, HIDEOUT),
    "D": ("/obj/structure/falsewall/saddam", PLATING, HIDEOUT),
    ",": (CAVE, APPROACH),
    "R": ("/obj/effect/saddam_rune", CAVE, APPROACH),
}

STUDIO = "/area/ruin/asteroid/schizo_room"
WOOD = "/turf/simulated/floor/wood"

SCHIZO_LAYOUT = """
######
#.RB.#
#.Tt.#
#..K.#
###D##
"""
SCHIZO_KEY = {
    "#": ("/turf/simulated/wall", STUDIO),
    ".": (WOOD, STUDIO),
    "R": ("/obj/structure/chair/wood", "/mob/living/simple_animal/schizo/rybnikov", WOOD, STUDIO),
    "B": ("/obj/structure/chair/wood", "/mob/living/simple_animal/schizo/boyarshinov", WOOD, STUDIO),
    "T": ("/obj/structure/table/wood", WOOD, STUDIO),
    "t": ("/obj/structure/table/wood", "/obj/item/poster/schizo_count", WOOD, STUDIO),
    "K": ("/obj/structure/tripod/schizo_studio", WOOD, STUDIO),
    "D": ("/obj/structure/mineral_door/wood", WOOD, STUDIO),
}


def tgm(layout, key):
    rows = [row for row in layout.strip().splitlines()]
    width = len(rows[0])
    assert all(len(row) == width for row in rows), "ragged layout"
    symbols = sorted({symbol for row in rows for symbol in row})
    names = {symbol: chr(ord("a") + index) for index, symbol in enumerate(symbols)}
    out = ["//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE"]
    for symbol in symbols:
        out.append(f'"{names[symbol]}" = (')
        out.append(",\n".join(key[symbol]) + ")")
    out.append("")
    for x in range(width):
        out.append(f'({x + 1},1,1) = {{"')
        out.extend(names[row[x]] for row in rows)
        out.append('"}')
    return "\n".join(out) + "\n"


def main():
    force = "--force" in sys.argv
    os.makedirs(OUT, exist_ok=True)
    for name, layout, key in (("saddam_hideout.dmm", SADDAM_LAYOUT, SADDAM_KEY), ("schizo_room.dmm", SCHIZO_LAYOUT, SCHIZO_KEY)):
        path = f"{OUT}/{name}"
        if os.path.exists(path) and not force:
            print(f"{path} exists, left alone")
            continue
        with open(path, "w", encoding="utf8", newline="\n") as handle:
            handle.write(tgm(layout, key))
        print(f"wrote {path}")


if __name__ == "__main__":
    main()
