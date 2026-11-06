"""Complete the reviewed zone candidate with connected room utilities.

Only writes candidate files in docs/ulthor_layout. Existing turfs, furniture,
devices and SMES cable separation are retained. No server or cleanup is invoked.
"""
from collections import Counter, deque
import json
import random
from layout_audit import ROOT, load, path
from check_map import parse_map_atom
from repair_layout import OUT, DIRS, neighbors
from render_layout import prop


def direction(p,q):
    dx,dy=q[0]-p[0],q[1]-p[1]
    return next(d for x,y,d in DIRS if (x,y)==(dx,dy))


def atom(typ,**edits):
    return typ+('{'+';'.join(k+' = '+str(v) for k,v in edits.items())+'}' if edits else '')


def main():
    random.seed(107)
    m,original=load(OUT/'candidate.dmm')
    _,before=load(OUT/'before.dmm')
    tiles={p:list(t) for p,t in original.items()}
    definitions=json.loads((OUT/'new_areas.json').read_text())
    additions=[]
    changed_areas={path(t[-1]) for p,t in tiles.items() if t[-1]!=before[p][-1]}
    # All area membership changes must be audited, including the cargo office
    # whose original APC belongs physically to the service access hallway.
    changed_areas|={path(before[p][-1]) for p,t in tiles.items() if t[-1]!=before[p][-1]}
    changed_areas-={'/area/space'}
    areas={}
    for p,t in tiles.items():
        if any(a.startswith('/turf/simulated/floor') for a in t):areas.setdefault(path(t[-1]),[]).append(p)

    def add(p,a):
        tiles[p].insert(0,a)
        additions.append({'position':list(p),'atom':a,'area':path(tiles[p][-1])})

    def objects(a,prefix):
        return [(p,o) for p in areas[a] for o in tiles[p] if o.startswith(prefix)]

    def name(a):
        if a in definitions:return definitions[a]['name']
        return (prop(a,'name') or '"'+a.rsplit('/',1)[-1]+'"').strip('"')

    def occupied(p):
        return any(o.startswith(('/obj/machinery/door/','/obj/structure/window','/obj/structure/grille')) for o in tiles[p])

    def wallmount(a):
        points=[]
        for p in areas[a]:
            if occupied(p):continue
            if any(o.startswith(('/obj/machinery/power/apc','/obj/machinery/camera','/obj/machinery/firealarm','/obj/machinery/alarm','/obj/item/radio/intercom')) for o in tiles[p]):continue
            for n in neighbors(p):
                if n in tiles and any(o.startswith(('/turf/simulated/wall','/obj/structure/window/reinforced','/obj/structure/window/full')) for o in tiles[n]):
                    points.append((p,direction(p,n)))
        if not points:
            raise ValueError('No unoccupied wall mount in '+a)
        # Prefer a cable-fed mounting location, then an uncluttered wall cell.
        points.sort(key=lambda pd:(not any(o.startswith('/obj/structure/cable') for o in tiles[pd[0]]),len(tiles[pd[0]]),pd))
        return points[0]

    def mount(a,typ,**edits):
        p,d=wallmount(a)
        dx,dy=next((x,y) for x,y,di in DIRS if di==d)
        edits.update(dir=d,pixel_x=dx*24,pixel_y=dy*24)
        add(p,atom(typ,**edits))
        return p

    # Static cable graph follows the modern cardinal auto-connect rules,
    # preserving banned links and separating each SMES from its input terminal.
    cables={p for p,t in tiles.items() if any(o.startswith('/obj/structure/cable') for o in t)}
    smes={p for p,t in tiles.items() if any(o.startswith('/obj/machinery/power/smes') for o in t)}
    terminals={p for p,t in tiles.items() if any(o.startswith('/obj/machinery/power/terminal') for o in t)}
    bans={p:int(next((parse_map_atom(o)[1].get('banned_links','0') for o in tiles[p] if o.startswith('/obj/structure/cable')),'0')) for p in cables}
    components=[];todo=set(cables)
    while todo:
        start=min(todo);todo.remove(start);q=[start];found={start}
        for p in q:
            for n in neighbors(p):
                if n not in todo:continue
                d=direction(p,n);rev=direction(n,p)
                if bans[p]&d or bans[n]&rev:continue
                if (p in smes and n in terminals) or (n in smes and p in terminals):continue
                todo.remove(n);found.add(n);q.append(n)
        components.append(found)
    mainnet=max(components,key=len)
    forbidden=(cables-mainnet)|smes|terminals
    # A new branch must not bridge into an input circuit merely by adjacency.
    forbidden|={n for p in cables-mainnet for n in neighbors(p)}

    def traversable(p):
        return p in tiles and any(o.startswith('/turf/simulated/') for o in tiles[p])

    def route(start,targets,avoid=()):
        q=deque([start]);prev={start:None};avoid=set(avoid)
        while q:
            p=q.popleft()
            if p in targets:
                result=[]
                while p is not None:result.append(p);p=prev[p]
                return result[::-1]
            for n in neighbors(p):
                if n not in prev and n not in avoid and traversable(n):prev[n]=p;q.append(n)
        raise ValueError('No utility route from '+str(start))

    def connect_apc(p):
        if p not in mainnet:
            branch=route(p,mainnet,forbidden)
            if len(branch)>35:raise ValueError('Unreasonably long APC branch '+str(branch))
            for n in branch:
                if n not in cables:add(n,'/obj/structure/cable');cables.add(n)
                mainnet.add(n)

    # Read/extend real port masks rather than laying disconnected pipe sprites.
    def pipebits(o):
        typ,v=parse_map_atom(o);d=int(v.get('dir','2'))
        if '/manifold4w/' in typ:return 15
        if '/manifold/' in typ:return 15^d
        return 3 if d in (1,2) else 12 if d in (4,8) else d

    def pipeatom(bits,family):
        if bits==15:return '/obj/machinery/atmospherics/pipe/manifold4w/hidden/'+family
        if bits.bit_count()==3:return atom('/obj/machinery/atmospherics/pipe/manifold/hidden/'+family,dir=15^bits)
        return atom('/obj/machinery/atmospherics/pipe/simple/hidden/'+family,dir=2 if bits==3 else 4 if bits==12 else bits)

    def family_pipes(family):
        return {p:next(o for o in t if o.startswith('/obj/machinery/atmospherics/pipe/') and path(o).endswith('/'+family)) for p,t in tiles.items() if any(o.startswith('/obj/machinery/atmospherics/pipe/') and path(o).endswith('/'+family) for o in t)}

    def atmosphere(a,kind):
        family='supply' if kind=='vent_pump' else 'scrubbers'
        pipes=family_pipes(family)
        # Select an indoor tile with clear access, close to an existing trunk.
        candidates=[p for p in areas[a] if not occupied(p) and not any(o.startswith('/obj/machinery/atmospherics/unary/') for o in tiles[p])]
        if not candidates:raise ValueError('No atmospheric fixture slot in '+a)
        source=min(candidates,key=lambda p:(min(abs(p[0]-n[0])+abs(p[1]-n[1]) for n in pipes),len(tiles[p]),p))
        # The unary occupies its tile; it connects to an adjacent pipe, not
        # to a pipe stacked directly underneath itself.
        targets=set(pipes)-{source}
        branch=route(source,targets)
        if len(branch)>35:raise ValueError('Unreasonably long atmospheric branch '+str(branch))
        if source in pipes:
            # Existing trunk on the proposed device tile: choose its free neighbor.
            candidates=[p for p in candidates if p not in pipes]
            if not candidates:raise ValueError('Atmos fixtures would stack on trunks in '+a)
            source=min(candidates,key=lambda p:(min(abs(p[0]-n[0])+abs(p[1]-n[1]) for n in pipes),p))
            branch=route(source,set(pipes))
        add(source,atom('/obj/machinery/atmospherics/unary/'+kind+('/on' if kind=='vent_pump' else ''),dir=direction(branch[0],branch[1]),**({} if kind=='vent_pump' else {'on':1})))
        for i,p in enumerate(branch[1:],1):
            bits=direction(p,branch[i-1])
            if i+1<len(branch):bits|=direction(p,branch[i+1])
            if p in pipes:
                old=pipes[p];bits|=pipebits(old);tiles[p].remove(old)
            replacement=pipeatom(bits,family)
            add(p,replacement)

    for a in sorted(changed_areas):
        if a not in areas or a.startswith(('/area/shuttle','/area/station/solars','/area/space')):continue
        if not objects(a,'/obj/machinery/power/apc'):
            p=mount(a,'/obj/machinery/power/apc');connect_apc(p)
        if not objects(a,'/obj/machinery/camera'):
            # Camera remains on the room side of its mounting wall.
            mount(a,'/obj/machinery/camera',c_tag=json.dumps(name(a)+' CCTV'),network='list("SS13")')
        for typ in ['/obj/machinery/firealarm','/obj/machinery/alarm']:
            if not objects(a,typ):mount(a,typ)
        maintenance=a.startswith('/area/station/maintenance')
        special=a.startswith('/area/station/ai/')
        if not maintenance and not special:
            for kind in ['vent_pump','vent_scrubber']:
                if not objects(a,'/obj/machinery/atmospherics/unary/'+kind):atmosphere(a,kind)
        staffed=not maintenance and not any(s in a for s in ('bedroom','coldroom','storage','costume','eva','ulthor_96_166','ulthor_89_175'))
        if staffed and not objects(a,'/obj/item/radio/intercom'):
            mount(a,'/obj/item/radio/intercom')

    for p,t in tiles.items():m.set_tile(p,t)
    (OUT/'equipped.dmm').write_bytes(m.to_bytes())
    (OUT/'additions.json').write_text(json.dumps(additions,indent=2)+'\n',encoding='utf-8')
    counts=Counter(path(x['atom']) for x in additions)
    print('Added connected equipment:',dict(counts))


if __name__=='__main__':main()
