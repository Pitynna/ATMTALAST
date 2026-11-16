"""Zone Ulthor's empty plating halls as maintenance (user decision 2026-11-16).

Three wall-bounded plating halls with no furniture had been given to security
areas. The hall by the departures checkpoint joins the engineering
maintenance next to it; the other two get their own maintenance areas, each
with an APC on a free wall and a cable branch to the grid. Incremental edit;
refuses to run on a map with uncommitted edits.
"""
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools/mapmerge2"))
sys.path.insert(0, str(Path(__file__).resolve().parent))
from rooms import Station  # noqa: E402
import rewire_power as R  # noqa: E402

S = "/area/station/"
# (a tile of the hall, area for the whole hall, needs its own APC)
HALLS = [
    ((100, 115, 1), S + "maintenance/ulthor_south_passage", True),
    ((152, 112, 1), S + "maintenance/ulthor_security_passage", True),
    ((170, 120, 1), S + "maintenance/ulthor_engineering_passage", False),
]
APC = {8: "/obj/machinery/power/apc{dir = 8;pixel_x = -24;pixel_y = 0}",
       4: "/obj/machinery/power/apc{dir = 4;pixel_x = 24;pixel_y = 0}",
       1: "/obj/machinery/power/apc{dir = 1;pixel_y = 24}",
       2: "/obj/machinery/power/apc{dir = 2;pixel_y = -24}"}
WALL_DIRS = ((8, -1, 0), (4, 1, 0), (1, 0, 1), (2, 0, -1))


def main():
    if subprocess.run(["git", "diff", "--quiet", "--", str(R.MAP)], cwd=ROOT).returncode:
        sys.exit("Ulthor.dmm has uncommitted edits - commit them first.")
    M = R.Map()
    st = Station(M.m)
    rooms = {p: comp for comp in st.rooms() for p in comp}
    has = lambda p, pre: any(R.path(a).startswith(pre) for a in M.t[p])
    cable2 = {p for p in M.t if any(R.cable_layer(a) == 2 for a in M.t[p])}
    cable1 = {p for p in M.t if any(R.cable_layer(a) == 1 for a in M.t[p])}
    changed = set()
    for seed, area, own_apc in HALLS:
        hall = [(x, y, 1) for x, y in rooms[seed[:2]]]
        # Doorways (one tile between doors) along the hall edge come along.
        for p in hall:
            M.t[p][-1] = area
        changed |= set(hall)
        if not own_apc:
            continue
        # APC: an empty hall tile against a wall, cheapest to wire to the grid.
        best = None
        for p in hall:
            if any(a.startswith("/obj") for a in M.t[p]):
                continue
            for d, dx, dy in WALL_DIRS:
                w = (p[0] + dx, p[1] + dy, 1)
                if R.classify(M.t[w]) != "wall":
                    continue
                cost = lambda q: None if (q in cable1 or not R.walkable(M, q) or
                                          (has(q, "/obj/machinery/power/") and q != p)) else \
                    (1.0 if "/maintenance" in M.area(q) or "/hallway" in M.area(q) else 4.0)
                path = R.route(M, {p}, lambda q: q in cable2, cost, set())
                if path and (best is None or len(path) < len(best[2])):
                    best = (p, d, path)
                break
        p, d, path = best
        M.t[p].insert(0, APC[d])
        for q in path:
            if q not in cable2:
                M.t[q].insert(0, R.CABLE)
        changed |= set(path)
        print(area, "APC", p, "cable", len(path) - 1, "tiles")
    for p in changed:
        M.m.set_tile(p, tuple(M.t[p]))
    used = set(M.m.grid.values())
    for k in [k for k in M.m.dictionary if k not in used]:
        del M.m.dictionary[k]
    M.m.to_file(str(R.MAP))


if __name__ == "__main__":
    main()
