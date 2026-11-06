"""Inspect physical room components without modifying the map."""
from collections import Counter, deque
from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools/mapmerge2"))
from dmm import DMM
from PIL import Image, ImageDraw


def load(path):
    m = DMM.from_file(path)
    return m, {tuple(p): m.get_tile(p) for p in m.grid}


def path(atom):
    return atom.split("{", 1)[0]


def blocked(tile):
    types = [path(a) for a in tile]
    turf = next(a for a in types if a.startswith("/turf"))
    return not turf.startswith("/turf/simulated/floor") or any(
        a.startswith(("/obj/machinery/door", "/obj/structure/window", "/obj/structure/grille"))
        and not a.startswith("/obj/machinery/door_control") for a in types)


def components(tiles):
    todo = {p for p, t in tiles.items() if not blocked(t)}
    result = []
    while todo:
        seed = min(todo)
        todo.remove(seed)
        found = {seed}
        queue = deque([seed])
        while queue:
            x, y, z = queue.popleft()
            for p in ((x-1,y,z),(x+1,y,z),(x,y-1,z),(x,y+1,z)):
                if p in todo:
                    todo.remove(p)
                    found.add(p)
                    queue.append(p)
        result.append(found)
    return sorted(result, key=lambda c: min(c))


def main():
    m, tiles = load(ROOT / "_maps/map_files/Ulthor/Ulthor.dmm")
    rooms = components(tiles)
    report = []
    scale = 12
    im = Image.new("RGB", (255*scale,255*scale), "#111111")
    draw = ImageDraw.Draw(im)
    for i, room in enumerate(rooms):
        color = ((i*83+80)%190+50,(i*137+10)%190+50,(i*193+20)%190+50)
        zones = Counter(path(tiles[p][-1]) for p in room)
        fixtures = []
        for p in sorted(room):
            x,y,z = p
            draw.rectangle(((x-1)*scale,(255-y)*scale,x*scale-1,(256-y)*scale-1),fill=color)
            for a in tiles[p]:
                if path(a).startswith(("/obj/machinery/power/apc", "/obj/machinery/camera", "/obj/machinery/alarm", "/obj/machinery/firealarm")):
                    fixtures.append([list(p),a])
                    if "/apc" in a:
                        draw.text(((x-1)*scale,(255-y)*scale),"A",fill="black")
        bounds = [min(p[0] for p in room),min(p[1] for p in room),max(p[0] for p in room),max(p[1] for p in room)]
        if len(room)>5:
            center=min(room,key=lambda p:abs(p[0]-(bounds[0]+bounds[2])/2)+abs(p[1]-(bounds[1]+bounds[3])/2))
            draw.text(((center[0]-1)*scale,(255-center[1])*scale),str(i),fill="black",stroke_width=1,stroke_fill="white")
        report.append(dict(id=i,size=len(room),bounds=bounds,zones=dict(zones),fixtures=fixtures))
    for (x,y,z), t in tiles.items():
        if blocked(t):
            turf=next(path(a) for a in t if a.startswith('/turf'))
            color = '#bbbbbb' if '/wall' in turf else '#555555' if '/floor' in turf else '#111111'
            if any(path(a).startswith('/obj/machinery/door/') for a in t):color='#ffffff'
            draw.rectangle(((x-1)*scale,(255-y)*scale,x*scale-1,(256-y)*scale-1),fill=color)
    out = ROOT/'docs/ulthor_layout'
    out.mkdir(exist_ok=True)
    im.save(out/'components.png')
    (out/'components.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('Physical components:',len(rooms))
    for r in report:
        if r['size']>12:
            print(r['id'],r['size'],r['bounds'],'; '.join(f'{k.rsplit("/",1)[-1]}:{v}' for k,v in r['zones'].items()),'APCs:',sum('/apc' in a for p,a in r['fixtures']))


if __name__ == '__main__':
    main()
