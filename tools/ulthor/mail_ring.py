"""Turn Ulthor's disposal tree into a Box-style mail ring (2026-11-19).

Ulthor's disposals were a tree draining into the disposal room, so a tagged
package could only travel downstream and never reach another department.
This script, editing the current map incrementally:

* closes the two trunks into a ring: the north trunk keeps flowing into the
  disposal room, the south trunk is reversed (it now leaves the disposal room
  eastwards) and a new pipe joins their eastern ends;
* next to the disposal room two sort junctions take tag 1 ("Disposals", all
  bin trash) and tag 0 (untagged) off the ring to the disposal outlet;
* every mail destination (GLOB.TAGGERLOCATIONS) gets a bin whose branch is a
  plain chain to a straight ring cell; that ring cell becomes a sort junction
  with the department's tag. Bins whose old branch had forks get a new branch
  (doors and windows are fine, walls are not); departments without a bin get
  one.
* Every other branch keeps draining into the ring.

The result is checked by tracing every bin's trash and every tag from every
bin and from the cargo delivery chute. Refuses to run over uncommitted map
edits. Usage: python tools/ulthor/mail_ring.py [--write]
"""
import heapq
import subprocess
import sys
from collections import deque
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from check_disposals import (MAP, ROOT, PIPE, BIN, OUTLET, DELTA, REVERSE, RIGHT, LEFT,  # noqa: E402
                             DMM, inventory, mask, step, direction, atom, parse_map_atom)

ROOT_CELL = (76, 110, 1)
OUTLET_CELL = (76, 109, 1)
CHUTE = (80, 133, 1)
NORTH_HEAD = (193, 149, 1)   # turbine bin, far end of the north trunk
SOUTH_HEAD = (167, 139, 1)   # atmospherics bin, far end of the south trunk
RESERVED = {(x, y, 1) for x in range(145, 150) for y in range(130, 142)}  # future engine room
TAGS = ['Disposals', 'Cargo Bay', 'QM Office', 'Engineering', 'CE Office', 'Atmospherics', 'HoS Office',
        'Security', 'Medbay', 'CMO Office', 'Chemistry', 'Research', 'RD Office', 'Robotics', 'HoP Office',
        'Library', 'Chapel', "Captain's Office", 'Bar', 'Kitchen', 'Hydroponics', 'Janitor Closet', 'Genetics',
        'Brig Physician', 'Morgue', 'NTRep Office', 'Detective', "Magistrate's Office", 'IAA Office', 'Mechanic']
# tag -> receiving bin (or the cargo mail outlet), or an area that needs a new bin
TARGETS = {
    2: (75, 132), 3: (80, 124), 4: (156, 120), 5: (154, 143), 6: (167, 139), 7: (110, 115), 8: (136, 118),
    9: (137, 179), 10: (141, 183), 11: '/area/station/medical/chemistry', 12: (172, 168), 13: (165, 165),
    14: (162, 178), 15: (117, 163), 16: (80, 103), 17: (89, 178), 18: (138, 161), 19: (83, 150),
    20: (73, 141), 21: (81, 152), 22: (87, 161), 23: (118, 188), 24: (108, 113), 25: (111, 187),
    26: (107, 161), 27: '/area/station/security/detectives_office', 28: (121, 101), 29: (126, 102),
    30: (158, 92),
}
ALTERNATIVES = {9: [(128, 189)]}
# HoS: the office's only exit (door 112,114) already carries the security
# branch and the ring turns right behind it, so no sort junction fits there.
KNOWN_UNSERVED = {7}
# Outlet branch at the disposal room: ring cells (78,110) and (79,110) are
# sort junctions flowing east with their side to the south.
MANUAL = {
    (78, 110, 1): (PIPE + 'sortjunction', {'dir': '4', 'sortType': '0'}),
    (79, 110, 1): (PIPE + 'sortjunction', {'dir': '4', 'sortType': '1'}),
    (79, 109, 1): (PIPE + 'segment', {'dir': '9'}),
    (78, 109, 1): (PIPE + 'junction', {'dir': '8'}),
    (77, 109, 1): (PIPE + 'segment', {'dir': '4'}),
    (76, 109, 1): (PIPE + 'trunk', {'dir': '4'}),
}
OUTLET_EDGES = [((78, 110, 1), (78, 109, 1)), ((79, 110, 1), (79, 109, 1)), ((79, 109, 1), (78, 109, 1)),
                ((78, 109, 1), (77, 109, 1)), ((77, 109, 1), (76, 109, 1))]
FREE_OBJ = ('/obj/effect', '/obj/structure/cable', '/obj/machinery/atmospherics', '/obj/item', '/obj/machinery/light',
            '/obj/machinery/alarm', '/obj/machinery/firealarm', '/obj/machinery/power/apc', '/obj/machinery/camera',
            '/obj/machinery/light_switch', '/obj/machinery/status_display', '/obj/machinery/newscaster',
            '/obj/machinery/requests_console', '/obj/structure/sign', '/obj/machinery/navbeacon',
            '/obj/structure/extinguisher_cabinet', '/obj/structure/noticeboard', '/obj/machinery/door_control')


def main():
    write = '--write' in sys.argv
    if subprocess.run(['git', 'diff', '--quiet', '--', str(MAP)], cwd=ROOT).returncode:
        sys.exit('Ulthor.dmm has uncommitted edits (StrongDMM?) - commit them first.')
    m = DMM.from_file(str(MAP))
    tiles, pipes, bins, outlets = inventory(m)
    ends = set(bins) | outlets

    # ---- graph of the connected main network ---------------------------------
    adj = {}
    for p, (typ, v) in pipes.items():
        adj[p] = set()
        for port in DELTA:
            q = step(p, port)
            if mask(typ, int(v.get('dir', '2'))) & port and q in pipes:
                qt, qv = pipes[q]
                if mask(qt, int(qv.get('dir', '2'))) & REVERSE[port]:
                    adj[p].add(q)
    comp, queue = {ROOT_CELL}, deque([ROOT_CELL])
    while queue:
        p = queue.popleft()
        for q in adj[p]:
            if q not in comp:
                comp.add(q)
                queue.append(q)
    occupied = set(pipes) - comp          # special isolated nets stay untouched
    g = {p: set(adj[p]) for p in comp}

    def link(a, b):
        g.setdefault(a, set()).add(b)
        g.setdefault(b, set()).add(a)

    def unlink(a, b):
        g[a].discard(b)
        g[b].discard(a)

    def tree_path(a, b):
        prev, queue = {a: None}, deque([a])
        while queue:
            p = queue.popleft()
            if p == b:
                break
            for q in g[p]:
                if q not in prev:
                    prev[q] = p
                    queue.append(q)
        out = [b]
        while prev[out[-1]] is not None:
            out.append(prev[out[-1]])
        return out[::-1]

    def area(p):
        return m.get_tile(p)[-1]

    def free(p):
        """A cell new pipe may use: station floor, no pipe, no window, no bin."""
        if p in g or p in occupied or p in RESERVED or p not in tiles or p in ends:
            return False
        a = area(p)
        if a.startswith(('/area/space', '/area/shuttle')) or a.startswith('/area/station/solars'):
            return False
        types = [t for t, v in tiles[p]]
        if not any(t.startswith('/turf/simulated/floor') for t in types):
            return False
        # windows are fine (user: utilities go through glass or doorways), walls are not
        return not any(t.startswith((BIN, OUTLET, '/obj/machinery/mass_driver')) for t in types)

    def cost(p):
        a = area(p)
        c = 1.0 if a.startswith('/area/station/maintenance') else 1.5 if a.startswith('/area/station/hallway') else 3.0
        if any(t.startswith('/obj/machinery/door') for t, v in tiles[p]):
            c += 1.0
        if any(t.startswith(('/obj/effect/spawner/window', '/obj/structure/window', '/obj/structure/grille'))
               for t, v in tiles[p]):
            c += 4.0
        return c

    def dijkstra(sources, goal):
        """sources: {cell: start dir or None}; goal(cell) -> truthy end info."""
        heap, best, prev = [], {}, {}
        for s in sources:
            best[(s, None)] = 0.0
            heapq.heappush(heap, (0.0, s, None))
        while heap:
            c, p, d = heapq.heappop(heap)
            if best.get((p, d), 1e18) < c:
                continue
            if d is not None:
                hit = goal(p)
                if hit:
                    out, key = [p], (p, d)
                    while key in prev:
                        key = prev[key]
                        out.append(key[0])
                    return out[::-1], hit
            for e in DELTA:
                q = step(p, e)
                if not free(q):
                    continue
                nc = c + cost(q) + (0.4 if d is not None and d != e else 0)
                if nc < best.get((q, e), 1e18):
                    best[(q, e)] = nc
                    prev[(q, e)] = (p, d)
                    heapq.heappush(heap, (nc, q, e))
        return None, None

    # ---- the ring ------------------------------------------------------------
    unlink(ROOT_CELL, OUTLET_CELL)
    north = tree_path(NORTH_HEAD, ROOT_CELL)
    south = tree_path(ROOT_CELL, SOUTH_HEAD)
    assert south[1] == (77, 110, 1), south[:3]
    s_cand = {p for p in south[len(south) * 3 // 5:-1] if len(g[p]) == 2}
    n_cand = {p for p in north[1:len(north) * 2 // 5] if len(g[p]) == 2}

    def near_north(p):
        return next((q for q in (step(p, e) for e in DELTA) if q in n_cand), None)
    path, n_att = dijkstra(s_cand, near_north)
    assert path, 'no free route between the trunk ends'
    s_att = path[0]
    for a, b in zip(path, path[1:]):
        link(a, b)
    link(path[-1], n_att)
    ring = [ROOT_CELL] + south[1:south.index(s_att) + 1] + path[1:] + north[north.index(n_att):-1]
    succ = {a: ring[(i + 1) % len(ring)] for i, a in enumerate(ring)}
    ringset = set(ring)
    assert len(ringset) == len(ring)
    for a, b in OUTLET_EDGES:
        assert a in ringset or free(b) or b == OUTLET_CELL or b in MANUAL, (a, b)
    for a, b in OUTLET_EDGES:
        link(a, b)
    for p in [(78, 110, 1), (79, 110, 1)]:
        assert p in ringset and succ[p] == step(p, 4) and len(g[p]) == 3, p

    def straight(p):
        prev = ring[ring.index(p) - 1]
        return direction(prev, p) == direction(p, succ[p])

    def parents():
        par, queue = {}, deque(ring)
        seen = set(ring) | set(MANUAL)
        while queue:
            p = queue.popleft()
            for q in g[p]:
                if q not in seen:
                    seen.add(q)
                    par[q] = p
                    queue.append(q)
        return par

    # ---- delivery branches -----------------------------------------------------
    sort, report, new_bins = {}, [], []

    def eligible(r):
        return r in ringset and r not in MANUAL and r not in sort and straight(r) and len(g[r]) == 2

    def existing_route(p, par):
        """Sort cells that let mail climb the bin's present branch: every fork on the
        way must take the bin's side in from the side while the rest of the
        branch runs straight through; the ring cell must be straight."""
        cells, c, n = [], p, par[p]
        while n not in ringset:
            if len(g[n]) == 3:
                ex = direction(n, par[n])
                other = next(q for q in g[n] if q not in (c, par[n]))
                if direction(n, other) != REVERSE[ex] or n in sort:
                    return None
                cells.append(n)
            c, n = n, par[n]
        if len(g[n]) == 3 and n not in MANUAL and n not in sort and straight(n):
            return cells + [n]
        return None

    def fork_ok(n, c, par):
        ex = direction(n, par[n])
        other = next(q for q in g[n] if q not in (c, par[n]))
        return direction(n, other) == REVERSE[ex] and n not in sort

    def sortable(x, par):
        """Sort cells that carry mail from the ring up to branch cell x, which is a
        straight plain pipe a new side branch may join; None if impossible."""
        if x in ringset or x in sort or x in MANUAL or x in ends or len(g.get(x, ())) != 2:
            return None
        a, b = sorted(g[x])
        if direction(x, a) != REVERSE[direction(x, b)]:
            return None
        cells, c, n = [x], x, par.get(x)
        while n is not None and n not in ringset:
            if len(g[n]) == 3:
                if not fork_ok(n, c, par):
                    return None
                cells.append(n)
            c, n = n, par[n]
        if n is None or len(g[n]) != 3 or n in MANUAL or n in sort or not straight(n):
            return None
        return cells + [n]

    goal_par = {}

    def ring_goal(c):
        for q in (step(c, e) for e in DELTA):
            if eligible(q):
                return [q]
            if q in g and '--no-branch-join' not in sys.argv:
                got = sortable(q, goal_par)
                if got:
                    return got
        return None

    def relay(p):
        """Cut the bin's branch as close to the ring as possible and lay a new
        plain pipe from the cut to a straight ring cell. Forks kept on the
        bin's side must pass fork_ok. Returns (stub, ring cell, forks)."""
        par = parents()
        chain = [p]
        while chain[-1] not in ringset:
            chain.append(par[chain[-1]])
        for i in reversed(range(len(chain) - 1)):
            if i and len(g[chain[i]]) != 2:
                continue
            forks = [chain[k] for k in range(1, i + 1) if len(g[chain[k]]) == 3]
            if not all(fork_ok(f, chain[chain.index(f) - 1], par) for f in forks):
                continue
            j = i + 1
            while chain[j] not in ringset and len(g[chain[j]]) == 2:
                j += 1
            cut = chain[i:j + 1]
            saved = {q: set(g[q]) for q in cut}
            for a, b in zip(cut, cut[1:]):
                unlink(a, b)
            for q in cut[1:-1]:
                del g[q]
            goal_par.clear()
            goal_par.update(parents())
            stub, r = dijkstra({chain[i]: None}, ring_goal)
            if stub:
                return stub, r, forks
            for q, nb in saved.items():
                g[q] = set(nb)
                for x in nb:
                    g.setdefault(x, set()).add(q)
        return None

    def walkable(p):
        return p in tiles and any(t.startswith('/turf/simulated/floor') for t, v in tiles[p]) and all(
            t.startswith(FREE_OBJ + ('/turf', '/area', '/obj/machinery/door', '/obj/structure/disposalpipe',
                                     '/obj/structure/chair', '/obj/machinery/hologram', '/mob/living/simple_animal'))
            and not t.startswith(('/obj/effect/spawner/window', '/obj/machinery/door/window'))
            for t, v in tiles[p])

    def keeps_room_connected(p, target_area):
        """A new bin must not split the room's walkable floor into more parts."""
        room = {q for q in tiles if area(q) == target_area and walkable(q)}

        def parts(cells):
            seen, n = set(), 0
            for s0 in cells:
                if s0 in seen:
                    continue
                n += 1
                todo = [s0]
                while todo:
                    c = todo.pop()
                    if c in seen or c not in cells:
                        continue
                    seen.add(c)
                    todo.extend(step(c, e) for e in DELTA)
            return n
        return p in room and parts(room - {p}) <= parts(room)

    last_cands = []

    def new_bin(target_area):
        cands, by_wall = [], {}
        for p in tiles:
            if area(p) != target_area or not free(p) or any(not t.startswith(FREE_OBJ + ('/turf', '/area',
                                                                                         '/mob/living/simple_animal'))
                                                           for t, v in tiles[p]):
                continue
            around = [tiles.get(step(p, e), []) for e in DELTA]
            walls = sum(any(t.startswith(('/turf/simulated/wall', '/obj/effect/spawner/window')) for t, v in a)
                        for a in around)
            doors = sum(any(t.startswith(('/obj/machinery/door/airlock', '/obj/machinery/door/window'))
                            for t, v in a) for a in around)
            busy = any(t.startswith(('/obj/machinery/atmospherics/unary', '/obj/effect/landmark',
                                     '/obj/machinery/hologram', '/obj/machinery/navbeacon')) for t, v in tiles[p])
            if (walkable(p) and not busy and walls <= 2 and not doors
                    and keeps_room_connected(p, target_area)):
                cands.append(p)
                by_wall[p] = 0 if walls else 1   # against a wall or window if possible
        last_cands[:] = cands
        goal_par.clear()
        goal_par.update(parents())
        for p in sorted(cands, key=lambda c: (by_wall[c], min(abs(c[0] - r[0]) + abs(c[1] - r[1]) for r in ring))):
            stub, r = dijkstra({p: None}, ring_goal)
            if stub:
                return p, stub, r
        return None

    base_g = {k: set(v) for k, v in g.items()}
    base_ends = set(ends)

    def attempt(order):
        g.clear()
        g.update({k: set(v) for k, v in base_g.items()})
        ends.clear()
        ends.update(base_ends)
        sort.clear()
        report.clear()
        new_bins.clear()
        done = set()
        for tag, target in sorted(TARGETS.items()):  # first keep the branches that already work
            if isinstance(target, str):
                continue
            got = existing_route((*target, 1), parents())
            if got:
                for c in got:
                    sort[c] = tag
                done.add(tag)

        for tag in order:   # then re-lay or add branches
            if tag in done:
                continue
            target = TARGETS[tag]
            name = TAGS[tag - 1]
            forks = []
            got = None
            if not isinstance(target, str):
                for alt in [target] + ALTERNATIVES.get(tag, []):
                    got = relay((*alt, 1))
                    if got:
                        break
                if got:
                    stub, r, forks = got
                else:
                    target = area((*target, 1))
            if not got:
                got = new_bin(target)
                if not got:
                    if '--why' in sys.argv and not isinstance(TARGETS[tag], str):
                        seen, todo = set(), [step((*TARGETS[tag], 1), 1)]
                        while todo:
                            c = todo.pop()
                            if c in seen or not free(c):
                                continue
                            seen.add(c)
                            todo.extend(step(c, e) for e in DELTA)
                        touch = {q for c in seen for q in (step(c, e) for e in DELTA) if q in g}
                        print('WHY region', len(seen), 'pipes touched',
                              sorted((q[:2], 'ring' if q in ringset else len(g[q]), q in sort,
                                      q in ringset and straight(q)) for q in touch))
                    report.append(f'{tag} {name}: no route from its bins and no place for a new bin in {target}')
                    continue
                p, stub, r = got
                new_bins.append(p)
                ends.add(p)
            for c in forks:
                sort[c] = tag
            for a, b in zip(stub, stub[1:]):
                link(a, b)
            link(stub[-1], r[0])
            for c in r:
                sort[c] = tag

        return [int(r.split()[0]) for r in report]

    order = sorted(TARGETS)
    best = None
    for _ in range(6):
        failed = attempt(order)
        if best is None or len(failed) < len(best[0]):
            best = (failed, list(order))
        if not failed:
            break
        order = failed + [t for t in order if t not in failed]
    if best[0] != failed:
        attempt(best[1])

    # prune dead ends left by removed branches
    changed = True
    while changed:
        changed = False
        for p in list(g):
            if len(g[p]) <= 1 and p not in ends and p not in MANUAL:
                for q in list(g[p]):
                    unlink(p, q)
                del g[p]
                changed = True

    # ---- pipe atoms ----------------------------------------------------------------
    par = parents()
    new = {}
    for p, nb in g.items():
        if p in MANUAL:
            new[p] = MANUAL[p]
            continue
        ports = sum(direction(p, q) for q in nb)
        n = len(nb)
        if p in ends:
            assert n == 1, (p, nb)
            new[p] = (PIPE + 'trunk', {'dir': str(ports)})
        elif n == 2:
            d = 2 if ports == 3 else 4 if ports == 12 else ports
            new[p] = (PIPE + 'segment', {'dir': str(d)})
        else:
            assert n == 3, (p, nb)
            ex = direction(p, succ[p] if p in ringset else par[p])
            kinds = ((PIPE + 'sortjunction', PIPE + 'sortjunction/reversed') if p in sort else
                     (PIPE + 'junction', PIPE + 'junction/reversed', PIPE + 'junction/yjunction'))
            typ = next((k for k in kinds if mask(k, ex) == ports), None)
            assert typ, (p, ports, ex)
            v = {'dir': str(ex)}
            if p in sort:
                v['sortType'] = str(sort[p])
            new[p] = (typ, v)

    # ---- trace -----------------------------------------------------------------------
    def trace(start, tag):
        p, incoming = start, 16
        for _ in range(1000):
            typ, v = new[p]
            d = int(v['dir'])
            ports = mask(typ, d)
            if typ.endswith('trunk'):
                if incoming != 16:
                    return p
                ex = d
            elif '/sortjunction' in typ:
                side = ports & ~(d | REVERSE[d])
                if int(v['sortType']) == tag and incoming != side:
                    ex = side
                elif incoming == REVERSE[d]:
                    return f'bounces at {p[:2]}'
                else:
                    ex = d
            elif '/junction' in typ:
                if REVERSE[incoming] == d:
                    return f'random junction at {p[:2]}'
                ex = d
            else:
                ex = ports & ~REVERSE[incoming]
            q = step(p, ex)
            if q not in new or not mask(new[q][0], int(new[q][1]['dir'])) & REVERSE[ex]:
                return f'broken {p[:2]} -> {q[:2]}'
            p, incoming = q, ex
        return 'loops'

    targets = {tag: next(p for p, t in sort.items() if t == tag) for tag in set(sort.values())}
    dest = {}
    for tag, r in targets.items():
        dest[tag] = trace(CHUTE, tag)
    senders = sorted(p for p in g if p in ends and p != OUTLET_CELL and p != (75, 132, 1))
    fails = []
    for b in senders:
        if trace(b, 1) != OUTLET_CELL:
            fails.append(f'trash from {b[:2]}: {trace(b, 1)}')
        for tag in targets:
            got = trace(b, tag)
            if got != dest[tag]:
                fails.append(f'tag {tag} from {b[:2]}: {got} (chute gives {dest[tag]})')
    if trace(CHUTE, 0) != OUTLET_CELL:
        fails.append(f'untagged from the chute: {trace(CHUTE, 0)}')
    for tag, end in sorted(dest.items()):
        area_name = area(end) if isinstance(end, tuple) else end
        print(f'{tag:2d} {TAGS[tag - 1]:20s} -> {end[:2] if isinstance(end, tuple) else end} {area_name}')
    print(f'ring {len(ring)} cells, link {len(path) - 1} new, branches re-laid/added '
          f'{sum(1 for t in TARGETS if t in targets)} served, new bins {[p[:2] for p in new_bins]}')
    for r in report:
        print('UNSERVED', r)
    for r in fails:
        print('FAIL', r)
    if fails or any(int(r.split()[0]) not in KNOWN_UNSERVED for r in report):
        return 1

    if write:
        touched = (comp | set(g)) - occupied
        for p in sorted(touched):
            old = m.get_tile(p)
            out = [a for a in old if not parse_map_atom(a)[0].startswith(PIPE)]
            if p in new_bins:
                out.insert(0, '/obj/machinery/disposal')
            if p in new:
                i = next(i for i, a in enumerate(out) if a.startswith('/turf'))
                out.insert(i, atom(*new[p]))
            if tuple(out) != tuple(old):
                m.set_tile(p, out)
        m.to_file(str(MAP))
        print('written')
    return 0


if __name__ == '__main__':
    sys.exit(main())
