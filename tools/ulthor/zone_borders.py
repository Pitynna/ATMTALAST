"""Zone borders that run across open floor (read-only).

A border between two station areas is fine on a wall, window, door/airlock or
a one-tile doorway. Two neighbouring open floor tiles in different areas with
none of that between them mark a border drawn through the middle of a room or
corridor (APC-distance flood fill made such staircases). Grouped by area pair,
with the bounding box of the offending tiles.

python zone_borders.py            - report
python zone_borders.py ascii x0 y0 x1 y1  - area letters over a region
"""
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
sys.path.insert(0, str(Path(__file__).resolve().parent))
from dmm import DMM  # noqa: E402
from rooms import Station, MAP, area, turf, is_wall, is_boundary, is_floor  # noqa: E402

STATION = ('/area/station', '/area/hydroponics', '/area/janitor')


def p(a):
    return a.split('{', 1)[0]


def open_floor(st, x, y):
    t = st.tile(x, y)
    return is_floor(t) and not is_boundary(t) and not is_wall(t) and p(area(t)).startswith(STATION)


def doorway(st, x, y):
    """One-tile gap in a wall line."""
    solid = lambda a, b: not open_floor(st, a, b)
    return (solid(x - 1, y) and solid(x + 1, y)) or (solid(x, y - 1) and solid(x, y + 1))


def borders(st):
    out = defaultdict(set)
    for y in range(1, st.Y + 1):
        for x in range(1, st.X + 1):
            if not open_floor(st, x, y):
                continue
            a = p(area(st.tile(x, y)))
            for dx, dy in ((1, 0), (0, 1)):
                nx, ny = x + dx, y + dy
                if not open_floor(st, nx, ny):
                    continue
                b = p(area(st.tile(nx, ny)))
                if a == b or doorway(st, x, y) or doorway(st, nx, ny):
                    continue
                out[tuple(sorted((a, b)))] |= {(x, y), (nx, ny)}
    return out


def short(a):
    return a.replace('/area/station/', '')


def main():
    st = Station(DMM.from_file(str(MAP)))
    if len(sys.argv) > 1 and sys.argv[1] == 'ascii':
        x0, y0, x1, y1 = map(int, sys.argv[2:6])
        letters = {}
        for y in range(y1, y0 - 1, -1):
            row = ''
            for x in range(x0, x1 + 1):
                t = st.tile(x, y)
                a = p(area(t))
                if a not in letters:
                    letters[a] = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'[len(letters) % 62]
                ch = letters[a]
                if is_wall(t):
                    ch = '#' if not a.startswith(STATION) else ch.upper() if ch.islower() else '#'
                elif is_boundary(t):
                    ch = '+'
                elif not is_floor(t):
                    ch = ' '
                row += ch
            print(f'{y:4} {row}')
        for a, c in letters.items():
            print(c, short(a))
        return
    res = borders(st)
    total = 0
    for pair, tiles in sorted(res.items(), key=lambda kv: -len(kv[1])):
        xs = [t[0] for t in tiles]
        ys = [t[1] for t in tiles]
        total += len(tiles)
        print(f'{len(tiles):4}  {short(pair[0])} | {short(pair[1])}  x{min(xs)}-{max(xs)} y{min(ys)}-{max(ys)}')
    print('pairs', len(res), 'tiles', total)


if __name__ == '__main__':
    main()
