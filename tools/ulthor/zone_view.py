"""Render an Ulthor region with zones tinted on top, like SDMM's area layer.
python zone_view.py out.png x0 y0 x1 y1
Each area gets a colour and a short label; borders between areas are drawn white."""
import hashlib
import sys
from pathlib import Path

from PIL import Image, ImageDraw

sys.path.insert(0, str(Path(__file__).resolve().parent))
import render_clean as RC  # noqa: E402
import render_layout as R  # noqa: E402

SCALE, PAD = 32, 36


def colour(a):
    h = hashlib.md5(a.encode()).digest()
    return (h[0], h[1], h[2], 90)


def main():
    out = sys.argv[1]
    x0, y0, x1, y1 = map(int, sys.argv[2:6])
    mp = R.ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
    RC.render(mp, (x0, y0, x1, y1), out)
    _, t = R.load(mp)
    im = Image.open(out).convert('RGBA')
    ov = Image.new('RGBA', im.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)

    def ar(x, y):
        return next((a.split('{')[0] for a in t.get((x, y, 1), ()) if a.startswith('/area')), '')

    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            a = ar(x, y)
            px, py = (x - x0) * SCALE + PAD, (y1 - y) * SCALE + PAD
            if not a.startswith('/area/space'):
                d.rectangle([px, py, px + SCALE - 1, py + SCALE - 1], fill=colour(a))
                lab = a.rsplit('/', 1)[-1].replace('ulthor_', '')[:8]
                d.text((px + 1, py + 11), lab, fill=(255, 255, 255, 200))
            if x < x1 and ar(x + 1, y) != a:
                d.line([px + SCALE - 1, py, px + SCALE - 1, py + SCALE], fill=(255, 255, 255, 255), width=2)
            if y > y0 and ar(x, y - 1) != a:
                d.line([px, py + SCALE - 1, px + SCALE, py + SCALE - 1], fill=(255, 255, 255, 255), width=2)
    Image.alpha_composite(im, ov).convert('RGB').save(out)


if __name__ == '__main__':
    main()
