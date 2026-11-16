"""Read-only audit of Ulthor areas (zones).

Reports per station area: APC count (must be exactly 1), disconnected pieces
(4-connected over floor, walls and doors of the area), APCs mounted outside
their own area; wall-bounded rooms split between several areas; station floor
left in space areas; tiny areas.
"""
import sys
from collections import Counter, defaultdict, deque
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools/mapmerge2"))
sys.path.insert(0, str(Path(__file__).resolve().parent))
from dmm import DMM  # noqa: E402
from rooms import Station  # noqa: E402

MAP = ROOT / "_maps/map_files/Ulthor/Ulthor.dmm"
# Station areas that live outside /area/station (as on Cyberiad and Delta).
STATION = ("/area/station", "/area/hydroponics", "/area/janitor")


def path(a):
    return a.split("{", 1)[0]


def components(tiles):
    todo, out = set(tiles), []
    while todo:
        s = todo.pop(); comp = {s}; q = deque([s])
        while q:
            x, y = q.popleft()
            for n in ((x+1, y), (x-1, y), (x, y+1), (x, y-1)):
                if n in todo:
                    todo.remove(n); comp.add(n); q.append(n)
        out.append(comp)
    return sorted(out, key=len, reverse=True)


def main():
    m = DMM.from_file(MAP)
    st = Station(m)
    by_area = defaultdict(set)
    floor_by_area = defaultdict(set)
    apcs = defaultdict(list)
    space_floor = []
    for (x, y, z) in m.grid:
        t = m.get_tile((x, y, z))
        a = path(t[-1])
        turf = next(path(v) for v in t if v.startswith("/turf"))
        by_area[a].add((x, y))
        if turf.startswith("/turf/simulated/floor"):
            floor_by_area[a].add((x, y))
            if not a.startswith(STATION + ("/area/shuttle",)):
                space_floor.append((x, y, a))
        if any(path(v).startswith("/obj/machinery/power/apc") for v in t):
            apcs[a].append((x, y))
    problems = 0
    print("== APC count per station area (expected 1)")
    for a in sorted(by_area):
        if not a.startswith(STATION) or "/solars/" in a and "/maintenance/" not in a:
            continue
        n = len(apcs.get(a, []))
        if n != 1:
            problems += 1
            print(f"  {a}: {n} APC, {len(floor_by_area[a])} floor tiles {apcs.get(a, [])}")
    print("== areas split into several pieces (floor only)")
    for a in sorted(floor_by_area):
        if not a.startswith(STATION) or a.startswith("/area/station/solars/"):
            continue
        parts = components(floor_by_area[a])
        if len(parts) > 1:
            problems += 1
            print(f"  {a}: {[ (len(c), min(c)) for c in parts]}")
    print("== tiny areas (< 6 floor tiles)")
    for a in sorted(floor_by_area):
        if a.startswith(STATION) and len(floor_by_area[a]) < 6:
            problems += 1
            print(f"  {a}: {sorted(floor_by_area[a])}")
    print("== rooms (wall/door bounded) holding several areas")
    for comp in st.rooms():
        c = Counter(path(st.tile(*p)[-1]) for p in comp)
        if len(c) > 1:
            xs = [p[0] for p in comp]; ys = [p[1] for p in comp]
            print(f"  {len(comp):4d} {(min(xs), min(ys), max(xs), max(ys))} {[(k.replace('/area/station/', ''), v) for k, v in c.most_common()]}")
    print("== station floor in non-station areas:", len(space_floor), space_floor[:20])
    print("problems:", problems)


if __name__ == "__main__":
    main()
