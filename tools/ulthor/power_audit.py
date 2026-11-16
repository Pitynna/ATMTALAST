"""Audit Ulthor's power cabling without modifying the map.

Layered TG-style cables join any cable of the same layer on an adjacent tile,
so a powernet is simply a 4-connected component of cable tiles per layer.
Reports: networks, APCs and power machines per network, cables on walls,
in space, and under windows/grilles. Optionally renders a picture.
"""
import argparse
import json
import sys
from collections import deque
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools/mapmerge2"))
from dmm import DMM  # noqa: E402

MAP = ROOT / "_maps/map_files/Ulthor/Ulthor.dmm"


def path(atom):
    return atom.split("{", 1)[0]


def cable_layer(atom):
    p = path(atom)
    if not p.startswith("/obj/structure/cable"):
        return None
    if p.startswith("/obj/structure/cable/layer1"):
        return 1
    if p.startswith("/obj/structure/cable/layer3"):
        return 3
    return 2


def classify(tile):
    types = [path(a) for a in tile]
    turf = [t for t in types if t.startswith("/turf")][-1]
    if turf.startswith("/turf/space"):
        return "space"
    if "/wall" in turf or turf.startswith("/turf/simulated/mineral"):
        return "wall"
    # Full-tile windows only; thin directional panes leave the tile usable.
    if any(t.startswith(("/obj/effect/spawner/window", "/obj/structure/grille", "/obj/structure/window/full")) for t in types):
        return "window"
    return "floor"


def load(map_path=MAP):
    m = DMM.from_file(map_path)
    return m, {tuple(p): m.get_tile(p) for p in m.grid}


def networks(tiles, layer=2):
    cab = {p for p, t in tiles.items() if any(cable_layer(a) == layer for a in t)}
    smes = {p for p, t in tiles.items() if any(path(a).startswith("/obj/machinery/power/smes") for a in t)}
    term = {p for p, t in tiles.items() if any(path(a).startswith("/obj/machinery/power/terminal") for a in t)}

    def linked(a, b):  # a SMES cable never links to its terminal's cable
        return not ((a in smes and b in term) or (a in term and b in smes))
    nets, seen = [], set()
    for s in sorted(cab):
        if s in seen:
            continue
        comp, q = {s}, deque([s])
        seen.add(s)
        while q:
            x, y, z = q.popleft()
            for n in ((x+1, y, z), (x-1, y, z), (x, y+1, z), (x, y-1, z)):
                if n in cab and n not in seen and linked((x, y, z), n):
                    seen.add(n); comp.add(n); q.append(n)
        nets.append(comp)
    nets.sort(key=len, reverse=True)
    return nets


def audit(tiles):
    nets = networks(tiles)
    owner = {p: i for i, n in enumerate(nets) for p in n}
    gen_nets = networks(tiles, 1)
    gen_owner = {p: i for i, n in enumerate(gen_nets) for p in n}
    machines = []
    for p, t in tiles.items():
        for a in t:
            typ = path(a)
            if typ.startswith("/obj/machinery/power/") and not typ.startswith(("/obj/machinery/power/solar_control",)):
                machines.append((p, typ, owner.get(p), gen_owner.get(p)))
    apcs = [(p, owner.get(p), path(tiles[p][-1])) for p, typ, _, _ in machines if typ.startswith("/obj/machinery/power/apc")]
    bad = {"space": [], "wall": [], "window": []}
    for p, t in tiles.items():
        if any(cable_layer(a) for a in t):
            c = classify(t)
            if c in bad:
                bad[c].append(p)
    return nets, owner, machines, apcs, bad, gen_nets


def render(tiles, nets, apcs, out, main=0):
    from PIL import Image, ImageDraw
    s = 6
    xs = [p[0] for p in tiles]; ys = [p[1] for p in tiles]
    W, H = max(xs), max(ys)
    im = Image.new("RGB", (W*s, H*s), "#000010")
    d = ImageDraw.Draw(im)
    col = {"space": "#000010", "wall": "#6a6a6a", "window": "#3a5a7a", "floor": "#262626"}
    for (x, y, z), t in tiles.items():
        d.rectangle(((x-1)*s, (H-y)*s, x*s-1, (H-y+1)*s-1), fill=col[classify(t)])
    for i, n in enumerate(nets):
        c = "#ff2020" if i == main else ((i*83+80) % 156+100, (i*137+10) % 156+100, 40)
        for x, y, z in n:
            d.rectangle(((x-1)*s+2, (H-y)*s+2, x*s-3, (H-y+1)*s-3), fill=c)
    for (x, y, z), net, area in apcs:
        c = "#00ff60" if net == main else "#ffff00"
        d.rectangle(((x-1)*s, (H-y)*s, x*s-1, (H-y+1)*s-1), outline=c, width=2)
    im.save(out)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--map", type=Path, default=MAP)
    ap.add_argument("--png", type=Path)
    ap.add_argument("--json", type=Path)
    a = ap.parse_args()
    _, tiles = load(a.map)
    nets, owner, machines, apcs, bad, gen_nets = audit(tiles)
    # The main grid is the net holding the most SMES units.
    smes_count = [0]*len(nets)
    for p, typ, net, _ in machines:
        if typ.startswith("/obj/machinery/power/smes") and net is not None:
            smes_count[net] += 1
    main_net = max(range(len(nets)), key=lambda i: (smes_count[i], len(nets[i]))) if nets else None
    off = [(p, net, area) for p, net, area in apcs if net != main_net]
    print(f"cable tiles: {sum(map(len, nets))}, networks: {len(nets)}, main net #{main_net} ({len(nets[main_net])} tiles, {smes_count[main_net]} SMES)")
    print(f"APCs: {len(apcs)}, not on main net: {len(off)}")
    for p, net, area in sorted(off):
        print("  off-grid APC", p, area, "net", net, "size", len(nets[net]) if net is not None else 0)
    for k, v in bad.items():
        print(f"cables on {k}: {len(v)}")
    print(f"generation (layer 1) nets: {len(gen_nets)}")
    for i, n in enumerate(gen_nets):
        kinds = sorted({typ.rsplit("/", 1)[-1] for p, typ, _, g in machines if g == i})
        print(f"  gen net {i}: {len(n)} tiles; {', '.join(kinds)}")
    for p, typ, net, g in sorted(machines):
        if not typ.startswith(("/obj/machinery/power/apc", "/obj/machinery/power/solar", "/obj/machinery/power/tracker")):
            print("  machine", p, typ, "grid" if net == main_net else f"net {net}", "" if g is None else f"gen {g}")
    if a.png:
        render(tiles, nets, apcs, a.png, main_net)
    if a.json:
        a.json.write_text(json.dumps({"networks": len(nets), "main": main_net, "off_grid_apcs": [[list(p), area] for p, _, area in off], **{f"cable_on_{k}": [list(p) for p in v] for k, v in bad.items()}}, indent=1) + "\n", encoding="utf-8")
    return 1 if off or any(bad.values()) else 0


if __name__ == "__main__":
    sys.exit(main())
