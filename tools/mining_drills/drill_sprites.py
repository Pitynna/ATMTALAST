"""Original procedural sprites for the stationary mining drills and their parts.

Used by generate_sprites.py. Each function returns a list of states:
(name, images, dirs, frames, delay). Images are ordered the BYOND way:
for each frame, the directions SOUTH, NORTH, EAST, WEST.
"""
from PIL import Image

SIZE = 32
DIRS = ("S", "N", "E", "W")

# Tier I: dark angular metal, one drilling unit.
STEEL_DARK = (0x2A, 0x2D, 0x31)
STEEL = (0x45, 0x4A, 0x50)
STEEL_LIGHT = (0x66, 0x6D, 0x75)
STEEL_EDGE = (0x8A, 0x92, 0x9A)
OUTLINE = (0x14, 0x15, 0x17)
BIT = (0x9C, 0x9E, 0xA2)
BIT_DARK = (0x5A, 0x5C, 0x60)
HOLE = (0x18, 0x14, 0x12)
DUST = (0x7A, 0x6E, 0x60)
HAZARD = (0xE8, 0xB8, 0x20)
HAZARD_DARK = (0x8A, 0x66, 0x10)
ARROW = (0xFF, 0xD2, 0x2A)
ARROW_SHADE = (0xA8, 0x7C, 0x0C)
LIGHT_OFF = (0x6A, 0x1E, 0x1E)
LIGHT_ON = (0x5C, 0xFF, 0x6A)
LIGHT_ON_DIM = (0x2E, 0xA8, 0x3A)


def new_image():
    return Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))


def put(img, x, y, color, alpha=255):
    if 0 <= x < SIZE and 0 <= y < SIZE:
        img.putpixel((x, y), (*color, alpha))


def rect(img, x0, y0, x1, y1, color):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            put(img, x, y, color)


def box(img, x0, y0, x1, y1, fill, light=None, dark=None):
    """Filled box with a 1px outline, a lit top-left edge and a shaded bottom-right edge."""
    rect(img, x0, y0, x1, y1, OUTLINE)
    rect(img, x0 + 1, y0 + 1, x1 - 1, y1 - 1, fill)
    if light:
        rect(img, x0 + 1, y0 + 1, x1 - 1, y0 + 1, light)
        rect(img, x0 + 1, y0 + 1, x0 + 1, y1 - 1, light)
    if dark:
        rect(img, x0 + 1, y1 - 1, x1 - 1, y1 - 1, dark)
        rect(img, x1 - 1, y0 + 1, x1 - 1, y1 - 1, dark)


def arrow(img, direction):
    """Solid yellow triangle on the output side."""
    rows = ((13, 18), (14, 17), (15, 16))  # widest row first, pointing outwards
    for depth, (start, end) in enumerate(rows):
        for along in range(start, end + 1):
            color = ARROW_SHADE if along in (start, end) and depth == 0 else ARROW
            if direction == "S":
                put(img, along, 29 + depth, color)
            elif direction == "N":
                put(img, along, 2 - depth, color)
            elif direction == "E":
                put(img, 29 + depth, along + 9, color)
            else:
                put(img, 2 - depth, along + 9, color)


def draw_drill_tier1(direction, frame=None):
    """frame None: idle. 0..3: working animation."""
    img = new_image()
    working = frame is not None
    # Skid plate seen in 3/4 view: top surface and a darker front face.
    box(img, 3, 18, 28, 25, STEEL, STEEL_LIGHT, STEEL_DARK)
    rect(img, 4, 26, 27, 27, STEEL_DARK)
    rect(img, 3, 26, 3, 28, OUTLINE)
    rect(img, 28, 26, 28, 28, OUTLINE)
    rect(img, 3, 28, 28, 28, OUTLINE)
    for x in range(5, 27, 3):
        put(img, x, 27, HAZARD if (x // 3) % 2 else HAZARD_DARK)
    for x, y in ((5, 20), (26, 20), (5, 24), (26, 24)):
        put(img, x, y, STEEL_EDGE)
    # Bore hole in the plate.
    rect(img, 13, 21, 18, 24, HOLE)
    rect(img, 12, 22, 19, 23, HOLE)
    # Angular A-frame tower.
    for i in range(14):
        put(img, 7 + i // 4, 18 - i, OUTLINE)
        put(img, 8 + i // 4, 18 - i, STEEL_LIGHT)
        put(img, 24 - i // 4, 18 - i, OUTLINE)
        put(img, 23 - i // 4, 18 - i, STEEL)
    box(img, 9, 3, 22, 6, STEEL, STEEL_EDGE, STEEL_DARK)
    # Drive housing on the mast.
    box(img, 11, 7, 20, 15, STEEL, STEEL_LIGHT, STEEL_DARK)
    rect(img, 13, 9, 18, 9, STEEL_DARK)
    rect(img, 13, 11, 18, 11, STEEL_DARK)
    rect(img, 13, 13, 18, 13, STEEL_DARK)
    # Drill bit with a spiral flute; the flute shifts while working.
    offset = frame or 0
    for y in range(16, 24):
        for x in (14, 15, 16, 17):
            if x in (14, 17) and y > 21:
                continue
            spiral = (x + y + offset) % 4
            put(img, x, y, BIT if spiral < 2 else BIT_DARK)
    put(img, 15, 24, BIT_DARK)
    put(img, 16, 24, BIT_DARK)
    # Status light.
    if working:
        put(img, 15, 4, LIGHT_ON if frame % 2 == 0 else LIGHT_ON_DIM)
        put(img, 16, 4, LIGHT_ON if frame % 2 == 0 else LIGHT_ON_DIM)
        dust = [((11, 20), (20, 21)), ((12, 19), (19, 20)), ((10, 21), (21, 19)), ((11, 19), (20, 20))][frame]
        for x, y in dust:
            put(img, x, y, DUST)
    else:
        put(img, 15, 4, LIGHT_OFF)
        put(img, 16, 4, LIGHT_OFF)
    arrow(img, direction)
    return img


def draw_panel_overlay():
    img = new_image()
    rect(img, 12, 8, 19, 14, OUTLINE)
    rect(img, 13, 9, 18, 13, (0x1E, 0x22, 0x26))
    for x, color in ((14, (0xD0, 0x30, 0x30)), (15, (0x30, 0x70, 0xE0)), (16, (0xE0, 0xC0, 0x30)), (17, (0x40, 0xC0, 0x40))):
        for y in range(10, 13):
            if (x + y) % 2:
                put(img, x, y, color)
    # Hatch door swung open to the side.
    rect(img, 20, 8, 22, 14, OUTLINE)
    rect(img, 21, 9, 21, 13, STEEL_LIGHT)
    return img


def draw_packed_tier1():
    img = new_image()
    # Folded case.
    box(img, 4, 12, 27, 26, STEEL, STEEL_LIGHT, STEEL_DARK)
    rect(img, 5, 27, 26, 28, STEEL_DARK)
    rect(img, 4, 27, 4, 29, OUTLINE)
    rect(img, 27, 27, 27, 29, OUTLINE)
    rect(img, 4, 29, 27, 29, OUTLINE)
    for x in range(6, 26, 3):
        put(img, x, 28, HAZARD if (x // 3) % 2 else HAZARD_DARK)
    # Carry handle.
    rect(img, 12, 8, 19, 8, OUTLINE)
    rect(img, 12, 9, 12, 11, OUTLINE)
    rect(img, 19, 9, 19, 11, OUTLINE)
    rect(img, 13, 9, 18, 9, STEEL_EDGE)
    # Folded drill bit lying on the lid.
    for x in range(8, 22):
        put(img, x, 16, OUTLINE)
        put(img, x, 17, BIT if x % 3 else BIT_DARK)
        put(img, x, 18, BIT_DARK if x % 3 else BIT)
        put(img, x, 19, OUTLINE)
    put(img, 22, 17, BIT_DARK)
    put(img, 22, 18, BIT_DARK)
    put(img, 23, 17, OUTLINE)
    put(img, 23, 18, OUTLINE)
    # Latches and a small yellow arrow badge.
    rect(img, 6, 21, 8, 23, HAZARD_DARK)
    rect(img, 23, 21, 25, 23, HAZARD_DARK)
    for x, y in ((14, 22), (15, 23), (16, 23), (17, 22), (15, 24), (16, 24)):
        put(img, x, y, ARROW)
    return img


def draw_module_base():
    img = new_image()
    box(img, 9, 11, 22, 21, STEEL, STEEL_LIGHT, STEEL_DARK)
    rect(img, 10, 20, 21, 20, HAZARD)
    for x in range(11, 21, 2):
        put(img, x, 22, (0xC8, 0xA0, 0x40))
    put(img, 12, 14, LIGHT_ON_DIM)
    return img


def drill_states():
    states = []
    idle = [draw_drill_tier1(d) for d in DIRS]
    states.append(("drill1", idle, 4, 1, None))
    working = [draw_drill_tier1(d, frame) for frame in range(4) for d in DIRS]
    states.append(("drill1_on", working, 4, 4, (2, 2, 2, 2)))
    states.append(("drill1_panel", [draw_panel_overlay()], 1, 1, None))
    states.append(("drill1_packed", [draw_packed_tier1()], 1, 1, None))
    states.append(("module", [draw_module_base()], 1, 1, None))
    return states
