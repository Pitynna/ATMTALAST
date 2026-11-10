"""Audit Ulthor's actual directed disposal routes, wall sprites and exact duplicates.

Read-only by default. --repair applies the one-time layout repair, preserving
the three dedicated outlets and reusing existing pipe corridors where possible.
No server, subprocess, cleanup, or links are used.
"""
import argparse
from collections import Counter, deque
import heapq
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM
from check_map import parse_map_atom

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
PIPE = '/obj/structure/disposalpipe/'
BIN = '/obj/machinery/disposal'
WALL = BIN + '/wall'
OUTLET = '/obj/structure/disposaloutlet'
DELTA = {1: (0, 1), 2: (0, -1), 4: (1, 0), 8: (-1, 0)}
REVERSE = {1: 2, 2: 1, 4: 8, 8: 4}
RIGHT = {1: 4, 4: 2, 2: 8, 8: 1}
LEFT = {v: k for k, v in RIGHT.items()}
MAIN = (76, 109, 1)
SPECIAL = {(64, 161, 1): (60, 159, 1),
           (137, 190, 1): (133, 197, 1),
           (186, 168, 1): (186, 167, 1)}


def step(p, direction):
    dx, dy = DELTA[direction]
    return p[0] + dx, p[1] + dy, p[2]


def direction(p, q):
    return next(d for d in DELTA if step(p, d) == q)


def atom(typ, values):
    return typ + ('{' + ';'.join(f'{k} = {v}' for k, v in values.items()) + '}' if values else '')


def inventory(m):
    tiles = {p: [parse_map_atom(a) for a in m.get_tile(p)] for p in m.grid}
    pipes, bins, outlets = {}, {}, set()
    for p, atoms in tiles.items():
        for typ, values in atoms:
            if typ.startswith(PIPE):
                assert p not in pipes, f'Stacked disposal pipes at {p}'
                pipes[p] = (typ, values)
            elif typ.startswith(BIN):
                bins[p] = (typ, values)
            elif typ == OUTLET:
                outlets.add(p)
    return tiles, pipes, bins, outlets


def mask(typ, d):
    if typ == PIPE + 'trunk':
        return d
    if typ == PIPE + 'segment':
        return d | REVERSE.get(d, 0)
    if typ == PIPE + 'junction':
        return d | REVERSE[d] | RIGHT[d]
    if typ == PIPE + 'junction/reversed':
        return d | REVERSE[d] | LEFT[d]
    if typ == PIPE + 'junction/yjunction':
        return d | LEFT[d] | RIGHT[d]
    raise ValueError(typ)


def wall_direction(tiles, p):
    walls = [d for d in DELTA if any(t.startswith('/turf/simulated/wall')
             for t, _ in tiles.get(step(p, d), []))]
    assert len(walls) == 1, (p, walls)
    return walls[0]


def wall_appearance(tiles, p):
    # DMI EAST sits on the LEFT edge, WEST on the RIGHT edge. NORTH's
    # front-facing frame occupies rows 15..31 and needs lifting to the wall.
    return {1: (1, 16), 2: (2, 0), 4: (8, 0), 8: (4, 0)}[wall_direction(tiles, p)]


def trace(pipes, start, outlets):
    p = start
    incoming = 16  # DOWN, as in disposalholder.start()
    visited = set()
    route = []
    while len(route) < 1000:
        if (p, incoming) in visited:
            raise ValueError(f'Loop at {p}')
        visited.add((p, incoming))
        route.append(p)
        if p not in pipes:
            raise ValueError(f'Missing pipe at {p}')
        typ, values = pipes[p]
        d = int(values.get('dir', '0'))
        ports = mask(typ, d)
        if not ports:
            raise ValueError(f'Zero pipe direction at {p}')
        if typ == PIPE + 'trunk':
            if incoming != 16:
                if p not in outlets:
                    raise ValueError(f'Route returns to another bin at {p}')
                return route
            exit_dir = d
        elif '/junction' in typ:
            if REVERSE[incoming] == d:
                raise ValueError(f'Random junction routing at {p}')
            exit_dir = d
        else:
            exit_dir = ports & ~REVERSE[incoming]
        if exit_dir not in DELTA:
            raise ValueError(f'Invalid outgoing direction {exit_dir} at {p}')
        q = step(p, exit_dir)
        if q not in pipes or not mask(pipes[q][0], int(pipes[q][1].get('dir', '0'))) & REVERSE[exit_dir]:
            raise ValueError(f'Broken connection {p} -> {q}')
        p, incoming = q, exit_dir
    raise ValueError('Route exceeds disposalholder step limit')


def audit(m):
    tiles, pipes, bins, outlets = inventory(m)
    failures, routes = [], []
    for p, (typ, values) in bins.items():
        if typ.startswith(WALL):
            expected_dir, expected_y = wall_appearance(tiles, p)
            if int(values.get('dir', '2')) != expected_dir:
                failures.append(f'{p}: wall bin faces away from wall')
            if int(values.get('pixel_x', '0')) or int(values.get('pixel_y', '0')) != expected_y:
                failures.append(f'{p}: incorrect wall bin pixel offset')
        try:
            route = trace(pipes, p, outlets)
            expected = SPECIAL.get(p, MAIN)
            if route[-1] != expected:
                raise ValueError(f'Wrong outlet {route[-1]}, expected {expected}')
            routes.append({'start': p, 'outlet': route[-1], 'steps': len(route) - 1})
        except (ValueError, KeyError) as error:
            failures.append(f'{p}: {error}')
    used = set()
    for entry in routes:
        used.update(trace(pipes, entry['start'], outlets))
    for p, (typ, values) in pipes.items():
        if not int(values.get('dir', '0')):
            failures.append(f'{p}: zero direction')
        if p not in used:
            failures.append(f'{p}: pipe unused by any complete disposal route')
        d = int(values.get('dir', '0'))
        if not d:
            continue
        for port in DELTA:
            if not mask(typ, d) & port:
                continue
            q = step(p, port)
            if q not in pipes or not mask(pipes[q][0], int(pipes[q][1].get('dir', '0'))) & REVERSE[port]:
                failures.append(f'{p}: unconnected port {port}')
    for p in tiles:
        for a, count in Counter(m.get_tile(p)).items():
            if count > 1 and a.startswith(('/obj/machinery', '/obj/structure')):
                failures.append(f'{p}: {count} exact copies of {a}')
    return {'bins': len(bins), 'wall_bins': sum(t.startswith(WALL) for t, v in bins.values()),
            'pipes': len(pipes), 'outlets': len(outlets), 'routes': routes, 'failures': failures}


def repair(m):
    tiles, old_pipes, bins, outlets = inventory(m)
    graph = {}

    def link(p, q):
        graph.setdefault(p, set()).add(q)
        graph.setdefault(q, set()).add(p)

    # Preserve isolated equipment routes. These must never become general waste exits.
    special_paths = [
        [(64, 161, 1), (64, 160, 1), (64, 159, 1)] + [(x, 159, 1) for x in range(63, 59, -1)],
        [(x, 190, 1) for x in range(137, 132, -1)] + [(133, y, 1) for y in range(191, 198)],
        [(186, 168, 1), (186, 167, 1)],
    ]
    for path in special_paths:
        assert all(p in old_pipes for p in path)
        for p, q in zip(path, path[1:]):
            link(p, q)
    reserved = set(graph)

    # Preserve the original connected cargo trunk and its three bins.
    main_graph = {}
    for p, (typ, values) in old_pipes.items():
        d = int(values.get('dir', '2'))  # old map's omitted SOUTH, made explicit below
        ports = mask(typ, d)
        main_graph[p] = set()
        for port in DELTA:
            q = step(p, port)
            if ports & port and q in old_pipes:
                qt, qv = old_pipes[q]
                if mask(qt, int(qv.get('dir', '2'))) & REVERSE[port]:
                    main_graph[p].add(q)
    connected = {MAIN}
    queue = deque([MAIN])
    while queue:
        p = queue.popleft()
        for q in sorted(main_graph[p]):
            link(p, q)
            if q not in connected:
                connected.add(q)
                queue.append(q)

    # Join each remaining bin to the existing trunk, favouring authored pipe cells.
    # New pipe is restricted to existing station floors; no hull or room edits.
    # Bins/outlets stay leaves; junctions are limited to three ports.
    for start in sorted(set(bins) - set(SPECIAL) - connected):
        heap = [(0, start)]
        costs, prev = {start: 0}, {start: None}
        target = None
        while heap:
            cost, p = heapq.heappop(heap)
            if cost != costs[p]:
                continue
            if p in connected:
                if p not in bins and p not in outlets and len(graph[p]) < 3:
                    target = p
                    break
                continue
            for port in DELTA:
                q = step(p, port)
                if q in reserved or q not in tiles or q in bins and q != start or q in outlets:
                    continue
                floor = any(t.startswith('/turf/simulated/floor') for t, v in tiles[q])
                if not floor and q not in old_pipes:
                    continue
                if q in connected and (q in bins or q in outlets or len(graph[q]) >= 3):
                    continue
                extra = 1 if q in old_pipes else 5
                new_cost = cost + extra
                if new_cost < costs.get(q, float('inf')):
                    costs[q] = new_cost
                    prev[q] = p
                    heapq.heappush(heap, (new_cost, q))
        assert target is not None, f'No floor route from {start}'
        p = target
        while prev[p] is not None:
            q = prev[p]
            link(p, q)
            connected.add(q)
            p = q

    parents = {}
    for root in sorted(outlets):
        parents[root] = None
        queue = deque([root])
        while queue:
            p = queue.popleft()
            for q in sorted(graph[p]):
                if q == parents[p]:
                    continue
                assert q not in parents, f'Cycle at {q}'
                parents[q] = p
                queue.append(q)
    new_pipes = {}
    for p, neighbours in graph.items():
        ports = {direction(p, q) for q in neighbours}
        if p in bins or p in outlets:
            assert len(ports) == 1, p
            typ, d = PIPE + 'trunk', next(iter(ports))
        elif len(ports) == 2:
            typ = PIPE + 'segment'
            d = sum(ports)
            if d in (3, 12):
                d = 2 if d == 3 else 4
        else:
            assert len(ports) == 3, (p, ports)
            d = direction(p, parents[p])
            typ = next(t for t in (PIPE + 'junction', PIPE + 'junction/reversed', PIPE + 'junction/yjunction')
                       if mask(t, d) == sum(ports))
        new_pipes[p] = atom(typ, {'dir': str(d)})

    duplicates = 0
    for p in sorted(tiles):
        old = m.get_tile(p)
        new, seen = [], set()
        for a in old:
            typ, values = parse_map_atom(a)
            if typ.startswith(PIPE):
                continue
            if a in seen and typ.startswith(('/obj/machinery', '/obj/structure')):
                duplicates += 1
                continue
            seen.add(a)
            if typ.startswith(WALL):
                values = {k: v for k, v in values.items() if k not in ('pixel_x', 'pixel_y')}
                d, py = wall_appearance(tiles, p)
                values['dir'] = str(d)
                if py:
                    values['pixel_y'] = str(py)
                a = atom(typ, values)
            if typ.startswith('/turf') and p in new_pipes:
                new.append(new_pipes[p])
            new.append(a)
        if tuple(new) != old:
            m.set_tile(p, new)
    report = audit(m)
    assert not report['failures'], report['failures']
    report['repair'] = {'duplicate_objects_removed': duplicates,
                        'old_pipe_cells': len(old_pipes),
                        'reused_pipe_cells': len(set(old_pipes) & set(new_pipes)),
                        'unused_pipe_cells_removed': sorted(set(old_pipes) - set(new_pipes)),
                        'new_pipe_cells': len(set(new_pipes) - set(old_pipes))}
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repair', action='store_true')
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    m = DMM.from_file(MAP)
    report = repair(m) if args.repair else audit(m)
    if args.repair:
        m.to_file(MAP)
    if args.output:
        args.output.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(report, indent=2))
    return bool(report['failures'])


if __name__ == '__main__':
    sys.exit(main())
