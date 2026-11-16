"""Static air-distribution audit for Ulthor (read-only).

Reports:
  * open ends of supply/scrubber pipes (a branch with no vent or scrubber);
  * vents/scrubbers that are not on the main distro / waste network;
  * per area: floor tiles, vents, scrubbers, air alarms and the norm
    ceil(tiles / 30) vents and scrubbers;
  * area/alarm binding: an air alarm drives every vent and scrubber whose
    tile is in the alarm's own area (code/game/machinery/alarm.dm,
    alarm_area = get_area(src)), so areas with vents need an alarm, and an
    area split into several disconnected rooms lets one alarm drive vents
    in another room.

Usage: python -I tools/ulthor/vent_audit.py [map] [--json out.json]
"""
import json
import math
import re
import sys
from collections import defaultdict, deque
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
sys.path.insert(0, str(ROOT / 'tools/ulthor'))
from dmm import DMM  # noqa: E402
from rooms import Station, CARD, area, turf, is_floor, is_boundary  # noqa: E402
from check_pipes import parse, DELTA, REV  # noqa: E402

TILES_PER_UNIT = 30
TILES_PER_UNIT_MAINT = 60
VENT = '/obj/machinery/atmospherics/unary/vent_pump'
SCRUB = '/obj/machinery/atmospherics/unary/vent_scrubber'
ALARM = '/obj/machinery/alarm'
# Areas that are not ventilated rooms (solar arrays, the reserved engine room).
SKIP = ('/area/space', '/area/shuttle', '/area/station/solars', '/area/station/engineering/ulthor_engine_room')
DEVICE = ('/obj/machinery/atmospherics/binary', '/obj/machinery/atmospherics/trinary',
          '/obj/machinery/atmospherics/omni', '/obj/machinery/atmospherics/unary')


def kind(a):
    p = a.split('{')[0]
    if p.startswith(VENT):
        return 'vent'
    if p.startswith(SCRUB):
        return 'scrubber'
    if p.startswith(ALARM):
        return 'alarm'
    return None


def load(path):
    m = DMM.from_file(str(path))
    return m, Station(m)


def pipe_graph(m):
    """Nodes: (x, y, i) for parsed pipe/unary atoms. Edges by matching dirs and connect types."""
    nodes = {}
    devices = set()
    for (x, y, z), k in m.grid.items():
        for i, a in enumerate(m.dictionary[k]):
            p = parse(a)
            if p:
                nodes[(x, y, i)] = p
            elif a.startswith(DEVICE):
                devices.add((x, y))
    by_tile = defaultdict(list)
    for n in nodes:
        by_tile[n[:2]].append(n)
    adj = defaultdict(set)
    open_ends = []
    for n, (path, dirs, ct) in nodes.items():
        for d, (dx, dy) in DELTA.items():
            if not dirs & d:
                continue
            t = (n[0] + dx, n[1] + dy)
            partners = [q for q in by_tile.get(t, []) if nodes[q][2] & ct and nodes[q][1] & REV[d]]
            for q in partners:
                adj[n].add(q)
            if not partners and t not in devices:
                open_ends.append((n, d))
    return nodes, adj, open_ends


def components(nodes, adj):
    comp = {}
    sizes = []
    for n in nodes:
        if n in comp:
            continue
        cid = len(sizes)
        q = deque([n])
        comp[n] = cid
        size = 0
        while q:
            c = q.popleft()
            size += 1
            for o in adj[c]:
                if o not in comp:
                    comp[o] = cid
                    q.append(o)
        sizes.append(size)
    return comp, sizes


def audit(path):
    m, st = load(path)
    nodes, adj, open_ends = pipe_graph(m)
    comp, sizes = components(nodes, adj)

    # Main networks: the largest component carrying supply / scrubber pipes.
    def main_net(word):
        best = None
        for n, (p, _, _) in nodes.items():
            if word in p and '/pipe/' in p:
                if best is None or sizes[comp[n]] > sizes[best]:
                    best = comp[n]
        return best
    supply_net, scrub_net = main_net('/supply'), main_net('/scrubbers')

    report = {'open_ends': [], 'detached': [], 'areas': {}, 'split_areas': [], 'rooms_multi_area': []}
    for (x, y, i), d in open_ends:
        p = nodes[(x, y, i)][0]
        if '/supply' in p or '/scrubbers' in p:
            report['open_ends'].append({'x': x, 'y': y, 'dir': d, 'type': p, 'area': area(st.tile(x, y))})

    # Gas chambers (rooms with an injector or a tank vent) are not ventilated.
    chamber = set()
    for comp_tiles in st.rooms():
        if any(any(a.startswith('/obj/machinery/atmospherics/unary/outlet_injector') or
                   (a.startswith(VENT) and 'id_tag' in a) for a in st.tile(*p)) for p in comp_tiles):
            chamber.update(comp_tiles)
    per_area = defaultdict(lambda: {'tiles': 0, 'vents': [], 'scrubbers': [], 'alarms': []})
    for (x, y, z), k in m.grid.items():
        t = m.dictionary[k]
        a = area(t)
        if is_floor(t) and not is_boundary(t) and (x, y) not in chamber:
            per_area[a]['tiles'] += 1
        for i, atom in enumerate(t):
            kd = kind(atom)
            if not kd:
                continue
            entry = per_area[a][kd + 's']
            entry.append([x, y, atom.split('{')[0]])
            if kd in ('vent', 'scrubber') and (x, y, i) in nodes:
                want = supply_net if kd == 'vent' else scrub_net
                if comp[(x, y, i)] != want:
                    # tank/airlock vents and vents on their own regular-pipe loop
                    own = 'id_tag' in atom or 'frequency' in atom or any(
                        1 in nodes[q][2] and '/supply' not in nodes[q][0] and '/scrubbers' not in nodes[q][0]
                        for q in adj[(x, y, i)])
                    report['detached'].append({'x': x, 'y': y, 'kind': kd, 'area': a, 'own_system': own,
                                               'net_size': sizes[comp[(x, y, i)]]})
    for a, r in sorted(per_area.items()):
        if a.startswith(SKIP) or not r['tiles']:
            continue
        per = TILES_PER_UNIT_MAINT if a.startswith('/area/station/maintenance') else TILES_PER_UNIT
        need = math.ceil(r['tiles'] / per)
        r['need'] = need
        r['missing_vents'] = max(0, need - len(r['vents']))
        r['missing_scrubbers'] = max(0, need - len(r['scrubbers']))
        r['no_alarm'] = bool(r['vents'] or r['scrubbers']) and not r['alarms']
        report['areas'][a] = r

    # Rooms (walkable, bounded by walls/doors) vs areas.
    rooms_of_area = defaultdict(list)
    for comp_tiles in st.rooms():
        areas = defaultdict(int)
        for p in comp_tiles:
            areas[area(st.tile(*p))] += 1
        for a in areas:
            rooms_of_area[a].append(len(comp_tiles))
        if len(areas) > 1:
            xs = [p[0] for p in comp_tiles]; ys = [p[1] for p in comp_tiles]
            report['rooms_multi_area'].append({'bbox': [min(xs), min(ys), max(xs), max(ys)], 'areas': dict(areas)})
    for a, rs in rooms_of_area.items():
        if len(rs) > 1 and a in report['areas']:
            report['split_areas'].append({'area': a, 'rooms': sorted(rs, reverse=True)})
    return report


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    target = Path(args[0]) if args else ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
    r = audit(target)
    short = lambda a: a.replace('/area/station/', '')
    print('open supply/scrubber pipe ends:', len(r['open_ends']))
    for e in r['open_ends']:
        print('  ', e['x'], e['y'], 'dir', e['dir'], e['type'].split('/')[-1], short(e['area']))
    stray = [e for e in r['detached'] if not e['own_system']]
    print('vents/scrubbers off the main network:', len(stray),
          f"(+{len(r['detached']) - len(stray)} on their own systems: tanks, airlocks, cooling loops)")
    for e in stray:
        print('  ', e)
    bad = {a: v for a, v in r['areas'].items() if v['missing_vents'] or v['missing_scrubbers'] or v['no_alarm']}
    print('areas below norm or without alarm:', len(bad), 'of', len(r['areas']))
    for a, v in bad.items():
        print(f"   {short(a):45} tiles={v['tiles']:4} need={v['need']} vents={len(v['vents'])} scrub={len(v['scrubbers'])} alarms={len(v['alarms'])}")
    print('areas split into several rooms:', len(r['split_areas']))
    for s in r['split_areas']:
        print('  ', short(s['area']), s['rooms'])
    if '--json' in sys.argv:
        out = Path(sys.argv[sys.argv.index('--json') + 1])
        out.write_text(json.dumps(r, indent=1) + '\n', encoding='utf-8')


if __name__ == '__main__':
    main()
