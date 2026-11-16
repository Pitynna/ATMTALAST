"""Re-lay Ulthor's power cabling as an incremental edit of the current map.

Layout:
* main ring along the corridors (north corridor, east engineering passage,
  south corridor, west passage), routed through fixed waypoints;
* every APC, SMES output and grid consumer is branched off the grid by the
  cheapest path, preferring corridors/maintenance, then the APC's own room;
  other rooms are expensive, so branches enter departments by their doors;
* every SMES input (terminal) gets its own separate net with its generators
  (solar arrays + console, turbine, PACMAN); tiles next to an input net are
  forbidden for the grid, because layered cables join any adjacent cable.

Cables never go on walls, windows/grilles, space without a catwalk (solar
arrays only), shuttles, or the reserved engine room. Only cable atoms are
changed; everything else on the map is preserved. Refuses to run when the map
has uncommitted changes (the user may be editing it in StrongDMM).
"""
import hashlib
import heapq
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools/mapmerge2"))
sys.path.insert(0, str(Path(__file__).resolve().parent))
from dmm import DMM  # noqa: E402
from power_audit import path, cable_layer, classify  # noqa: E402

MAP = ROOT / "_maps/map_files/Ulthor/Ulthor.dmm"
CABLE = "/obj/structure/cable"
CABLE_IN = "/obj/structure/cable/layer1"
STAMP = ROOT / "docs/ulthor_power/last_output.sha256"
# Future engine room (user, 2026-11-16): keep free of cables.
RESERVED = {(x, y, 1) for x in range(145, 150) for y in range(130, 142)}
# Ring waypoints, walked in order and closed back to the first one.
RING = [(76, 169), (120, 169), (158, 169), (157, 130), (160, 110), (120, 106),
        (86, 106), (84, 128), (98, 145)]
DIRS = ((1, 0), (-1, 0), (0, 1), (0, -1))
# The AI core SMES sits in a wall niche whose only open side is its own
# terminal, so its output can never reach a cable; it is charged from the grid.
GRID_FED_SMES = {(140, 149, 1)}
# Consumers outside APC control that were powered before (AI core emitter).
GRID_CONSUMERS = {(140, 155, 1)}
# Map fixes needed for wiring (applied before routing).
DEPARTURES_MAINT = "/area/station/maintenance/ulthor_departures_passage"
SOLAR_ROOM = "/area/station/maintenance/solars/starboard"
APC_WEST = "/obj/machinery/power/apc{dir = 8;pixel_x = -24;pixel_y = 0}"
# APCs that were placed inside full-tile windows: old tile -> new tile.
APC_MOVES = {(116, 128, 1): (119, 126, 1), (124, 108, 1): (124, 109, 1)}


def apply_map_fixes(M):
    """The plating hall by departures was sealed and zoned as the solar SMES
    room (no door even in the original map). It is the departures maintenance
    with the starboard solar substation (x171-173, y93-95) inside it: rezone
    it, give it an APC and a maintenance door from the departures corridor."""
    changed = set()
    for p in [q for q in M.t if M.area(q) == SOLAR_ROOM]:
        x, y, _ = p
        if (y >= 96 and p != (172, 96, 1)) or (x <= 169 and y >= 93):
            M.t[p][-1] = DEPARTURES_MAINT
            changed.add(p)
    door = (162, 97, 1)
    M.t[door] = ["/obj/machinery/door/airlock/maintenance{req_access = list(12);check_one_access = 0}",
                 "/turf/simulated/floor/plating", DEPARTURES_MAINT]
    apc = (164, 100, 1)
    M.t[apc].insert(0, APC_WEST)
    changed |= {door, apc}
    for old, new in APC_MOVES.items():
        atom = next(a for a in M.t[old] if path(a).startswith("/obj/machinery/power/apc"))
        M.t[old].remove(atom)
        M.t[new].insert(0, APC_WEST)
        changed |= {old, new}
    return changed


class Map:
    def __init__(self):
        self.m = DMM.from_file(MAP)
        self.t = {tuple(p): list(self.m.get_tile(p)) for p in self.m.grid}

    def types(self, p):
        return [path(a) for a in self.t.get(p, ())]

    def area(self, p):
        return path(self.t[p][-1])

    def has(self, p, prefix):
        return any(x.startswith(prefix) for x in self.types(p))

    def find(self, prefix):
        return sorted(p for p in self.t if self.has(p, prefix))


def neighbours(p):
    x, y, z = p
    return [(x+dx, y+dy, z) for dx, dy in DIRS]


def walkable(M, p, allow_space=False):
    if p not in M.t or p in RESERVED:
        return False
    tile = M.t[p]
    kind = classify(tile)
    area = M.area(p)
    if kind == "space":
        return allow_space and area.startswith(("/area/station/solars", "/area/station/maintenance/solars")) \
            and M.has(p, "/obj/structure/lattice")
    if kind != "floor" or not area.startswith("/area/station"):
        return False
    return True


def route(M, sources, goal_test, cost, forbid, max_cost=10**9):
    """Dijkstra with a turn penalty; returns the path from a source to a goal."""
    heap, best = [], {}
    for s in sources:
        heapq.heappush(heap, (0.0, s, None, None))
        best[(s, None)] = 0.0
    prev = {}
    while heap:
        c, p, d, parent = heapq.heappop(heap)
        if best.get((p, d), 1e18) < c:
            continue
        if goal_test(p) and parent is not None or (goal_test(p) and p in sources):
            out = [p]
            key = (p, d)
            while key in prev:
                key = prev[key]
                out.append(key[0])
            return out[::-1]
        for i, n in enumerate(neighbours(p)):
            if n in forbid:
                continue
            step = cost(n)
            if step is None:
                continue
            nc = c + step + (0.35 if d is not None and d != i else 0)
            if nc > max_cost:
                continue
            if nc < best.get((n, i), 1e18):
                best[(n, i)] = nc
                prev[(n, i)] = (p, d)
                heapq.heappush(heap, (nc, n, i, p))
    return None


def main():
    # Re-runs start from HEAD, but only over our own previous output: any
    # other uncommitted edit (StrongDMM) aborts instead of being overwritten.
    if subprocess.run(["git", "diff", "--quiet", "--", str(MAP)], cwd=ROOT).returncode:
        mine = STAMP.is_file() and STAMP.read_text().strip() == hashlib.sha256(MAP.read_bytes()).hexdigest()
        if not mine:
            sys.exit("Ulthor.dmm has uncommitted edits (StrongDMM?) - commit them first.")
        MAP.write_bytes(subprocess.run(["git", "show", "HEAD:_maps/map_files/Ulthor/Ulthor.dmm"], cwd=ROOT,
                                       capture_output=True, check=True).stdout)
    M = Map()
    fixed = apply_map_fixes(M)
    smes = [s for s in M.find("/obj/machinery/power/smes") if s not in GRID_FED_SMES]
    terms = M.find("/obj/machinery/power/terminal")
    apcs = M.find("/obj/machinery/power/apc")
    # Keep the internal wiring of the solar arrays (catwalks in /area/station/solars).
    keep = {p for p in M.t if any(cable_layer(a) for a in M.t[p])
            and M.area(p).startswith("/area/station/solars/") and M.has(p, "/obj/structure/lattice")}
    old = {p for p in M.t if any(cable_layer(a) for a in M.t[p])}
    cables = set(keep)
    owner = {p: "solar" for p in keep}

    def term_for(s):
        for n in neighbours(s):
            if n in terms:
                return n
        raise SystemExit(f"SMES {s} has no terminal")

    smes_term = {s: term_for(s) for s in smes}
    fed_terms = {term_for(s) for s in GRID_FED_SMES}
    term_smes = {v: k for k, v in smes_term.items()}

    # Inputs: terminal -> generators of the same plant.
    def near(prefix, s, radius):
        return [p for p in M.find(prefix) if abs(p[0]-s[0]) + abs(p[1]-s[1]) <= radius]

    plants = {}
    for s in smes:
        area = M.area(s)
        gens = []
        if "/solars/" in area:
            gens = near("/obj/machinery/power/solar_control", s, 8)
            arrays = {"/area/station/maintenance/solars/port/ulthor": "/area/station/solars/port/ulthor",
                      "/area/station/maintenance/solars/port/aft": "/area/station/solars/port/aft",
                      "/area/station/maintenance/solars/starboard": "/area/station/solars/starboard/ulthor"}[area]
            gens += [p for p in M.find("/obj/machinery/power/solar") + M.find("/obj/machinery/power/tracker")
                     if M.area(p) == arrays and not M.has(p, "/obj/machinery/power/solar_control")]
        elif "turbine" in area:
            # The cable runs under the compressor, the turbine's only open side.
            gens = M.find("/obj/machinery/power/turbine") + M.find("/obj/machinery/power/compressor")
        else:
            gens = [g for g in near("/obj/machinery/power/port_gen", s, 12) if g not in apcs]
        plants[s] = gens

    # Generators standing on an APC tile feed the grid directly.
    grid_targets = set(smes) | set(apcs) | set(M.find("/obj/machinery/power/treadmill")) | fed_terms \
        | GRID_CONSUMERS | {g for g in M.find("/obj/machinery/power/port_gen") if g in apcs}
    # Machines that must not be touched by an unrelated net.
    machine_tiles = {p for p in M.t if any(x.startswith("/obj/machinery/power/") for x in M.types(p))}
    failures = []

    def guard(net):
        """Tiles a different net may not use: the net and its neighbours."""
        g = set()
        for p in (q for q, o in owner.items() if o == net):
            g.add(p)
            g.update(neighbours(p))
        return g

    # ---- input nets (layer 1: never joins the layer-2 grid) ----------------
    gen_tiles = set().union(*plants.values()) | set(terms)
    for s, gens in plants.items():
        net = ("in", s)
        term = smes_term[s]
        cables.add(term); owner[term] = net
        ban = set(smes) | set(apcs) | (machine_tiles - set(gens) - {term})
        for g in sorted(gens, key=lambda g: abs(g[0]-term[0]) + abs(g[1]-term[1])):
            mine = {p for p, o in owner.items() if o == net}
            if g in mine:
                continue
            # A solar group already wired joins as a whole.
            sources = {g}
            if owner.get(g) == "solar":
                group, todo = set(), [g]
                while todo:
                    q = todo.pop()
                    if q in group or owner.get(q) != "solar":
                        continue
                    group.add(q); todo += neighbours(q)
                for q in group:
                    owner[q] = net
                sources = group
            others = set()
            for o in set(owner.values()) - {net, "solar"}:
                others |= guard(o)
            pth = route(M, sources, lambda p: p in mine, lambda p: 1.0 if walkable(M, p, True) else None,
                        (ban | others) - mine - sources)
            if not pth:
                failures.append(f"input {s}: generator {g} unreachable")
                continue
            for p in pth:
                cables.add(p); owner[p] = net

    # Unclaimed solar wiring (dead ends) is dropped.
    for p, o in list(owner.items()):
        if o == "solar":
            cables.discard(p); del owner[p]
    inputs = set(cables)

    # ---- grid (layer 2, red) ---------------------------------------------
    blocked = inputs | (machine_tiles - grid_targets)

    def ring_cost(p):
        if p in blocked or not walkable(M, p):
            return None
        a = M.area(p)
        c = 1.0 if "/hallway" in a else 1.6 if "/maintenance" in a else 4.0 if "/commons" in a else 12.0
        if any(classify(M.t.get(n, ["/turf/simulated/wall", "/area"])) != "floor" for n in neighbours(p)):
            c += 0.25  # keep to the middle of wide corridors
        return c

    ring = []
    pts = [(x, y, 1) for x, y in RING]
    for a, b in zip(pts, pts[1:] + pts[:1]):
        pth = route(M, {a}, lambda p, b=b: p == b, ring_cost, set())
        if not pth:
            failures.append(f"ring segment {a}->{b} unroutable")
            continue
        ring += pth
    grid = set(ring)

    def branch_cost(target_area):
        def c(p):
            if p in blocked or not walkable(M, p):
                return None
            if p in grid:
                return 0.0
            a = M.area(p)
            v = 1.0 if ("/hallway" in a or "/maintenance" in a) else 1.5 if a == target_area else 8.0
            if any(n in grid for n in neighbours(p)):
                v += 0.5  # do not run alongside an existing line
            return v
        return c

    for tgt in sorted(grid_targets, key=lambda p: min(abs(p[0]-q[0]) + abs(p[1]-q[1]) for q in ring)):
        if tgt in grid:
            continue
        pth = route(M, {tgt}, lambda p: p in grid, branch_cost(M.area(tgt)), set())
        if not pth:
            failures.append(f"grid: {M.area(tgt)} {tgt} unreachable")
            continue
        grid.update(pth)
    cables |= grid

    # ---- write ------------------------------------------------------------
    for p in old | cables | fixed:
        tile = [a for a in M.t[p] if not cable_layer(a)]
        if p in cables:
            i = next(i for i, a in enumerate(tile) if a.startswith(("/obj", "/turf")))
            tile.insert(i, CABLE_IN if p in inputs else CABLE)
        M.m.set_tile(p, tuple(tile))
    M.m.to_file(str(MAP))
    STAMP.parent.mkdir(exist_ok=True)
    STAMP.write_text(hashlib.sha256(MAP.read_bytes()).hexdigest() + "\n")
    print(f"cables: {len(old)} -> {len(cables)} tiles; ring {len(set(ring))}; grid {len(grid)}; inputs {len(inputs)}")
    for f in failures:
        print("FAIL", f)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
