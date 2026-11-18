"""Builds the Goonstation sprites for the swing sign, business cards and punching bag skins.

Sprites: Goonstation 13, CC BY-NC-SA 3.0 (see docs/GOON_ASSETS.md).

Usage: python -I tools/goon_ports/extras.py [path-to-goonstation-checkout]

Writes icons/obj/goon_misc.dmi, icons/obj/goon_phones.dmi, icons/mob/inhands/goon_misc_{left,right}hand.dmi,
copies the landline sounds to sound/goonstation/phones/, and adds the missing punching bag skins to icons/goonstation/objects/fitness.dmi
(states that already exist there are left alone).
"""
import os
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools"))

from dmi import Dmi  # noqa: E402

GOON = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "..", "goonstation-master")

CARDS = ["businesscard", "businesscard-alt", "businesscard-seneca", "businesscard-vurdulak", "businesscard-josh",
	"businesscard-clowntown", "businesscard-hemera", "businesscard-mabinogi"]
BAGS = ["punchingbagsyndie", "punchingbagsyndie2", "punchingbagcaptain", "punchingbagcaptain2",
	"punchingbagwizard", "punchingbagwizard2", "bopbag", "bopbag2"]


def sheet(*parts):
	return Dmi.from_file(os.path.join(GOON, "icons", *parts))


def copy(dst, src, name, new_name=None):
	s = src.get_state(name)
	st = dst.state(new_name or name, dirs=s.dirs, loop=s.loop, rewind=s.rewind)
	st.frames = list(s.frames)
	st.delays = list(s.delays) if s.delays else [1] * (len(s.frames) // s.dirs)


PHONE_SOUNDS = ["dial.ogg", "hang_up.ogg", "phone_busy.ogg", "pick_up.ogg", "remote_answer.ogg",
	"remote_hangup.ogg", "ring_incoming.ogg", "ring_outgoing.ogg"]


def build_phones():
	src = sheet("obj", "machines", "phones.dmi")
	out = Dmi(32, 32)
	for s in src.states:
		if not s.name.startswith("cellphone"):
			copy(out, src, s.name)
	out.to_file(os.path.join(ROOT, "icons", "obj", "goon_phones.dmi"))
	dst = os.path.join(ROOT, "sound", "goonstation", "phones")
	os.makedirs(dst, exist_ok=True)
	for name in PHONE_SOUNDS:
		shutil.copyfile(os.path.join(GOON, "sound", "machines", "phones", name), os.path.join(dst, name))


def main():
	build_phones()
	swing = sheet("obj", "furniture", "swingsign.dmi")
	out = Dmi(32, 32)
	for name, new in [("blank", "swingsign"), ("written", "swingsign_written"), ("folded", "swingsign_folded"),
			("blank$$cardboard", "swingsign_cardboard"), ("written$$cardboard", "swingsign_cardboard_written"),
			("folded$$cardboard", "swingsign_cardboard_folded")]:
		copy(out, swing, name, new)
	writing = sheet("obj", "writing.dmi")
	for name in CARDS:
		copy(out, writing, name)
	out.to_file(os.path.join(ROOT, "icons", "obj", "goon_misc.dmi"))

	for side, suffix in (("left", "L"), ("right", "R")):
		hands = Dmi(32, 32)
		copy(hands, swing, f"folded_held-{suffix}", "swingsign_folded")
		copy(hands, swing, f"folded_held-{suffix}$$cardboard", "swingsign_cardboard_folded")
		hands.to_file(os.path.join(ROOT, "icons", "mob", "inhands", f"goon_misc_{side}hand.dmi"))

	fitness_path = os.path.join(ROOT, "icons", "goonstation", "objects", "fitness.dmi")
	fitness = Dmi.from_file(fitness_path)
	have = {s.name for s in fitness.states}
	gym = sheet("obj", "gym_objs.dmi")
	added = [name for name in BAGS if name not in have]
	for name in added:
		copy(fitness, gym, name)
	if added:
		fitness.to_file(fitness_path)
	print("ok, bag skins added:", added)


if __name__ == "__main__":
	main()
