"""Minimal BYOND .dmi reader/writer used by the xenoarchaeology sprite tools."""
import zlib
from pathlib import Path

from PIL import Image, PngImagePlugin

ROOT = Path(__file__).resolve().parents[2]


def read_states(relative_path):
    """Return {state: {"dirs", "frames", "delay", "images"}} preserving order."""
    sheet = Image.open(ROOT / relative_path)
    desc = sheet.info["Description"]
    width = height = 32
    states = {}
    order = []
    current = None
    for line in desc.splitlines():
        line = line.strip()
        if line.startswith("width"):
            width = int(line.split("=")[1])
        elif line.startswith("height"):
            height = int(line.split("=")[1])
        elif line.startswith("state"):
            current = {"name": line.split('"', 1)[1].rsplit('"', 1)[0], "dirs": 1, "frames": 1, "delay": None}
            order.append(current)
        elif current and line.startswith("dirs"):
            current["dirs"] = int(line.split("=")[1])
        elif current and line.startswith("frames"):
            current["frames"] = int(line.split("=")[1])
        elif current and line.startswith("delay"):
            current["delay"] = [float(v) for v in line.split("=")[1].split(",")]
    sheet = sheet.convert("RGBA")
    columns = sheet.width // width
    index = 0
    for state in order:
        images = []
        for _ in range(state["dirs"] * state["frames"]):
            x, y = (index % columns) * width, (index // columns) * height
            images.append(sheet.crop((x, y, x + width, y + height)))
            index += 1
        state["images"] = images
        states.setdefault(state["name"], state)
    return states, width, height


def write_dmi(path, states, width=32, height=32):
    """states: list of (name, images, dirs, frames, delays|None)."""
    total = sum(len(s[1]) for s in states)
    columns = max(1, int(total ** 0.5 + 0.999))
    rows = (total + columns - 1) // columns
    sheet = Image.new("RGBA", (columns * width, rows * height), (0, 0, 0, 0))
    lines = ["# BEGIN DMI", "version = 4.0", f"\twidth = {width}", f"\theight = {height}"]
    index = 0
    for name, images, dirs, frames, delays in states:
        assert len(images) == dirs * frames, name
        lines.append(f'state = "{name}"')
        lines.append(f"\tdirs = {dirs}")
        lines.append(f"\tframes = {frames}")
        if delays:
            lines.append("\tdelay = " + ",".join(str(d) for d in delays))
        for image in images:
            sheet.paste(image, ((index % columns) * width, (index // columns) * height))
            index += 1
    lines.append("# END DMI")
    info = PngImagePlugin.PngInfo()
    info.add_text("Description", "\n".join(lines) + "\n", zip=True)
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    sheet.save(path, format="PNG", pnginfo=info, optimize=True)
