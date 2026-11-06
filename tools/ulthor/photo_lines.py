"""Detect cable / supply / scrubber runs per tile on the 2 May 2024 Ulthor screenshot.

Photo tile (0,0) is map (23,234); the screenshot covers 190x175 tiles."""
import numpy as np, json
from PIL import Image
import sys
PHOTO = sys.argv[1] if len(sys.argv) > 1 else 'Z:/ATMTA/ULTHOR/StrongDMM-2024-05-02_23.05.10.png'
OUT = 'tools/ulthor/photo_lines.json'
P = np.asarray(Image.open(PHOTO).convert('RGB'))[:5600, :6080].astype(int)
r, g, b = P[..., 0], P[..., 1], P[..., 2]
RED = (r - np.maximum(g, b)) > 60
BLUE = (b - np.maximum(r, g)) > 40
# layer: (mask, vertical column, horizontal row)
LAY = {'cable': (RED, (15, 16), (15, 16)), 'scrub': (RED, (19, 19), (12, 12)), 'supply': (BLUE, (12, 13), (18, 19))}
# Disposal pipes: a 16 px grey tube, dark edges at offsets 8 and 23 across the tile.
PROFILE = np.array([30, 57, 67, 84, 89, 99, 115, 133, 133, 115, 99, 89, 84, 67, 57, 30])
GREY = P.mean(-1)
FLAT = (P.max(-1) - P.min(-1)) < 14


SAT = (P.max(-1) - P.min(-1)) > 40


def tube(strip, sat):
    """strip: (n, 18) grey values across a disposal tube at tile offsets 7..24.
    A row counts when both tube edges are dark and the inside is a grey tube body;
    this covers the plain tube and the darker flanges at tile edges. Pixels of
    coloured cable/pipe lines drawn over the tube are ignored."""
    g = strip.astype(float)
    g[sat] = np.nan
    with np.errstate(all='ignore'):
        left = np.nanmin(np.where(np.isnan(g[:, :2]), 0, g[:, :2]), 1)
        right = np.nanmin(np.where(np.isnan(g[:, -2:]), 0, g[:, -2:]), 1)
        body = g[:, 3:-3]
        mean = np.nanmean(body, 1)
        low = np.nanmin(body, 1)
    good = (left < 36) & (right < 36) & (mean > 38) & (mean < 150) & (low > 30) & (np.isnan(body).sum(1) < 6)
    return good.mean()


out = {}
for ty in range(175):
    for tx in range(190):
        x, y = tx + 23, 234 - ty
        res = {}
        for name, (M, vc, hr) in LAY.items():
            t = M[ty * 32:ty * 32 + 32, tx * 32:tx * 32 + 32]
            col = t[:, vc[0]:vc[1] + 1].any(1)
            row = t[hr[0]:hr[1] + 1, :].any(0)
            d = 0
            if col[0:10].mean() > 0.6: d |= 1   # north
            if col[22:32].mean() > 0.6: d |= 2  # south
            if row[22:32].mean() > 0.6: d |= 4  # east
            if row[0:10].mean() > 0.6: d |= 8   # west
            if d: res[name] = d
        G = GREY[ty * 32:ty * 32 + 32, tx * 32:tx * 32 + 32]
        Q = SAT[ty * 32:ty * 32 + 32, tx * 32:tx * 32 + 32]
        d = 0
        if tube(G[0:8, 7:25], Q[0:8, 7:25]) > 0.5: d |= 1
        if tube(G[24:32, 7:25], Q[24:32, 7:25]) > 0.5: d |= 2
        if tube(G[7:25, 24:32].T, Q[7:25, 24:32].T) > 0.5: d |= 4
        if tube(G[7:25, 0:8].T, Q[7:25, 0:8].T) > 0.5: d |= 8
        if d: res['disposal'] = d
        if res: out[f'{x},{y}'] = res
json.dump(out, open(OUT, 'w'))
from collections import Counter
print(len(out), Counter(k for v in out.values() for k in v))
