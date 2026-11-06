"""Rebuild Ulthor room footprints from authored room bounds and walk topology.

Reads a retained baseline, writes a candidate map. Never deletes directories.
The manifest is explicit: room bounds override distances, walls stop traversal,
and corridors/maintenance have their own seeds rather than borrowing room APCs.
"""
from collections import Counter
import heapq
import json
from pathlib import Path
import random
import sys

from layout_audit import ROOT, load, path
from check_map import parse_map_atom

OUT = ROOT / 'docs/ulthor_layout'
DIRS = ((0,1,1),(0,-1,2),(1,0,4),(-1,0,8))


def neighbors(p):
    x,y,z=p
    return [(x+dx,y+dy,z) for dx,dy,d in DIRS]


def main():
    random.seed(106)
    m, tiles=load(OUT/'before.dmm')
    parsed={p:[parse_map_atom(a) for a in t] for p,t in tiles.items()}
    def in_scope(p):
        x,y,z=p
        return (65<=x<=104 and 133<=y<=186) or (139<=x<=167 and 119<=y<=166)
    floor={p for p,t in parsed.items() if in_scope(p) and any(a.startswith('/turf/simulated/floor') for a,v in t) and not path(tiles[p][-1]).startswith('/area/shuttle')}
    area={p:tiles[p][-1] for p in floor}
    apcs={p:tiles[p][-1] for p,t in parsed.items() if p in floor and any(a.startswith('/obj/machinery/power/apc') for a,v in t)}
    definitions={}
    fixed={}
    seeds=dict(apcs)

    def zone(parent,slug,name,icon):
        typ=parent+'/ulthor_'+slug
        definitions[typ]={'name':name,'icon_state':icon}
        return typ

    def paint(typ,box):
        x0,y0,x1,y1=box
        for p in floor:
            x,y,z=p
            if x0<=x<=x1 and y0<=y<=y1:
                fixed[p]=typ

    def existing(suffix):
        return next(tiles[p][-1] for p,t in parsed.items() if any(a.startswith('/obj/machinery/power/apc') for a,v in t) and path(tiles[p][-1]).endswith('/'+suffix))

    # Interior bounds stop at walls. Shared perimeter walls are assigned below.
    # Service rooms in the supplied screenshots, including the two entertainer offices.
    rooms=[
        ('ulthor_72_141',(66,140,75,150)),
        ('ulthor_80_150',(76,140,85,150)),
        ('ulthor_82_155',(71,152,83,160)),
        ('ulthor_81_165',(76,162,81,167)),
        ('ulthor_87_165',(87,161,91,165)),
        ('ulthor_85_173',(77,173,84,181)),
        ('ulthor_86_180',(86,178,89,183)),
        ('ulthor_89_175',(87,173,89,176)),
        ('ulthor_91_176',(91,173,96,182)),
        ('ulthor_100_175',(100,173,104,178)),
        ('ulthor_104_164',(104,163,107,167)),
        ('ulthor_106_160',(106,158,110,161)),
        ('ulthor_96_166',(96,163,98,167)),
        ('barber',(90,134,92,139)),
        ('ulthor_93_151',(90,150,93,152)),
        # Engineering, telecomms and research: the old nearest-APC fill crossed
        # the long walls between these rooms and the maintenance spine.
        ('ulthor_154_145',(150,142,154,146)),
        ('ulthor_149_129',(145,121,150,129)),
        ('ulthor_152_122',(151,121,154,124)),
        ('ulthor_158_119',(156,119,161,126)),
        ('ulthor_151_130',(151,125,155,140)),
        ('ulthor_163_93',(157,89,163,95)),
        ('ulthor_145_147',(142,147,146,149)),
        ('ulthor_141_152',(139,151,143,155)),
        ('ulthor_148_151',(145,151,148,155)),
        ('ulthor_coldroom',(160,147,162,149)),
        ('server',(163,147,164,149)),
        ('chargebay',(158,172,160,175)),
        ('rd',(165,161,168,166)),
        ('genetics',(165,147,175,160)),
        ('captain',(138,161,146,166)),
        ('bedroom',(137,157,143,159)),
        ('ulthor_153_164',(150,161,154,164)),
    ]
    for suffix,box in rooms:paint(existing(suffix),box)

    extra_rooms=[
        ('/area/station/service','mime_office','Ulthor Mime Office','mime_office',(89,157,94,159)),
        ('/area/station/service','costume_storage','Ulthor Costume Storage','Theatre',(95,150,97,152)),
        ('/area/station/service','bar_backroom','Ulthor Bar Backroom','barstation',(77,135,80,139)),
        ('/area/station/service','kitchen_coldroom','Ulthor Kitchen Coldroom','kitchen',(67,140,69,144)),
        ('/area/station/service','theatre','Ulthor Theatre','Theatre',(88,140,97,148)),
        ('/area/station/commons','bedroom_west_north','Ulthor North-West Bedroom','Sleep',(77,180,79,181)),
        ('/area/station/commons','bedroom_west_south','Ulthor West Bedroom','Sleep',(77,177,79,178)),
        ('/area/station/engineering','eva','Ulthor EVA Storage','eva',(99,163,102,167)),
        ('/area/station/engineering','tool_storage','Ulthor Engineering Equipment Storage','engine_storage',(156,128,159,134)),
        ('/area/station/engineering','monitoring','Ulthor Engineering Monitoring','engine_monitoring',(154,136,159,140)),
    ]
    for parent,slug,name,icon,box in extra_rooms:paint(zone(parent,slug,name,icon),box)

    # Public passage sections follow the actual three-tile-wide routes.
    corridors=[
        ('service_south','Ulthor Service South Hallway','hallF',(83,133,88,148)),
        ('service_east','Ulthor Service East Hallway','hallF',(99,135,102,160)),
        ('service_center','Ulthor Service Hallway','hallF',(84,149,88,160)),
        ('theatre_access','Ulthor Theatre Hallway','hallF',(89,153,98,156)),
        ('service_north','Ulthor North-West Hallway','hallF',(76,169,104,171)),
        ('eva_access','Ulthor EVA Access Hallway','hallF',(83,161,85,167)),
        ('west','Ulthor West Hallway','hallP',(86,105,88,132)),
        ('south','Ulthor South Hallway','hallA',(89,105,166,107)),
        ('east','Ulthor East Hallway','hallS',(169,117,171,166)),
        ('north','Ulthor North Hallway','hallF',(105,169,168,171)),
    ]
    # Only seed corridor floor; room bounds above retain priority.
    for slug,name,icon,box in corridors:
        typ=zone('/area/station/hallway',slug,name,icon)
        x0,y0,x1,y1=box
        for p in floor:
            x,y,z=p
            if x0<=x<=x1 and y0<=y<=y1 and p not in fixed:
                fixed[p]=typ

    # Bare plating is a maintenance route, not a continuation of the nearest
    # office. Section edges are authored at route junctions.
    maint={}
    for slug,name,icon in [('northwest','North-West','fpmaint'),('service','Service','pmaint'),('ai','AI','green'),('engineering','Engineering','green'),('research','Research','asmaint'),('north','North','fmaint'),('northeast','North-East','fsmaint'),('west','West','pmaint'),('southwest','South-West','apmaint'),('south','South','amaint'),('southeast','South-East','asmaint'),('east','East','smaint'),('central','Central','central')]:
        maint[slug]=zone('/area/station/maintenance',slug+'_passage','Ulthor '+name+' Maintenance',icon)
    for p in floor:
        if p in fixed:continue
        turf=next(a for a,v in parsed[p] if a.startswith('/turf'))
        if not turf.startswith('/turf/simulated/floor/plating'):continue
        x,y,z=p
        slug='northwest' if x<105 and y>=172 else 'west' if x<76 else 'service' if x<105 else 'research' if y>=150 else 'ai' if y>=141 else 'engineering'
        # Keep genuine plated machinery rooms, prisons and solar controls;
        # their existing areas are bounded by surrounding walls.
        old=path(area[p])
        if old.startswith(('/area/station/solars','/area/station/maintenance/solars','/area/station/maintenance/turbine','/area/station/security/prison','/area/station/engineering/atmos')):
            continue
        fixed[p]=maint[slug]

    # Existing APСs are authoritative only at their mounting tile, never across walls.
    for p,a in apcs.items():
        if p not in fixed:fixed[p]=a
    seeds.update(fixed)

    def theme(p):
        atom=next(a for a in tiles[p] if a.startswith('/turf'))
        typ,v=parse_map_atom(atom)
        return typ, v.get('icon_state','')

    def barrier(p):
        return any(a.startswith(('/obj/machinery/door/','/obj/structure/window','/obj/structure/grille')) for a,v in parsed[p])

    themes={p:theme(p) for p in floor}
    barriers={p for p in floor if barrier(p)}
    dist={p:0 for p in seeds}
    owner=dict(seeds)
    queue=[(0,p,a) for p,a in seeds.items()]
    heapq.heapify(queue)
    while queue:
        d,p,a=heapq.heappop(queue)
        if d!=dist.get(p) or a!=owner[p]:continue
        for n in neighbors(p):
            if n not in floor or n in seeds:continue
            cost=1 + (200 if n in barriers or p in barriers else 0) + (40 if themes[p]!=themes[n] else 0)
            nd=d+cost
            if nd<dist.get(n,10**12):
                dist[n]=nd;owner[n]=a;heapq.heappush(queue,(nd,n,a))

    # Enclosed unseeded compartments retain their original identity. Do not
    # jump through a wall or use Euclidean nearest-APC fallback.
    for p in floor:
        owner.setdefault(p,area[p])
    changed=0
    for p in floor:
        if owner[p]!=tiles[p][-1]:
            m.set_tile(p,tiles[p][:-1]+(owner[p],));changed+=1
    # A perimeter wall belongs to an adjacent interior. It cannot bridge zones.
    for p,t in tiles.items():
        if not in_scope(p) or p in floor or path(t[-1]).startswith(('/area/shuttle','/area/space')):continue
        turf=next(path(a) for a in t if a.startswith('/turf'))
        if '/wall' not in turf:continue
        near=[owner[n] for n in neighbors(p) if n in owner]
        if near:
            chosen=Counter(near).most_common(1)[0][0]
            if chosen!=t[-1]:m.set_tile(p,t[:-1]+(chosen,));changed+=1
    used={path(m.get_tile(p)[-1]) for p in m.grid}
    definitions={k:v for k,v in definitions.items() if k in used}
    (OUT/'candidate.dmm').write_bytes(m.to_bytes())
    (OUT/'new_areas.json').write_text(json.dumps(definitions,indent=2)+'\n',encoding='utf-8')
    print('Candidate area edits:',changed,'new areas:',len(definitions))


if __name__=='__main__':main()
