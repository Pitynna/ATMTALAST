"""Generate icons/obj/hydroponics/prehistoric.dmi.

Growth stages and seed packets of the seven reconstituted prehistoric plants.
Each plant reuses the outline of a project plant with a comparable silhouette
and is recoloured into its own alien palette, so the sprites keep the exact
size, shading and line weight of the existing hydroponics art.

Run from the repository root:  python tools/xenoarch/prehistoric_sprites.py
"""
import colorsys
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from dmi import ROOT, read_states, write_dmi  # noqa: E402

HYDRO = "icons/obj/hydroponics/"

# species: (source file, source species, grow stages to use, foliage hsv, fruit hsv)
# hsv tuples: (hue degrees, saturation multiplier, value multiplier)
PLANTS = {
    "telriis": ("growing.dmi", "grass", 2, (158, 0.75, 0.70), (150, 0.8, 0.8)),
    "thaadra": ("growing_mushrooms.dmi", "reishi", 4, (275, 0.35, 1.25), (300, 0.45, 1.30)),
    "jurlmah": ("growing.dmi", "sugarcane", 3, (186, 0.90, 0.95), (172, 1.00, 1.15)),
    "amauri": ("growing_vegetables.dmi", "eggplant", 6, (140, 0.65, 0.80), (268, 0.90, 0.70)),
    "gelthi": ("growing_fruits.dmi", "berry", 6, (28, 0.70, 0.85), (8, 1.00, 1.10)),
    "vale": ("growing_vegetables.dmi", "aloe", 5, (330, 0.40, 1.15), (320, 0.50, 1.20)),
    "surik": ("growing_vegetables.dmi", "cabbage", 1, (222, 0.85, 0.95), (232, 1.00, 1.05)),
}

FALLBACK_DEAD = ("growing_fruits.dmi", "berry-dead")


def is_foliage(h, s):
    degrees = h * 360
    return s > 0.12 and 55 <= degrees <= 175


def recolour(image, foliage, fruit):
    out = image.copy()
    pixels = out.load()
    for y in range(out.height):
        for x in range(out.width):
            r, g, b, a = pixels[x, y]
            if not a:
                continue
            h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
            degrees = h * 360
            if is_foliage(h, s):
                target = foliage
            elif s > 0.25 and not (18 <= degrees <= 50 and v < 0.55):
                # Saturated non-green pixels are fruit, flowers and caps.
                # Dark browns (stalks, soil) keep their colour.
                target = fruit
            else:
                continue
            nh = (target[0] % 360) / 360
            ns = min(1.0, s * target[1] + (0.08 if target[1] < 0.5 else 0))
            nv = min(1.0, v * target[2])
            nr, ng, nb = colorsys.hsv_to_rgb(nh, ns, nv)
            pixels[x, y] = (round(nr * 255), round(ng * 255), round(nb * 255), a)
    return out


def main():
    states = []
    cache = {}

    def sheet(name):
        if name not in cache:
            cache[name] = read_states(HYDRO + name)[0]
        return cache[name]

    seeds = sheet("seeds.dmi")
    for species, (source, base, stages, foliage, fruit) in PLANTS.items():
        src = sheet(source)
        for stage in range(1, stages + 1):
            image = src[f"{base}-grow{stage}"]["images"][0]
            states.append((f"{species}-grow{stage}", [recolour(image, foliage, fruit)], 1, 1, None))
        harvest = src.get(f"{base}-harvest") or src[f"{base}-grow{stages}"]
        states.append((f"{species}-harvest", [recolour(harvest["images"][0], foliage, fruit)], 1, 1, None))
        dead = src.get(f"{base}-dead") or sheet(FALLBACK_DEAD[0])[FALLBACK_DEAD[1]]
        withered = recolour(dead["images"][0], (foliage[0], 0.3, 0.75), (fruit[0], 0.3, 0.75))
        states.append((f"{species}-dead", [withered], 1, 1, None))
        packet = recolour(seeds["seed-x"]["images"][0], (foliage[0], 0.9, 1.0), (fruit[0], 1.0, 1.0))
        states.append((f"seed-{species}", [packet], 1, 1, None))
    target = ROOT / HYDRO / "prehistoric.dmi"
    write_dmi(target, states)
    print(f"wrote {target} with {len(states)} states")


if __name__ == "__main__":
    main()
