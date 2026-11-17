"""Minimal DMI reader/writer for the asteroid ruin icon builder (needs Pillow)."""
import re
import zlib

from PIL import Image, PngImagePlugin


class State:
    def __init__(self, name, dirs=1, frames=1, delay=None, extra=None):
        self.name = name
        self.dirs = dirs
        self.frames = frames
        self.delay = delay
        self.extra = extra or []
        self.images = []  # frame-major: images[frame * dirs + dir_index]

    def get(self, dir_index=0, frame=0):
        return self.images[frame * self.dirs + min(dir_index, self.dirs - 1)]


def _description(path):
    image = Image.open(path)
    description = image.info.get("Description")
    if description is None:
        raise ValueError(f"{path}: no DMI metadata")
    return image.convert("RGBA"), description


def read(path):
    """Returns (width, height, [State])."""
    sheet, description = _description(path)
    width = int(re.search(r"width = (\d+)", description).group(1))
    height = int(re.search(r"height = (\d+)", description).group(1))
    states = []
    current = None
    for line in description.splitlines():
        line = line.strip()
        match = re.match(r'state = "(.*)"$', line)
        if match:
            current = State(match.group(1))
            states.append(current)
        elif current is not None and " = " in line:
            key, value = line.split(" = ", 1)
            if key == "dirs":
                current.dirs = int(value)
            elif key == "frames":
                current.frames = int(value)
            elif key == "delay":
                current.delay = [float(part) for part in value.split(",")]
            else:
                current.extra.append((key, value))
    columns = sheet.width // width
    index = 0
    for state in states:
        for _ in range(state.dirs * state.frames):
            x = (index % columns) * width
            y = (index // columns) * height
            state.images.append(sheet.crop((x, y, x + width, y + height)))
            index += 1
    return width, height, states


def find(states, name):
    for state in states:
        if state.name == name:
            return state
    raise KeyError(name)


def write(path, width, height, states):
    total = sum(len(state.images) for state in states)
    columns = max(1, int(total ** 0.5 + 0.9999))
    rows = (total + columns - 1) // columns
    sheet = Image.new("RGBA", (columns * width, rows * height), (0, 0, 0, 0))
    lines = ["# BEGIN DMI", "version = 4.0", f"\twidth = {width}", f"\theight = {height}"]
    index = 0
    for state in states:
        if len(state.images) != state.dirs * state.frames:
            raise ValueError(f"{state.name}: {len(state.images)} images for {state.dirs}x{state.frames}")
        lines.append(f'state = "{state.name}"')
        lines.append(f"\tdirs = {state.dirs}")
        lines.append(f"\tframes = {state.frames}")
        if state.delay:
            lines.append("\tdelay = " + ",".join(f"{value:g}" for value in state.delay))
        for key, value in state.extra:
            lines.append(f"\t{key} = {value}")
        for image in state.images:
            sheet.paste(image, ((index % columns) * width, (index // columns) * height))
            index += 1
    lines.append("# END DMI")
    info = PngImagePlugin.PngInfo()
    info.add_text("Description", "\n".join(lines) + "\n", zip=True)
    sheet.save(path, "PNG", pnginfo=info, optimize=True)
