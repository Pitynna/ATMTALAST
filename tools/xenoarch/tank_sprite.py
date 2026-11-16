"""Generate icons/obj/fossil_tank.dmi: the growth tank as one 32x64 sprite.

The historical tank is two 32x32 halves in icons/obj/xenoarchaeology.dmi
(cellbottom*, celltop*). Drawing the top as an offset overlay is fragile, so
the halves are stacked into single tall frames.

Run from the repository root:  python tools/xenoarch/tank_sprite.py
"""
import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from dmi import ROOT, read_states, write_dmi  # noqa: E402

SOURCE = "icons/obj/xenoarchaeology.dmi"
STATES = {
    "tank": ("cellbottomold", "celltopold"),
    "tank_growing": ("cellbottomold", "celltop_1old"),
    "tank_off": ("cellbottom-pold", "celltop-pold"),
}


def main():
    src = read_states(SOURCE)[0]
    out = []
    for name, (bottom, top) in STATES.items():
        frame = Image.new("RGBA", (32, 64), (0, 0, 0, 0))
        frame.alpha_composite(src[top]["images"][0], (0, 0))
        frame.alpha_composite(src[bottom]["images"][0], (0, 32))
        out.append((name, [frame], 1, 1, None))
    target = ROOT / "icons/obj/fossil_tank.dmi"
    write_dmi(target, out, width=32, height=64)
    print("wrote", target)


if __name__ == "__main__":
    main()
