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


def draw_panel_overlay(dx=0, dy=0):
    """Open maintenance hatch with wiring; (dx, dy) shifts it onto each tier's housing."""
    img = new_image()
    rect(img, 12 + dx, 8 + dy, 19 + dx, 14 + dy, OUTLINE)
    rect(img, 13 + dx, 9 + dy, 18 + dx, 13 + dy, (0x1E, 0x22, 0x26))
    for x, color in ((14, (0xD0, 0x30, 0x30)), (15, (0x30, 0x70, 0xE0)), (16, (0xE0, 0xC0, 0x30)), (17, (0x40, 0xC0, 0x40))):
        for y in range(10, 13):
            if (x + y) % 2:
                put(img, x + dx, y + dy, color)
    # Hatch door swung open to the side.
    rect(img, 20 + dx, 8 + dy, 22 + dx, 14 + dy, OUTLINE)
    rect(img, 21 + dx, 9 + dy, 21 + dx, 13 + dy, STEEL_LIGHT)
    return img


def draw_packed_tier1(lid=None, lid_light=None):
    img = new_image()
    # Folded case.
    box(img, 4, 12, 27, 26, STEEL, STEEL_LIGHT, STEEL_DARK)
    if lid:
        rect(img, 5, 13, 26, 15, lid)
        rect(img, 5, 13, 26, 13, lid_light)
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


def draw_module_ejector():
    """Module casing with an ore chute and a yellow output arrow."""
    img = new_image()
    box(img, 8, 10, 23, 22, STEEL, STEEL_LIGHT, STEEL_DARK)
    # Chute on the right side.
    box(img, 22, 13, 27, 19, STEEL_DARK, STEEL, OUTLINE)
    rect(img, 24, 15, 26, 17, HOLE)
    # Ore chunk dropping out of the chute.
    put(img, 28, 18, (0xB0, 0x60, 0x3A))
    put(img, 29, 19, (0xB0, 0x60, 0x3A))
    put(img, 28, 19, (0x6E, 0x34, 0x20))
    # Yellow arrow on the casing pointing at the chute.
    for depth, (start, end) in enumerate(((13, 18), (14, 17), (15, 16))):
        for along in range(start, end + 1):
            put(img, 17 + depth, along, ARROW)
    rect(img, 11, 15, 16, 16, ARROW)
    # Contact strip.
    for x in range(10, 22, 2):
        put(img, x, 23, (0xC8, 0xA0, 0x40))
    return img


PIPE = (0x5E, 0x56, 0x4C)
PIPE_LIGHT = (0x84, 0x7A, 0x6C)
PIPE_DARK = (0x38, 0x33, 0x2D)
PIPE_BAND = (0xA0, 0x6A, 0x2E)
NORTH, SOUTH, EAST, WEST = 1, 2, 4, 8


def pipe_run(img, direction, start, end):
    """Tube 8px wide from `start` to `end` along the axis of `direction` (pixels measured from the edge)."""
    vertical = direction in (NORTH, SOUTH)
    for along in range(start, end + 1):
        pos = along if direction in (NORTH, WEST) else SIZE - 1 - along
        for across in range(12, 20):
            if across in (12, 19):
                color = OUTLINE
            elif across == 13:
                color = PIPE_LIGHT
            elif across == 18:
                color = PIPE_DARK
            else:
                color = PIPE
            if along % 6 == 2 and across not in (12, 19):
                color = PIPE_BAND
            x, y = (across, pos) if vertical else (pos, across)
            put(img, x, y, color)


def draw_pipe(mask):
    img = new_image()
    straight = mask in (NORTH | SOUTH, EAST | WEST)
    for direction in (NORTH, SOUTH, EAST, WEST):
        if mask & direction:
            pipe_run(img, direction, 0, 15)
    if not straight:
        # Joint housing where branches meet, or a capped end.
        box(img, 10, 10, 21, 21, PIPE, PIPE_LIGHT, PIPE_DARK)
        for x, y in ((12, 12), (19, 12), (12, 19), (19, 19)):
            put(img, x, y, STEEL_EDGE)
        rect(img, 14, 14, 17, 17, PIPE_DARK)
    return img


def draw_pipe_stub(direction):
    img = new_image()
    pipe_run(img, direction, 0, 7)
    return img


def draw_outlet(direction):
    img = new_image()
    box(img, 8, 8, 23, 23, STEEL, STEEL_LIGHT, STEEL_DARK)
    rect(img, 11, 11, 20, 20, PIPE_DARK)
    rect(img, 13, 13, 18, 18, HOLE)
    # Mouth with a yellow lip on the facing side.
    if direction == "S":
        rect(img, 11, 22, 20, 25, HOLE)
        rect(img, 10, 26, 21, 26, HAZARD)
    elif direction == "N":
        rect(img, 11, 6, 20, 9, HOLE)
        rect(img, 10, 5, 21, 5, HAZARD)
    elif direction == "E":
        rect(img, 22, 11, 25, 20, HOLE)
        rect(img, 26, 10, 26, 21, HAZARD)
    else:
        rect(img, 6, 11, 9, 20, HOLE)
        rect(img, 5, 10, 5, 21, HAZARD)
    return img


def draw_pipe_layer():
    img = new_image()
    # Grip and body.
    box(img, 6, 12, 20, 22, STEEL, STEEL_LIGHT, STEEL_DARK)
    box(img, 8, 22, 13, 28, STEEL_DARK, STEEL, OUTLINE)
    rect(img, 8, 14, 18, 14, HAZARD)
    put(img, 17, 17, LIGHT_ON)
    # Nozzle holding a short pipe piece.
    box(img, 20, 13, 26, 19, PIPE, PIPE_LIGHT, PIPE_DARK)
    rect(img, 22, 15, 24, 17, PIPE_BAND)
    return img


RAIL = (0x7C, 0x84, 0x8C)
RED = (0xA8, 0x28, 0x28)
RED_LIGHT = (0xD8, 0x48, 0x48)
RED_DARK = (0x6A, 0x16, 0x16)
COOLANT = (0x2E, 0x8C, 0x8C)
COOLANT_LIGHT = (0x5C, 0xC8, 0xC4)
COOLANT_DARK = (0x1A, 0x52, 0x52)
GLOW = (0x6E, 0xF4, 0xFF)
GLOW_DIM = (0x2C, 0x7A, 0x88)
BLUE = (0x2E, 0x5C, 0xA8)
BLUE_LIGHT = (0x5A, 0x8C, 0xD8)


def skid_plate(img, y0=18):
    box(img, 3, y0, 28, y0 + 7, STEEL, STEEL_LIGHT, STEEL_DARK)
    rect(img, 4, y0 + 8, 27, y0 + 9, STEEL_DARK)
    rect(img, 3, y0 + 8, 3, y0 + 10, OUTLINE)
    rect(img, 28, y0 + 8, 28, y0 + 10, OUTLINE)
    rect(img, 3, y0 + 10, 28, y0 + 10, OUTLINE)
    for x in range(5, 27, 3):
        put(img, x, y0 + 9, HAZARD if (x // 3) % 2 else HAZARD_DARK)


def draw_drill_tier2(direction, frame=None):
    """Guide rails on both sides, a carriage that rides up and down, a heavy drill head."""
    img = new_image()
    working = frame is not None
    skid_plate(img)
    rect(img, 12, 21, 19, 24, HOLE)
    # Rails with bolts.
    for x0 in (5, 24):
        rect(img, x0, 2, x0 + 2, 23, OUTLINE)
        rect(img, x0 + 1, 3, x0 + 1, 22, RAIL)
        for y in range(5, 22, 4):
            put(img, x0 + 1, y, STEEL_EDGE)
    box(img, 5, 1, 26, 4, STEEL, STEEL_EDGE, STEEL_DARK)
    lift = (0, 1, 2, 1)[frame] if working else 0
    # Drill head: a wide cone under the carriage.
    head_top = 14 + lift
    for row in range(8):
        y = head_top + row
        half = max(1, 4 - row // 2)
        for x in range(16 - half, 16 + half):
            spiral = (x + y + (frame or 0)) % 3
            put(img, x, y, BIT if spiral else BIT_DARK)
        put(img, 16 - half - 1, y, OUTLINE)
        put(img, 16 + half, y, OUTLINE)
    # Carriage riding on the rails.
    box(img, 8, 7 + lift, 23, 14 + lift, STEEL, STEEL_LIGHT, STEEL_DARK)
    rect(img, 9, 10 + lift, 22, 10 + lift, BLUE)
    rect(img, 9, 9 + lift, 22, 9 + lift, BLUE_LIGHT)
    rect(img, 7, 8 + lift, 7, 13 + lift, OUTLINE)
    rect(img, 24, 8 + lift, 24, 13 + lift, OUTLINE)
    # Status light.
    light = (LIGHT_ON if frame % 2 == 0 else LIGHT_ON_DIM) if working else LIGHT_OFF
    put(img, 15, 2, light)
    put(img, 16, 2, light)
    if working:
        for x, y in [((10, 21), (21, 22)), ((11, 20), (20, 20)), ((9, 22), (22, 21)), ((10, 20), (21, 21))][frame]:
            put(img, x, y, DUST)
    arrow(img, direction)
    return img


def draw_drill_tier3(direction, frame=None):
    """Compact dense casing with a red top, coolant pipes and a glowing core."""
    img = new_image()
    working = frame is not None
    # Coolant pipes along the sides.
    for x0 in (3, 27):
        rect(img, x0, 9, x0 + 1, 25, COOLANT_DARK)
        rect(img, x0, 9, x0, 25, COOLANT_LIGHT if x0 == 3 else COOLANT)
        for y in (12, 22):
            inner = range(x0 + 2, 6) if x0 == 3 else range(26, x0)
            for x in inner:
                put(img, x, y, COOLANT)
                put(img, x, y + 1, COOLANT_DARK)
    # Heavy body.
    box(img, 5, 7, 26, 26, STEEL_DARK, STEEL, OUTLINE)
    rect(img, 6, 23, 25, 25, (0x20, 0x22, 0x26))
    for y in (24,):
        for x in range(7, 25, 2):
            put(img, x, y, STEEL)
    # Red top.
    rect(img, 6, 8, 25, 11, RED)
    rect(img, 6, 8, 25, 8, RED_LIGHT)
    rect(img, 6, 11, 25, 11, RED_DARK)
    for x in (8, 23):
        put(img, x, 9, STEEL_EDGE)
    # Core window.
    box(img, 11, 13, 20, 21, (0x10, 0x14, 0x18))
    pulse = (0, 1, 2, 1)[frame] if working else 0
    core = GLOW if working else GLOW_DIM
    for y in range(15, 20):
        for x in range(13, 19):
            ring = max(abs(x - 15.5), abs(y - 17))
            if ring <= 1 + pulse * 0.5:
                put(img, x, y, core)
            elif ring <= 2 + pulse * 0.5 and working:
                put(img, x, y, GLOW_DIM)
    # Side lights.
    for x in (8, 23):
        put(img, x, 15, GLOW if working and frame % 2 == 0 else GLOW_DIM if working else LIGHT_OFF)
        put(img, x, 18, GLOW if working and frame % 2 == 1 else GLOW_DIM if working else LIGHT_OFF)
    arrow(img, direction)
    return img


BS = (0x38, 0x66, 0xFF)
BS_LIGHT = (0x9C, 0xD4, 0xFF)
BS_DARK = (0x18, 0x26, 0x96)


def bs_crystal(img, cx, cy, size, light=BS_LIGHT, base=BS, dark=BS_DARK):
    for dy in range(-size, size + 1):
        span = size - abs(dy)
        for dx in range(-span, span + 1):
            color = light if dx + dy < 0 else dark if dx + dy > 0 else base
            put(img, cx + dx, cy + dy, color)


def draw_module_transmitter():
    img = new_image()
    box(img, 8, 11, 23, 22, STEEL, STEEL_LIGHT, STEEL_DARK)
    rect(img, 9, 21, 22, 21, BS)
    bs_crystal(img, 15, 15, 3)
    # Antenna.
    rect(img, 21, 6, 21, 11, OUTLINE)
    put(img, 21, 5, BS_LIGHT)
    for x in range(10, 22, 2):
        put(img, x, 23, (0xC8, 0xA0, 0x40))
    return img


def draw_receiver(glow=0, receiving=None):
    """Bluespace pad on a heavy base. glow: 0 idle, 1..4 tuned animation; receiving: flash frame."""
    img = new_image()
    # Base.
    box(img, 3, 14, 28, 26, STEEL, STEEL_LIGHT, STEEL_DARK)
    rect(img, 4, 27, 27, 28, STEEL_DARK)
    rect(img, 3, 27, 3, 29, OUTLINE)
    rect(img, 28, 27, 28, 29, OUTLINE)
    rect(img, 3, 29, 28, 29, OUTLINE)
    for x in range(5, 27, 3):
        put(img, x, 28, BS if (x // 3) % 2 else BS_DARK)
    # Pad ring.
    for y in range(15, 26):
        for x in range(6, 26):
            d = ((x - 15.5) / 9.5) ** 2 + ((y - 20) / 5) ** 2
            if d <= 1:
                put(img, x, y, OUTLINE if d > 0.8 else (0x20, 0x26, 0x3A))
    # Emitter arms.
    for x0 in (5, 25):
        rect(img, x0, 4, x0 + 1, 15, OUTLINE)
        rect(img, x0, 5, x0, 14, STEEL_LIGHT)
        put(img, x0, 4, BS_LIGHT if glow else BS_DARK)
    rect(img, 5, 3, 26, 4, OUTLINE)
    rect(img, 6, 3, 25, 3, STEEL_EDGE)
    if glow:
        level = (0, 1, 2, 1)[(glow - 1) % 4]
        for y in range(16, 25):
            for x in range(8, 24):
                d = ((x - 15.5) / 7) ** 2 + ((y - 20) / 3.6) ** 2
                if d <= 0.3 + level * 0.15:
                    put(img, x, y, BS)
                elif d <= 0.55 + level * 0.15:
                    put(img, x, y, BS_DARK)
        put(img, 15, 20, BS_LIGHT)
        put(img, 16, 20, BS_LIGHT)
    if receiving is not None:
        # A bright column and a crystal flash as ore arrives.
        height = (12, 9, 6, 3)[receiving]
        for y in range(20 - height, 21):
            for x in range(14, 18):
                put(img, x, y, BS_LIGHT if x in (15, 16) else BS, 230)
        bs_crystal(img, 15, 20, 3 - receiving if receiving < 3 else 1, (255, 255, 255), BS_LIGHT, BS)
    return img


def drill_states():
    states = []
    idle = [draw_drill_tier1(d) for d in DIRS]
    states.append(("drill1", idle, 4, 1, None))
    working = [draw_drill_tier1(d, frame) for frame in range(4) for d in DIRS]
    states.append(("drill1_on", working, 4, 4, (2, 2, 2, 2)))
    states.append(("drill1_panel", [draw_panel_overlay()], 1, 1, None))
    states.append(("drill1_packed", [draw_packed_tier1()], 1, 1, None))
    for tier, draw, panel_offset, lid in (
        (2, draw_drill_tier2, (0, 0), (BLUE, BLUE_LIGHT)),
        (3, draw_drill_tier3, (0, 4), (RED, RED_LIGHT)),
    ):
        states.append((f"drill{tier}", [draw(d) for d in DIRS], 4, 1, None))
        states.append((f"drill{tier}_on", [draw(d, frame) for frame in range(4) for d in DIRS], 4, 4, (2, 2, 2, 2)))
        states.append((f"drill{tier}_panel", [draw_panel_overlay(*panel_offset)], 1, 1, None))
        states.append((f"drill{tier}_packed", [draw_packed_tier1(*lid)], 1, 1, None))
    states.append(("module", [draw_module_base()], 1, 1, None))
    states.append(("module_ejector", [draw_module_ejector()], 1, 1, None))
    states.append(("module_transmitter", [draw_module_transmitter()], 1, 1, None))
    states.append(("bs_receiver", [draw_receiver()], 1, 1, None))
    states.append(("bs_receiver_on", [draw_receiver(glow) for glow in range(1, 5)], 1, 4, (3, 3, 3, 3)))
    states.append(("bs_receiver_receive", [draw_receiver(1, frame) for frame in range(4)], 1, 4, (1, 1, 1, 1)))
    states.append(("bs_receiver_panel", [draw_panel_overlay(0, 7)], 1, 1, None))
    for mask in range(16):
        states.append((f"ore_pipe_{mask}", [draw_pipe(mask)], 1, 1, None))
    for direction in (NORTH, SOUTH, EAST, WEST):
        states.append((f"ore_pipe_stub_{direction}", [draw_pipe_stub(direction)], 1, 1, None))
    states.append(("ore_pipe_outlet", [draw_outlet(d) for d in DIRS], 4, 1, None))
    states.append(("pipe_layer", [draw_pipe_layer()], 1, 1, None))
    return states
