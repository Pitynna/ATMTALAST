"""Builds the icons of the asteroid ruins from the game's own human parts.

Run from the repository root:  python tools/asteroid_ruins/build_icons.py
Writes icons/mob/asteroid_ruins.dmi and icons/obj/asteroid_ruins.dmi.
"""
import os
import sys

from PIL import Image, ImageChops, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import dmi  # noqa: E402

BODY = "icons/mob/human_races/r_human.dmi"
UNIFORM = "icons/mob/clothing/uniform.dmi"
SUIT = "icons/mob/clothing/suit.dmi"
FEET = "icons/mob/clothing/feet.dmi"
TIES = "icons/mob/clothing/ties.dmi"
HAIR = "icons/mob/sprite_accessories/human/human_hair.dmi"
BEARD = "icons/mob/sprite_accessories/human/human_facial_hair.dmi"
POSTERS = "icons/obj/contraband.dmi"

BODY_PARTS = ("torso_m", "groin_m", "head_m", "l_arm", "r_arm", "l_leg", "r_leg", "l_hand", "r_hand", "l_foot", "r_foot")

_cache = {}


def frame(path, state, direction=0):
    if path not in _cache:
        _cache[path] = dmi.read(path)[2]
    return dmi.find(_cache[path], state).get(direction)


def add_colour(image, colour):
    """Hair is stored dark and coloured additively, like the game does it."""
    alpha = image.getchannel("A")
    out = ImageChops.add(image, Image.new("RGBA", image.size, colour + (0,)))
    out.putalpha(alpha)
    return out


def multiply(image, colour):
    alpha = image.getchannel("A")
    out = ImageChops.multiply(image, Image.new("RGBA", image.size, colour + (255,)))
    out.putalpha(alpha)
    return out


def person(layers, direction, skin=(255, 255, 255)):
    image = Image.new("RGBA", (32, 32))
    for part in BODY_PARTS:
        image.alpha_composite(multiply(frame(BODY, part, direction), skin))
    for path, state, colour in layers:
        layer = frame(path, state, direction)
        image.alpha_composite(add_colour(layer, colour) if colour else layer)
    return image


def lying(image, blood=False):
    out = image.rotate(90, resample=Image.NEAREST)
    shifted = Image.new("RGBA", (32, 32))
    shifted.alpha_composite(out, (0, 6))  # rest on the floor, not mid-tile
    if not blood:
        return shifted
    pool = Image.new("RGBA", (32, 32))
    draw = ImageDraw.Draw(pool)
    draw.ellipse((6, 20, 27, 30), fill=(110, 8, 8, 255))
    draw.ellipse((3, 23, 12, 29), fill=(128, 12, 12, 255))
    draw.point([(9, 22), (22, 29), (26, 22), (15, 30)], fill=(150, 20, 20, 255))
    pool.alpha_composite(multiply(shifted, (190, 180, 180)))
    return pool


RYBNIKOV = [
    (UNIFORM, "charcoal_suit_s", None),
    (FEET, "laceups", None),
    (HAIR, "father_s", (150, 150, 150)),
]
BOYARSHINOV = [
    (UNIFORM, "lawyer_black_s", None),
    (FEET, "laceups", None),
    (SUIT, "suitjacket_black", None),
    (TIES, "redtie", None),
    (HAIR, "balding_s", (190, 190, 190)),
    (BEARD, "fullbeard_s", (190, 190, 190)),
]
# Saddam is the figure from the "Saddam's hiding place" diagram: a featureless, solid red human shape.
SADDAM_RED = (192, 0, 0, 255)
SADDAM_DEAD_RED = (96, 0, 0, 255)


def silhouette(colour):
    body = person([], 0)
    flat = Image.new("RGBA", (32, 32))
    flat.paste(Image.new("RGBA", (32, 32), colour), mask=body.getchannel("A").point(lambda value: 255 if value else 0))
    return flat


def boyarshinov_roof(frame_index):
    """The 'roof over the head' gesture from the broadcast."""
    image = person(BOYARSHINOV, 0)
    draw = ImageDraw.Draw(image)
    sleeve = (24, 24, 28, 255)
    hand = (236, 190, 160, 255)
    if frame_index == 0:
        return image
    # hide the hanging arms, raise them to the head instead
    for x in (9, 10, 21, 22):
        for y in range(15, 22):
            if image.getpixel((x, y))[3] and x in (9, 22):
                image.putpixel((x, y), (0, 0, 0, 0))
    draw.line((10, 13, 11, 6), fill=sleeve)
    draw.line((21, 13, 20, 6), fill=sleeve)
    draw.line((12, 4, 14, 3), fill=hand)
    draw.line((19, 4, 17, 3), fill=hand)
    draw.point([(11, 5), (20, 5)], fill=hand)
    return image


def build_mobs():
    states = []
    for name, layers in (("rybnikov", RYBNIKOV), ("boyarshinov", BOYARSHINOV)):
        alive = dmi.State(name, dirs=4)
        alive.images = [person(layers, direction) for direction in range(4)]
        dead = dmi.State(f"{name}_dead")
        dead.images = [lying(person(layers, 0), blood=True)]
        states += [alive, dead]
    roof = dmi.State("boyarshinov_roof", frames=4, delay=[2, 6, 2, 6])
    roof.images = [boyarshinov_roof(index % 2) for index in (0, 1, 0, 1)]
    states.append(roof)
    saddam = dmi.State("saddam")
    saddam.images = [lying(silhouette(SADDAM_RED))]
    saddam_dead = dmi.State("saddam_dead")
    saddam_dead.images = [lying(silhouette(SADDAM_DEAD_RED))]
    states += [saddam, saddam_dead]
    dmi.write("icons/mob/asteroid_ruins.dmi", 32, 32, states)


def draw_poster():
    """The Ancient Periodic System of the Schizos, boiled down to 32x32."""
    image = Image.new("RGBA", (32, 32))
    draw = ImageDraw.Draw(image)
    draw.rectangle((5, 2, 26, 29), fill=(44, 40, 52, 255))            # frame
    draw.rectangle((6, 3, 25, 28), fill=(214, 204, 232, 255))         # lilac paper
    draw.ellipse((7, 6, 24, 23), fill=(232, 222, 244, 255), outline=(170, 150, 200, 255))  # the "allrod" sphere
    draw.ellipse((8, 11, 15, 18), outline=(150, 120, 200, 255))
    draw.ellipse((16, 11, 23, 18), outline=(150, 120, 200, 255))
    beads = ((208, 32, 32), (230, 130, 20), (232, 212, 40), (60, 170, 60), (40, 170, 210), (50, 80, 200), (140, 60, 190))
    for index in range(14):                                           # the chain of electro-atoms
        draw.point((9 + index, 14 + (index % 2)), fill=beads[index % 7] + (255,))
        draw.point((9 + index, 15 - (index % 2)), fill=beads[(index + 3) % 7] + (255,))
    for index, colour in enumerate(beads):                            # the legend of rods
        draw.line((7, 4 + index * 2, 8, 4 + index * 2), fill=colour + (255,))
    ink = (40, 30, 60, 255)
    draw.point([(14, 8), (15, 7), (16, 8), (15, 9), (14, 10), (15, 10), (16, 10), (18, 7)], fill=ink)   # 2^n
    draw.line((13, 19, 17, 19), fill=ink)                             # 1 / 2^n
    draw.point([(15, 17), (15, 18), (14, 21), (15, 20), (16, 21), (15, 22), (14, 22), (16, 22)], fill=ink)
    draw.rectangle((20, 22, 24, 27), fill=(120, 120, 124, 255))       # the author's portrait
    draw.rectangle((21, 23, 23, 24), fill=(206, 206, 206, 255))
    draw.point([(21, 25), (22, 25), (23, 25)], fill=(226, 190, 164, 255))
    draw.line((21, 27, 23, 27), fill=(50, 50, 56, 255))
    draw.line((8, 26, 17, 26), fill=ink)                              # "ancient periodic system"
    draw.line((9, 24, 16, 24), fill=(96, 80, 130, 255))
    draw.ellipse((6, 24, 8, 26), fill=(120, 40, 200, 255))            # the two glowing models
    return image


def build_objects():
    source = _cache.get(POSTERS) or dmi.read(POSTERS)[2]
    poster = dmi.State("schizo_poster")
    poster.images = [draw_poster()]
    rolled = dmi.State("rolled_schizo_poster")
    rolled_image = dmi.find(source, "rolled_poster").get().copy()
    pixels = rolled_image.load()
    for x in range(32):
        for y in range(32):
            red, green, blue, alpha = pixels[x, y]
            if alpha and abs(red - green) < 24 and abs(green - blue) < 24:   # grey paper turns lilac
                pixels[x, y] = (min(255, red + 40), green + 10 if green < 245 else green, min(255, blue + 70), alpha)
    rolled.images = [rolled_image]
    setting_source = dmi.find(source, "poster_being_set")
    setting = dmi.State("poster_being_set", dirs=setting_source.dirs, frames=setting_source.frames, delay=setting_source.delay, extra=setting_source.extra)
    setting.images = list(setting_source.images)
    dmi.write("icons/obj/asteroid_ruins.dmi", 32, 32, [poster, rolled, setting])


def preview(path):
    sheet = Image.new("RGBA", (34 * 12, 34), (90, 90, 110, 255))
    index = 0
    for icon in ("icons/mob/asteroid_ruins.dmi", "icons/obj/asteroid_ruins.dmi"):
        for state in dmi.read(icon)[2]:
            for image in (state.images[:1] if state.name != "boyarshinov_roof" else state.images[:2]):
                sheet.alpha_composite(image, (index * 34 + 1, 1))
                index += 1
    sheet.resize((sheet.width * 6, sheet.height * 6), Image.NEAREST).save(path)


if __name__ == "__main__":
    build_mobs()
    build_objects()
    if len(sys.argv) > 1:
        preview(sys.argv[1])
