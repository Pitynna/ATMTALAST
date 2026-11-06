"""Inventory room utilities and generate exact runtime registration checks."""
import json
from layout_audit import ROOT, load, path

KEYS={'apc':'/obj/machinery/power/apc','camera':'/obj/machinery/camera','airalarm':'/obj/machinery/alarm','firealarm':'/obj/machinery/firealarm','intercom':'/obj/item/radio/intercom','vent':'/obj/machinery/atmospherics/unary/vent_pump','scrubber':'/obj/machinery/atmospherics/unary/vent_scrubber','light':'/obj/machinery/light/','light_switch':'/obj/machinery/light_switch','firedoor':'/obj/machinery/door/firedoor','door_control':'/obj/machinery/door_control','holopad':'/obj/machinery/hologram/holopad','requests_console':'/obj/machinery/requests_console','status_display':'/obj/machinery/status_display','disposal':'/obj/machinery/disposal','disposal_pipe':'/obj/structure/disposalpipe'}


def main():
    out=ROOT/'docs/ulthor_layout'
    m,tiles=load(ROOT/'_maps/map_files/Ulthor/Ulthor.dmm')
    _,before=load(out/'before.dmm')
    affected={path(t[-1]) for p,t in tiles.items() if t[-1]!=before[p][-1]}|{path(before[p][-1]) for p,t in tiles.items() if t[-1]!=before[p][-1]}
    expected=[];inventory={};geometry=[]
    for p,atoms in tiles.items():
        a=path(atoms[-1]);r=inventory.setdefault(a,{k:[] for k in KEYS})
        if [v for v in atoms if v.startswith('/turf')]!=[v for v in before[p] if v.startswith('/turf')]:geometry.append(list(p))
        for o in atoms:
            typ=path(o)
            for key,prefix in KEYS.items():
                if typ.startswith(prefix):r[key].append(list(p))
            if a in affected and any(typ.startswith(KEYS[k]) for k in ['apc','camera','airalarm','firealarm','vent','scrubber','intercom']):expected.append({'x':p[0],'y':p[1],'area':a,'type':typ})
    # Another chat repaired this pre-existing floor hole while the layout was
    # being reviewed. Preserve that one external edit, and no other turf edit.
    assert geometry==[[81,134,1]],geometry
    (out/'fixture-expectations.json').write_text(json.dumps(expected,indent=2)+'\n',encoding='utf-8')
    (out/'inventory.json').write_text(json.dumps(inventory,indent=2)+'\n',encoding='utf-8')
    (out/'geometry.json').write_text(json.dumps({'own_geometry_edits':0,'preserved_external_floor_repairs':geometry,'affected_areas':sorted(affected)},indent=2)+'\n',encoding='utf-8')
    print('Expected fixtures:',len(expected),'affected areas:',len(affected),'own geometry edits: 0')


if __name__=='__main__':main()
