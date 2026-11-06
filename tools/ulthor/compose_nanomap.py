"""Compose runtime-exported BYOND appearances into a full-resolution map screenshot."""
from pathlib import Path
import sys,json,math,argparse
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tmp/python-deps'))
from PIL import Image,ImageChops
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('run_directory',type=Path)
args=parser.parse_args()
run=args.run_directory.resolve()
snapshot=run/'data/ulthor_mapshot/snapshot.json'
data=json.loads(snapshot.read_text(encoding='utf-8-sig').strip().splitlines()[-1])
width=data['width']*32;height=data['height']*32
canvas=Image.new('RGBA',(width,height),(0,0,0,255))
sprites={int(s['id']):Image.open(run/s['path']).convert('RGBA') for s in data['sprites']}
transformed={}
placements=sorted(data['placements'],key=lambda p:(p['plane'],p['layer']))
for p in placements:
    sid=int(p['sprite'])
    if sid not in sprites:continue
    source=sprites[sid]
    sx=p.get('scale_x',1);sy=p.get('scale_y',1);rotation=p.get('rotation',0)
    if abs(sx)<0.001 or abs(sy)<0.001:continue
    key=(sid,sx,sy,rotation)
    if key not in transformed:
        im=source
        if abs(sx-1)>0.001 or abs(sy-1)>0.001:
            im=im.resize((max(1,round(im.width*abs(sx))),max(1,round(im.height*abs(sy)))),Image.Resampling.NEAREST)
        if sx<0:im=im.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
        if sy<0:im=im.transpose(Image.Transpose.FLIP_TOP_BOTTOM)
        if abs(rotation)>0.001:im=im.rotate(-rotation,resample=Image.Resampling.NEAREST,expand=True)
        transformed[key]=im
    im=transformed[key]
    x=(p['x']-1)*32+p['pixel_x']+p.get('shift_x',0)-(im.width-source.width)/2
    bottom=(p['y']-1)*32+p['pixel_y']+p.get('shift_y',0)-(im.height-source.height)/2
    x=round(x);y=round(height-bottom-im.height)
    # All captured visible sprites use ordinary alpha overlays. Emissive lighting planes
    # are intentionally excluded, as in the game's full-bright photography mode.
    if p['blend']==2: # BYOND BLEND_ADD
        bounds=(max(0,x),max(0,y),min(width,x+im.width),min(height,y+im.height))
        if bounds[2]<=bounds[0] or bounds[3]<=bounds[1]:continue
        patch=im.crop((bounds[0]-x,bounds[1]-y,bounds[2]-x,bounds[3]-y))
        base=canvas.crop(bounds)
        added=ImageChops.add(base.convert('RGB'),patch.convert('RGB')).convert('RGBA')
        canvas.paste(added,bounds[:2],patch.getchannel('A'))
    else:
        canvas.alpha_composite(im,(x,y))
output=ROOT/'icons/_nanomaps/Ulthor_nanomap_z1.png'
preview=canvas.convert('RGB').resize((data['width']*8,data['height']*8),Image.Resampling.LANCZOS)
preview.save(output,optimize=True)
print('Saved',output,'size',preview.size,'sprites',len(sprites),'placements',len(placements))
