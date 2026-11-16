"""Static audit of the research outpost on a mining asteroid map.

Checks gas pipe connections, smart cable power networks and disposal pipes in
the outpost bounding box, using the connection rules of the project's code.

Usage: python tools/xenoarch/audit_outpost.py MAP [x0 y0 x1 y1]
"""
import sys
from collections import defaultdict, deque
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from dmm import DMM, atom_type, atom_vars  # noqa: E402

N, S, E, W = 1, 2, 4, 8
DIRS = (N, S, E, W)
STEP = {N: (0, 1), S: (0, -1), E: (1, 0), W: (-1, 0)}
REV = {N: S, S: N, E: W, W: E}
SIMPLE = {1: N | S, 2: N | S, 4: E | W, 8: E | W, 5: N | E, 6: S | E, 9: N | W, 10: S | W}
MANIFOLD = {N: E | S | W, S: W | N | E, E: S | W | N, W: N | E | S}
TRINARY = {N: E | N | S, S: S | W | N, E: E | W | S, W: W | N | E}


def bits(mask):
    return [d for d in DIRS if mask & d]


def atmos_dirs(t, v):
    d = int(v.get('dir', '2'))
    if '/pipe/simple' in t:
        return SIMPLE[d]
    if '/pipe/cap' in t:
        return d
    if '/pipe/manifold4w' in t:
        return N | S | E | W
    if '/pipe/manifold' in t:
        return MANIFOLD[d]
    if '/unary/' in t:
        return d
    if '/binary/' in t:
        return d | REV[d]
    if '/trinary/' in t:
        return TRINARY[d]
    return 0


def disposal_dirs(t, v):
    d = int(v.get('dir', '2'))
    if t.endswith('/segment'):
        if 'pipe-c' in v.get('icon_state', ''):
            return d | {N: E, E: S, S: W, W: N}[d]  # corner: dir and turn(dir, -90)
        return d | REV[d]
    if t.endswith('/trunk'):
        return d
    if t.endswith('/junction') or t.endswith('/sortjunction'):
        return 0
    return 0


def audit(path, x0=130, y0=170, x1=200, y1=218):
    m = DMM.load(path)
    atmos = defaultdict(list)
    disposal = defaultdict(list)
    cables = {}
    smes, terminals, apcs, gens = [], [], [], []
    for x in range(x0 - 1, x1 + 2):
        for y in range(y0 - 1, y1 + 2):
            for a in m.tile(x, y):
                t = atom_type(a)
                v = atom_vars(a)
                if t.startswith('/obj/machinery/atmospherics/') and not t.endswith('/meter'):
                    atmos[(x, y)].append((t, atmos_dirs(t, v)))
                elif t.startswith('/obj/structure/disposalpipe/'):
                    disposal[(x, y)].append((t, disposal_dirs(t, v)))
                elif t.startswith('/obj/structure/cable'):
                    cables[(x, y)] = 15 & ~int(v.get('banned_links', '0'))
                elif t == '/obj/machinery/power/smes':
                    smes.append((x, y))
                elif t == '/obj/machinery/power/terminal':
                    terminals.append((x, y))
                elif t == '/obj/machinery/power/apc':
                    apcs.append(((x, y), v.get('name')))
                elif t.startswith('/obj/machinery/power/port_gen'):
                    gens.append((x, y))
    problems = []
    inside = lambda p: x0 <= p[0] <= x1 and y0 <= p[1] <= y1  # noqa: E731
    for label, net in (('gas', atmos), ('disposal', disposal)):
        for p, items in net.items():
            if not inside(p):
                continue
            seen = 0
            for t, mask in items:
                if mask & seen:
                    problems.append(f'{label}: stacked connections at {p}: {[i[0].split("/")[-1] for i in items]}')
                seen |= mask
                for d in bits(mask):
                    q = (p[0] + STEP[d][0], p[1] + STEP[d][1])
                    if not any(om & REV[d] for _, om in net.get(q, [])):
                        problems.append(f'{label}: {t.split("/", 3)[-1]} at {p} points {d} into nothing')
    # Power: emulate smart cable linking, including the SMES/terminal exception.
    graph = defaultdict(set)
    for p, mask in cables.items():
        for d in bits(mask):
            q = (p[0] + STEP[d][0], p[1] + STEP[d][1])
            if q not in cables or not cables[q] & REV[d]:
                continue
            if (p in smes and q in terminals) or (p in terminals and q in smes):
                continue
            graph[p].add(q)
    def component(start):
        seen, todo = {start}, deque([start])
        while todo:
            c = todo.popleft()
            for n in graph[c]:
                if n not in seen:
                    seen.add(n)
                    todo.append(n)
        return seen
    report = {}
    if smes:
        output = component(smes[0]) if smes[0] in cables else set()
        inputs = component(terminals[0]) if terminals and terminals[0] in cables else set()
        report['output_tiles'] = len(output)
        report['input_tiles'] = len(inputs)
        report['separate'] = not (output & inputs)
        for s in smes:
            if s not in output:
                problems.append(f'power: SMES {s} not on the distribution circuit')
        for tm in terminals:
            if tm not in inputs:
                problems.append(f'power: terminal {tm} not on the charging circuit')
        for g in gens:
            if g not in inputs:
                problems.append(f'power: generator {g} not on the charging circuit')
        for p, name in apcs:
            if inside(p) and p not in output:
                problems.append(f'power: APC {name} at {p} not on the distribution circuit (cable={p in cables})')
    return problems, report


if __name__ == '__main__':
    args = sys.argv[1:]
    box = [int(a) for a in args[1:5]] if len(args) >= 5 else []
    problems, report = audit(args[0], *box)
    print(report)
    for p in problems:
        print(p)
    print(f'{len(problems)} problems')
