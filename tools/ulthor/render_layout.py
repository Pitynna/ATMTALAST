"""Static DMM review sheet. Reads DMI base frames; no game server is started."""
import ast
from collections import Counter
import json
import re
import subprocess
import sys
from PIL import Image, ImageDraw, ImageFont
from layout_audit import ROOT, load, path
from check_map import parse_map_atom

PROPS={}
for rel in subprocess.check_output(['git','ls-files','code/*.dm','code/**/*.dm'],cwd=ROOT,text=True).splitlines():
    p=ROOT/rel
    if not p.is_file():continue
    current=None
    for line in p.read_text(encoding='utf-8-sig',errors='replace').splitlines():
        if line.startswith('/'):
            current=line.split('//')[0].strip()
            if '(' in current or ' ' in current:current=None
        elif current and line.startswith('\t') and not line.startswith('\t\t'):
            z=re.match(r'\t(icon|icon_state|dir|pixel_x|pixel_y|layer|parent_type)\s*=\s*(.*)',line)
            if z:PROPS.setdefault(current,{})[z[1]]=z[2].split(' //')[0].strip()


def prop(typ,k):
    seen=set()
    while typ and typ not in seen:
        seen.add(typ)
        if k in PROPS.get(typ,{}):return PROPS[typ][k]
        typ=PROPS.get(typ,{}).get('parent_type',typ.rsplit('/',1)[0])


CACHE={}
def dmi(rel):
    if rel not in CACHE:
        try:
            im=Image.open(ROOT/rel).convert('RGBA')
            original=Image.open(ROOT/rel)
            desc=original.info.get('Description','')
            w=int(re.search(r'\bwidth = (\d+)',desc)[1]);h=int(re.search(r'\bheight = (\d+)',desc)[1]);cols=im.width//w
            frames={};off=0
            for b in re.split(r'\nstate = ',desc)[1:]:
                name=b.splitlines()[0].strip('"');dirs=int(re.search(r'dirs = (\d+)',b)[1]);count=int(re.search(r'frames = (\d+)',b)[1])
                frames[name]=[im.crop((((off+i)%cols)*w,((off+i)//cols)*h,((off+i)%cols+1)*w,((off+i)//cols+1)*h)) for i in range(dirs)]
                off+=dirs*count
            CACHE[rel]=frames
        except Exception:CACHE[rel]={}
    return CACHE[rel]


def sprite(atom):
    typ,v=parse_map_atom(atom)
    icon=v.get('icon',prop(typ,'icon'))
    state=v.get('icon_state',prop(typ,'icon_state'))
    if not icon or not icon.startswith("'") or not state or not state.startswith('"'):return None
    frames=dmi(icon.strip("'"))
    fr=frames.get(state.strip('"'))
    if not fr:return None
    direction=v.get('dir',prop(typ,'dir'))
    direct={'NORTH':1,'SOUTH':2,'EAST':4,'WEST':8}.get(direction,2)
    try:direct=int(direction or 2)
    except ValueError:pass
    di={2:0,1:1,4:2,8:3,6:4,10:5,5:6,9:7}.get(direct,0)
    return fr[min(di,len(fr)-1)]


def render(mapfile,box,out,zones=False):
    m,t=load(mapfile)
    x0,y0,x1,y1=box
    scale=32;pad=36
    im=Image.new('RGBA',((x1-x0+1)*scale+pad,(y1-y0+1)*scale+pad),'#111111')
    d=ImageDraw.Draw(im)
    for y in range(y1,y0-1,-1):
        for x in range(x0,x1+1):
            tile=t.get((x,y,1),())
            atoms=[a for a in tile if not a.startswith('/area')]
            atoms.sort(key=lambda a:0 if a.startswith('/turf') else 1 if a.startswith('/obj/structure/cable') else 2)
            px=(x-x0)*scale+pad;py=(y1-y)*scale+pad
            for a in atoms:
                if a.startswith('/obj/structure/cable'):
                    _,v=parse_map_atom(a)
                    banned=int(v.get('banned_links','0'))
                    for dx,dy,di,rev in [(0,1,1,2),(0,-1,2,1),(1,0,4,8),(-1,0,8,4)]:
                        other=t.get((x+dx,y+dy,1),())
                        cable=next((b for b in other if b.startswith('/obj/structure/cable')),None)
                        if not cable or banned&di:continue
                        _,nv=parse_map_atom(cable)
                        if int(nv.get('banned_links','0'))&rev:continue
                        smes=any(b.startswith('/obj/machinery/power/smes') for b in tile)
                        term=any(b.startswith('/obj/machinery/power/terminal') for b in tile)
                        if smes and any(b.startswith('/obj/machinery/power/terminal') for b in other):continue
                        if term and any(b.startswith('/obj/machinery/power/smes') for b in other):continue
                        d.line((px+16,py+16,px+16+dx*16,py+16-dy*16),fill='#fc3838',width=3)
                    continue
                s=sprite(a)
                if s:im.alpha_composite(s,(px,py+scale-s.height))
            if zones and tile and not any(a.startswith('/turf/space') for a in tile):
                area=path(tile[-1]);i=sum((n+1)*ord(c) for n,c in enumerate(area))
                color=(50+i*37%206,50+i*83%206,50+i*137%206,80)
                overlay=Image.new('RGBA',(scale,scale),color);im.alpha_composite(overlay,(px,py))
                for nx,ny,edge in [(x+1,y,(px+31,py,px+31,py+31)),(x,y+1,(px,py,px+31,py))]:
                    if (nx,ny,1) in t and path(t[nx,ny,1][-1])!=area:d.line(edge,fill='white',width=2)
            if any(a.startswith('/obj/machinery/power/apc') for a in tile):d.text((px+2,py+2),'A',fill='yellow',stroke_fill='black',stroke_width=1)
            if any(a.startswith('/obj/machinery/camera') for a in tile):d.text((px+17,py+2),'C',fill='cyan',stroke_fill='black',stroke_width=1)
    for x in range(x0,x1+1):d.text(((x-x0)*scale+pad,12),str(x),fill='white')
    for y in range(y0,y1+1):d.text((5,(y1-y)*scale+pad+8),str(y),fill='white')
    im.convert('RGB').save(out)


if __name__=='__main__':
    base=ROOT/'docs/ulthor_layout'
    file=ROOT/'_maps/map_files/Ulthor/Ulthor.dmm' if '--working' in sys.argv else base/('candidate.dmm' if '--candidate' in sys.argv else 'before.dmm')
    prefix='final' if '--working' in sys.argv else 'candidate' if '--candidate' in sys.argv else 'before'
    for name,box in [('service',(65,132,105,184)),('engineering',(139,117,169,158)),('science',(150,145,185,182)),('south',(72,88,174,133))]:
        render(file,box,base/f'{prefix}_{name}.png',True)
    print('Review sheets written:',prefix)
