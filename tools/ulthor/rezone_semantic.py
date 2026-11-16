"""Give Ulthor's areas meaningful types (incremental edit of the current map).

The earlier wall-following rezone left 39 areas named by coordinates
(`ulthor_108_176`...) and several named areas that do not match their room
(`medical/break_room` is the science rest room, `science/genetics` is the
research hallway, solar arrays named after the wrong side...). Each room was
identified by its contents (job starts, machines) and given the standard type
the reference maps (Cyberiad, Delta) use, or a named Ulthor type.

Only area atoms change, plus: APCs removed where two areas merge into one,
an APC (and two cable tiles) for the future engine room. Refuses to run on a
map with uncommitted edits.
"""
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools/mapmerge2"))
from dmm import DMM  # noqa: E402

MAP = ROOT / "_maps/map_files/Ulthor/Ulthor.dmm"
S = "/area/station/"

RENAME = {
    # AI
    "ai/ulthor_141_152": "ai/ulthor_core",                 # AI start, turrets
    "ai/ulthor_148_151": "ai/ulthor_cyborg_station",       # cyborg starts, robot cryo
    "ai/upload/ulthor": "ai/upload/chamber",
    "telecomms/ulthor_145_147": "telecomms/chamber",       # tcomms core
    # command
    "command/ulthor_100_175": "command/gateway",
    "command/ulthor_104_164": "command/office/blueshield",
    "command/ulthor_106_160": "command/office/ntrep",
    "command/ulthor_141_185": "command/office/cmo",
    "command/ulthor_153_164": "command/vault",             # nuke, safe
    "command/ulthor_154_145": "command/office/ce",
    "command/office/qm/ulthor": "command/office/qm",
    "engineering/ulthor_eva": "command/eva",
    # commons
    "commons/ulthor_81_165": "commons/arcade",
    "commons/ulthor_85_173": "commons/dorms",              # cryopods, wardrobes
    "commons/ulthor_87_165": "/area/janitor",
    "commons/ulthor_89_175": "commons/ulthor_emergency_storage",
    # engineering
    "engineering/ulthor_149_129": "engineering/storage/secure",  # emitters, field gens, sing gen
    "engineering/ulthor_151_130": "engineering/storage",         # engine suits, SMES
    "engineering/ulthor_152_122": "engineering/ulthor_drone_bay",
    "engineering/ulthor_158_119": "engineering/engine",          # main hall, engineer starts
    "engineering/ulthor_163_93": "engineering/mechanic_workshop",
    # hallways (fore = north, aft = south)
    "hallway/primary/port": "hallway/primary/aft",
    "hallway/ulthor_service_north": "hallway/primary/fore",
    # maintenance / solars
    "maintenance/asmaint2": "maintenance/ulthor_northeast_passage",
    "maintenance/solars/port/aft": "maintenance/solars/port/fore",       # north-west array room
    "solars/port/aft": "solars/port/fore",
    "maintenance/solars/starboard": "maintenance/solars/starboard/aft",  # south-east array room
    "solars/starboard/ulthor": "solars/starboard/aft",
    # medical
    "medical/ulthor_108_176": "medical/break_room",        # scrubs, doctor start
    "medical/ulthor_110_175": "medical/chemistry",
    "medical/ulthor_113_186": "medical/morgue",
    "medical/ulthor_118_183": "medical/ward",
    "medical/ulthor_124_179": "medical/medbay",
    "medical/ulthor_122_183": "medical/surgery/north",
    "medical/ulthor_131_183": "medical/surgery/south",
    "medical/ulthor_135_176": "medical/paramedic",
    "medical/ulthor_135_192": "medical/virology",
    "medical/ulthor_139_176": "medical/psych",
    "medical/ulthor_145_181": "medical/storage",
    # science
    "medical/break_room": "science/break_room",            # scientist closets, by R&D
    "science/genetics": "science/research/lobby",          # hallway, vending
    "science/ulthor_123_191": "science/genetics",          # DNA scanners, geneticists
    "science/ulthor_186_169": "science/toxins/launch",     # doppler array, driver button
    # service
    "service/ulthor_72_141": "service/kitchen",
    "service/ulthor_80_150": "service/bar",
    "service/ulthor_82_155": "/area/hydroponics",
    "service/ulthor_86_180": "service/chapel/office",
    "service/ulthor_91_176": "service/chapel",
    "service/ulthor_93_151": "service/clown",
    "service/ulthor_mime_office": "service/mime",
    "service/ulthor_theatre": "service/theatre",
    "service/ulthor_costume_storage": "service/theatre",   # one tile + its own APC
    "service/barber/ulthor": "service/barber",
    "cargo/ulthor_76_110": "cargo/storage",                # one conveyor tile + its own APC
}


def box(x0, y0, x1, y1):
    return {(x, y, 1) for x in range(x0, x1 + 1) for y in range(y0, y1 + 1)}


# (tiles, only if currently in this area, new area)
PIECES = [
    (box(139, 148, 140, 149), "telecomms/ulthor_145_147", "ai/ulthor_core"),  # SMES pocket of the core
    (box(96, 163, 98, 167), "commons/ulthor_96_166", "command/eva"),           # same room as EVA
    (box(108, 180, 109, 181), "commons/ulthor_96_166", "medical/ward"),        # medbay cryo freezer closet
    (box(60, 130, 69, 160), "service/ulthor_72_141", "maintenance/ulthor_west_passage"),  # empty plating, was port solar maint
    (box(91, 183, 93, 185), "maintenance/ulthor_northwest_passage", "service/chapel/office"),  # crematorium
    (box(139, 164, 139, 166), "command/office/captain", "command/teleporter"),  # teleporter hub
    (box(147, 186, 150, 190), "science/robotics/ulthor", "maintenance/asmaint2"),  # empty plating in maint
    (box(186, 165, 190, 167), "maintenance/asmaint2", "science/toxins/launch"),  # toxins mass driver
    (box(145, 130, 149, 141), "maintenance/ulthor_ai_passage", "engineering/ulthor_engine_room"),  # future engine
    (box(146, 156, 148, 156), "maintenance/ulthor_research_passage", "ai/ulthor_cyborg_station"),  # borg recharger
    (box(64, 139, 64, 139), "/area/space/nearstation", "maintenance/ulthor_west_passage"),  # plating inside the hull
]
# APCs removed when their area is merged into another one that has an APC.
APC_DROP = [(76, 110, 1), (94, 149, 1), "commons/ulthor_96_166"]
ENGINE_APC = (149, 132, 1)
ENGINE_CABLE = [(149, 132, 1), (149, 133, 1), (150, 133, 1), (151, 133, 1), (152, 133, 1)]

NEW_TYPES = {
    "ai/ulthor_core": ("AI Core", "ai_chamber"),
    "ai/ulthor_cyborg_station": ("Cyborg Station", "ai"),
    "commons/ulthor_emergency_storage": ("Emergency Storage", "emergencystorage"),
    "engineering/ulthor_drone_bay": ("Drone Fabrication", "engine"),
    "engineering/ulthor_engine_room": ("Engine Room", "engine"),
    "maintenance/ulthor_northeast_passage": ("Ulthor North-East Maintenance", "asmaint"),
}


def full(a):
    return a if a.startswith("/area/") else S + a


def main():
    if subprocess.run(["git", "diff", "--quiet", "--", str(MAP)], cwd=ROOT).returncode:
        sys.exit("Ulthor.dmm has uncommitted edits - commit them first.")
    m = DMM.from_file(MAP)
    tiles = {tuple(p): list(m.get_tile(p)) for p in m.grid}
    # Compare by type: one area carries a name override (genetics = "Research
    # Division"); retyped tiles get the plain new type, whose name is right.
    area = {p: t[-1].split("{", 1)[0] for p, t in tiles.items()}
    # One step per tile: a piece target is final unless it names an area
    # that is itself renamed; never chain renames (break_room, genetics).
    ren = {full(k): full(v) for k, v in RENAME.items()}
    new = {p: ren.get(a, a) for p, a in area.items()}
    for tiles_, old, to in PIECES:
        for p in tiles_:
            if area.get(p) == full(old):
                new[p] = ren.get(full(to), full(to))
    for p, a in area.items():  # walls left in the split EVA tool-storage area
        if a == full("commons/ulthor_96_166") and new[p] == a:
            new[p] = full("command/eva")
    changed = {p for p in tiles if new[p] != area[p]}
    for p in changed:
        tiles[p][-1] = new[p]
    drop = [p for p in APC_DROP if isinstance(p, tuple)]
    drop += [p for p, a in area.items() if a == full(APC_DROP[-1])
             and any(x.startswith("/obj/machinery/power/apc") for x in tiles[p])]
    for p in drop:
        before = len(tiles[p])
        tiles[p] = [x for x in tiles[p] if not x.startswith("/obj/machinery/power/apc")]
        assert len(tiles[p]) == before - 1, f"no APC at {p}"
        changed.add(p)
    # Future engine room: APC on its east wall, wired through the door.
    assert new[ENGINE_APC] == full("engineering/ulthor_engine_room")
    assert any(x.startswith("/obj/machinery/door") for x in tiles[(150, 133, 1)])
    assert any(x.startswith("/obj/structure/cable") for x in tiles[(153, 133, 1)])
    tiles[ENGINE_APC].insert(0, "/obj/machinery/power/apc{dir = 4;pixel_x = 24;pixel_y = 0}")
    for p in ENGINE_CABLE:
        if not any(x.startswith("/obj/structure/cable") for x in tiles[p]):
            tiles[p].insert(0, "/obj/structure/cable")
    changed |= set(ENGINE_CABLE)
    for p in changed:
        m.set_tile(p, tuple(tiles[p]))
    used = set(m.grid.values())  # mapmerge keeps stale keys; drop them
    for k in [k for k in m.dictionary if k not in used]:
        del m.dictionary[k]
    m.to_file(str(MAP))
    print(f"retyped {sum(new[p] != area[p] for p in tiles)} tiles, APCs removed {len(drop)}, engine room APC added")


if __name__ == "__main__":
    main()
