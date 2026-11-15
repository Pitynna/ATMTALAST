"""Procedural, original sprites for the stationary mining drills (docs/MINING_DRILLS.md).

Writes icons/obj/mining_drills.dmi. Deterministic: rerunning produces the same file.

    python tools/mining_drills/generate_sprites.py [output.dmi]

States produced so far (stage 1, "Deposits"):
  deposit_<ore>_<1..3>  open deposit tile drawn over the asteroid floor
  deposit_scan_<ore>    mining scanner highlight drawn on the rock above a hidden deposit
"""
import math
import random
import sys
from pathlib import Path

from PIL import Image
from PIL.PngImagePlugin import PngInfo

SIZE = 32
ROOT = Path(__file__).resolve().parents[2]
DEFAULT_OUTPUT = ROOT / "icons" / "obj" / "mining_drills.dmi"

# ore id: (shadow, base, highlight, shape)
ORES = {
    "iron": ((0x6E, 0x34, 0x20), (0xB0, 0x60, 0x3A), (0xE0, 0x96, 0x64), "nugget"),
    "plasma": ((0x52, 0x1C, 0x78), (0x9B, 0x3F, 0xD0), (0xDE, 0x9C, 0xFF), "crystal"),
    "silver": ((0x5E, 0x62, 0x70), (0xA4, 0xAA, 0xB8), (0xEE, 0xF0, 0xF6), "nugget"),
    "gold": ((0x86, 0x5E, 0x0E), (0xDC, 0xAC, 0x2C), (0xFF, 0xEE, 0x8C), "nugget"),
    "titanium": ((0x5E, 0x88, 0x94), (0xB4, 0xDA, 0xE2), (0xF2, 0xFF, 0xFF), "nugget"),
    "uranium": ((0x2A, 0x66, 0x16), (0x5C, 0xBE, 0x38), (0xBC, 0xFF, 0x7C), "glowing"),
    "diamond": ((0x40, 0x9C, 0xBE), (0xA4, 0xEC, 0xFF), (0xFF, 0xFF, 0xFF), "crystal"),
    "bluespace": ((0x18, 0x26, 0x96), (0x38, 0x66, 0xFF), (0x9C, 0xD4, 0xFF), "crystal"),
}

ROCK_DARK = (0x22, 0x1E, 0x1B)
ROCK_MID = (0x3A, 0x33, 0x2E)
ROCK_LIGHT = (0x52, 0x49, 0x42)


def put(img, x, y, color, alpha=255):
    if 0 <= x < SIZE and 0 <= y < SIZE:
        img.putpixel((x, y), (*color, alpha))


def blend(color_a, color_b, t):
    return tuple(round(a + (b - a) * t) for a, b in zip(color_a, color_b))


def patch_mask(rng):
    """Irregular blob that fills most of the tile, so neighbouring deposit tiles read as one seam."""
    lobes = [(rng.uniform(0, math.tau), rng.uniform(0.6, 1.6), rng.randint(2, 5)) for _ in range(3)]
    mask = {}
    for y in range(SIZE):
        for x in range(SIZE):
            dx, dy = x - 15.5, y - 15.5
            angle = math.atan2(dy, dx)
            radius = 14.2 + sum(amp * math.sin(freq * angle + phase) for phase, amp, freq in lobes)
            distance = math.hypot(dx, dy) * 0.85 + max(abs(dx), abs(dy)) * 0.15
            edge = radius - distance
            if edge > 0:
                mask[(x, y)] = edge
    return mask


def draw_rock(img, rng, mask):
    for (x, y), edge in mask.items():
        shade = blend(ROCK_MID, ROCK_DARK, rng.random() * 0.5)
        if rng.random() < 0.12:
            shade = ROCK_LIGHT
        alpha = 255 if edge > 1.6 else 150
        put(img, x, y, shade, alpha)
    # A few dark cracks running through the seam.
    for _ in range(rng.randint(2, 3)):
        x, y = rng.uniform(6, 26), rng.uniform(6, 26)
        angle = rng.uniform(0, math.tau)
        for _ in range(rng.randint(5, 9)):
            if (round(x), round(y)) in mask:
                put(img, round(x), round(y), ROCK_DARK)
            angle += rng.uniform(-0.7, 0.7)
            x += math.cos(angle)
            y += math.sin(angle)


def draw_nugget(img, rng, cx, cy, palette):
    shadow, base, light = palette[:3]
    radius = rng.uniform(1.6, 2.8)
    for y in range(int(cy - 4), int(cy + 5)):
        for x in range(int(cx - 4), int(cx + 5)):
            dx, dy = x - cx, y - cy
            if dx * dx + dy * dy * 1.2 <= radius * radius:
                light_level = -(dx + dy) / (radius * 2)
                if light_level > 0.25:
                    color = light
                elif light_level < -0.25:
                    color = shadow
                else:
                    color = base
                put(img, x, y, color)
    put(img, round(cx + radius * 0.7), round(cy + radius * 0.7) + 1, ROCK_DARK)


def draw_crystal(img, rng, cx, cy, palette):
    shadow, base, light = palette[:3]
    height = rng.randint(2, 4)
    width = rng.randint(1, 2)
    lean = rng.choice((-0.5, -0.34, 0, 0.34, 0.5))
    cx, cy = round(cx), round(cy)
    for dy in range(-height, height + 1):
        span = round(width * (1 - abs(dy) / (height + 1)) + 0.4)
        shift = round(-dy * lean)
        for dx in range(-span + shift, span + shift + 1):
            if dx - shift < 0:
                color = light
            elif dx - shift > 0:
                color = shadow
            else:
                color = base
            put(img, cx + dx, cy + dy, color)
    put(img, cx - 1 + round((height - 1) * lean), cy - height + 1, (255, 255, 255))
    put(img, cx + 1 - round(height * lean), cy + height, ROCK_DARK)


def draw_deposit(ore, variant):
    palette = ORES[ore]
    rng = random.Random(f"{ore}-{variant}")
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    mask = patch_mask(rng)
    draw_rock(img, rng, mask)
    inner = [pos for pos, edge in mask.items() if edge > 4]
    spots = []
    while len(spots) < rng.randint(5, 7) and inner:
        candidate = rng.choice(inner)
        if all(math.dist(candidate, other) >= 6 for other in spots):
            spots.append(candidate)
        inner.remove(candidate)
    for cx, cy in spots:
        if palette[3] == "crystal":
            draw_crystal(img, rng, cx, cy, palette)
        else:
            draw_nugget(img, rng, cx, cy, palette)
    if palette[3] == "glowing":
        # Faint radioactive specks around the uranium.
        for _ in range(14):
            x, y = rng.choice(list(mask))
            if img.getpixel((x, y))[:3] in (ROCK_MID, ROCK_DARK, ROCK_LIGHT) or rng.random() < 0.5:
                put(img, x, y, blend(palette[1], ROCK_MID, 0.4))
    return img


def draw_scan(ore):
    """Corner brackets and a centre gem: clearly a deposit, distinct from the ore-in-wall overlay."""
    shadow, base, light, _ = ORES[ore]
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    for corner_x, step_x in ((2, 1), (29, -1)):
        for corner_y, step_y in ((2, 1), (29, -1)):
            for i in range(6):
                put(img, corner_x + step_x * i, corner_y, base, 230)
                put(img, corner_x, corner_y + step_y * i, base, 230)
                put(img, corner_x + step_x * i, corner_y + step_y, shadow, 160)
                put(img, corner_x + step_x, corner_y + step_y * i, shadow, 160)
            put(img, corner_x, corner_y, light)
    for dy in range(-4, 5):
        span = 4 - abs(dy)
        for dx in range(-span, span + 1):
            color = light if dx + dy < -1 else shadow if dx + dy > 1 else base
            put(img, 15 + dx, 15 + dy, color, 220)
    return img


def write_dmi(states, output):
    columns = min(len(states), 8)
    rows = math.ceil(len(states) / columns)
    sheet = Image.new("RGBA", (columns * SIZE, rows * SIZE), (0, 0, 0, 0))
    lines = ["# BEGIN DMI", "version = 4.0", f"\twidth = {SIZE}", f"\theight = {SIZE}"]
    for index, (name, image) in enumerate(states):
        sheet.paste(image, ((index % columns) * SIZE, (index // columns) * SIZE))
        lines += [f'state = "{name}"', "\tdirs = 1", "\tframes = 1"]
    lines.append("# END DMI")
    info = PngInfo()
    info.add_text("Description", "\n".join(lines) + "\n", zip=True)
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output, format="PNG", pnginfo=info)


def main():
    output = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_OUTPUT
    states = []
    for ore in ORES:
        for variant in (1, 2, 3):
            states.append((f"deposit_{ore}_{variant}", draw_deposit(ore, variant)))
        states.append((f"deposit_scan_{ore}", draw_scan(ore)))
    write_dmi(states, output)
    print(f"Wrote {len(states)} states to {output}")


if __name__ == "__main__":
    main()
