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
        if res: out[f'{x},{y}'] = res
json.dump(out, open(OUT, 'w'))
from collections import Counter
print(len(out), Counter(k for v in out.values() for k in v))
