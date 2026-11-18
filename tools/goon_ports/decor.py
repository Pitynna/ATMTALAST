"""Builds the Goonstation decor sprites used by code/game/objects/structures/goon_decor.dm.

Sprites: Goonstation 13, CC BY-NC-SA 3.0 (see docs/GOON_ASSETS.md).

Usage: python -I tools/goon_ports/decor.py [path-to-goonstation-checkout]

Writes only icons/obj/goon_decor.dmi (32x32) and icons/obj/goon_cabinet.dmi (32x64).
States keep their Goon names; states from the sign/poster/ISO sheets get a prefix so names never clash.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools"))

from dmi import Dmi  # noqa: E402

GOON = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "..", "goonstation-master")

DECORATION = (
	[f"vase{i}" for i in range(1, 9)] + ["vase", "vase-flowers"]
	+ [f"ppot{i}" for i in range(1, 6)]
	+ [f"plant{i}" for i in range(1, 8)]
	+ ["monkeyplant", "lil_candle0", "lil_candle1", "candles", "candles-unlit", "clock",
		"bottleship", "bottleship_broken", "skeleton_stand", "gold_bee", "trophy", "trophyfucked",
		"wallfish", "wallfish_move", "opensign-0", "opensign-1", "opensign-glow", "toiletholder",
		"junctionbox", "junctionbox2", "junctionbox3", "junctionbox_open", "junctionbox2_open", "junctionbox3_open",
		"vent1", "vent2", "vent3", "ringrope",
		"wall-lever-up", "wall-lever-down", "wall-lever-up-anim", "wall-lever-down-anim", "bookcase"]
	+ [f"blinds{axis}{seg}-{st}" for axis in "HV" for seg in ("", "-L", "-M", "-R") for st in "oc"]
)

WALLSIGNS = ["medal", "medal1", "rddiploma", "rddiploma1", "mdlicense", "mdlicense1", "hopcredit", "hopcredit1",
	"frame", "portrait", "portrait_scientist", "accidents_sign", "ptoe", "gym", "pool", "arcade", "garden",
	"office_plaque", "read_me"]

POSTERS = ["explore_the_trench", "bird_up", "a_new_you", "grow_food_not_weed", "more_laser_power", "pack_smart",
	"capy_king", "biodome", "rat", "mandarin_belief", "keep_it_or_melt"]


def sheet(*parts):
	return Dmi.from_file(os.path.join(GOON, "icons", "obj", *parts))


def copy(dst, src, name, new_name=None):
	s = src.get_state(name)
	st = dst.state(new_name or name, dirs=s.dirs, loop=s.loop, rewind=s.rewind)
	st.frames = list(s.frames)
	st.delays = list(s.delays) if s.delays else [1] * (len(s.frames) // s.dirs)


def main():
	out = Dmi(32, 32)
	deco = sheet("decoration.dmi")
	for name in DECORATION:
		copy(out, deco, name)
	signs = sheet("decals", "wallsigns.dmi")
	for name in WALLSIGNS:
		copy(out, signs, name, "sign_" + name)
	posters = sheet("decals", "posters.dmi")
	for name in POSTERS:
		copy(out, posters, name, "poster_" + name)
	iso = sheet("decals", "ISO_signs.dmi")
	for s in iso.states:
		copy(out, iso, s.name, "iso_" + s.name)
	guides = sheet("decals", "floorguides.dmi")
	for s in guides.states:
		if s.name.startswith(("guide_", "endpiece_")) and "(" not in s.name:
			copy(out, guides, s.name)
	copy(out, sheet("decals", "misc.dmi"), "drain")
	out.to_file(os.path.join(ROOT, "icons", "obj", "goon_decor.dmi"))

	cab = Dmi(32, 64)
	src = sheet("furniture", "cabinet.dmi")
	for s in src.states:
		copy(cab, src, s.name)
	cab.to_file(os.path.join(ROOT, "icons", "obj", "goon_cabinet.dmi"))
	print(len(out.states), "decor states,", len(cab.states), "cabinet states")


if __name__ == "__main__":
	main()
