"""Compare Ulthor's contents with reference stations (Delta, Cyberiad).

Read-only. Prints/writes which object types every reference map has (map-wide
and per department) while Ulthor has none or few.
Usage: python -I tools/ulthor/compare_reference_maps.py [--json out.json]
"""
import argparse, json, re, sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools/mapmerge2"))
from dmm import DMM  # noqa: E402

MAPS = {
    "ulthor": "_maps/map_files/Ulthor/Ulthor.dmm",
    "delta": "_maps/map_files/Delta/delta.dmm",
    "cyberiad": "_maps/map_files/cyberiad/cyberiad.dmm",
}
REFS = ["delta", "cyberiad"]

# Types that are pure decor/plumbing and drown the signal.
SKIP = re.compile(r"^/obj/(effect/(decal|turf_decal|spawner/window|mapping_helpers|landmark/(lightsout))|structure/(cable|disposalpipe|lattice|grille|window|sign|chair|table|bed$)|machinery/atmospherics/pipe|item/(trash|cigbutt|stack/(rods|sheet/glass$)))")


def norm(path, depth):
    path = path.split("{", 1)[0]
    parts = path.strip("/").split("/")
    return "/" + "/".join(parts[:depth])


def dept_of(area):
    parts = area.strip("/").split("/")
    if len(parts) >= 3 and parts[1] == "station":
        return parts[2]
    if len(parts) >= 2:
        return parts[1]
    return "none"


def scan(rel, depth):
    dmm = DMM.from_file(str(ROOT / rel))
    total = Counter()
    by_dept = defaultdict(Counter)
    for coord, key in dmm.grid.items():
        atoms = dmm.dictionary[key]
        area = next((a.split("{")[0] for a in atoms if a.startswith("/area")), "/area/none")
        d = dept_of(area)
        if d in ("space",):
            pass
        for atom in atoms:
            if atom.startswith(("/area", "/turf")):
                continue
            t = norm(atom, depth)
            if SKIP.match(atom):
                continue
            total[t] += 1
            by_dept[d][t] += 1
    return total, by_dept


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--depth", type=int, default=4)
    ap.add_argument("--json")
    a = ap.parse_args()
    data = {name: scan(rel, a.depth) for name, rel in MAPS.items()}
    ul_total, ul_dept = data["ulthor"]

    missing = []
    low = []
    for t in sorted(set.intersection(*(set(data[r][0]) for r in REFS))):
        refc = [data[r][0][t] for r in REFS]
        u = ul_total.get(t, 0)
        if u == 0:
            missing.append((t, refc))
        elif u * 3 < min(refc) and min(refc) >= 6:
            low.append((t, u, refc))

    dept_missing = {}
    for d in sorted(set.intersection(*(set(data[r][1]) for r in REFS))):
        if d in ("maintenance", "hallway", "space", "none", "shuttle", "solars"):
            continue
        rows = []
        for t in sorted(set.intersection(*(set(data[r][1][d]) for r in REFS))):
            if ul_dept.get(d, {}).get(t, 0) == 0:
                rows.append((t, [data[r][1][d][t] for r in REFS], ul_total.get(t, 0)))
        dept_missing[d] = rows

    print("== Map-wide: in Delta AND Cyberiad, absent on Ulthor ==  [delta, cyberiad]")
    for t, c in missing:
        print(f"  {t:70s} {c}")
    print("\n== Map-wide: Ulthor has < 1/3 of the smaller reference ==  ulthor [delta, cyberiad]")
    for t, u, c in low:
        print(f"  {t:70s} {u} {c}")
    print("\n== Per department: in both refs' dept, absent from Ulthor's dept ==  [delta, cyberiad] ulthor-anywhere")
    for d, rows in dept_missing.items():
        print(f"-- {d}")
        for t, c, anywhere in rows:
            print(f"  {t:70s} {c} {anywhere}")
    if a.json:
        Path(a.json).write_text(json.dumps({"missing": missing, "low": low, "dept_missing": dept_missing}, indent=1, ensure_ascii=False), encoding="utf-8")


main()
