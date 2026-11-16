"""Overview of Ulthor power: red = layer-2 grid nets, yellow = layer-1 SMES inputs,
yellow frame = APC, magenta frame = SMES/terminal. Usage: map out.png x0 y0 x1 y1 scale"""
import sys;sys.path.insert(0,'tools/ulthor')
from power_audit import *
from PIL import Image, ImageDraw
def draw(mapfile,out,x0=30,y0=70,x1=205,y1=215,s=8):
    _,t=load(mapfile)
    nets=networks(t); owner={p:i for i,n in enumerate(nets) for p in n}
    im=Image.new('RGB',((x1-x0+1)*s,(y1-y0+1)*s),'black');d=ImageDraw.Draw(im)
    for (x,y,z),a in t.items():
        if not(x0<=x<=x1 and y0<=y<=y1):continue
        c=classify(a);ar=path(a[-1])
        col={'space':'#000010','wall':'#777','window':'#357'}.get(c)
        if not col:
            col='#1a3a90' if '/hallway' in ar else '#1a6a2a' if '/maintenance' in ar else '#333'
            if any(path(o).startswith('/obj/machinery/door/airlock') for o in a): col='#bbb'
        px,py=(x-x0)*s,(y1-y)*s
        d.rectangle((px,py,px+s-1,py+s-1),fill=col)
        if (x,y,z) in owner:
            i=owner[(x,y,z)]; cc='#ff3030' if i==0 else ((i*83+80)%156+100,(i*137+10)%156+100,(i*53)%200)
            d.rectangle((px+2,py+2,px+s-3,py+s-3),fill=cc)
        if any(path(o).startswith('/obj/machinery/power/apc') for o in a): d.rectangle((px,py,px+s-1,py+s-1),outline='yellow',width=2)
        if any(path(o).startswith(('/obj/machinery/power/smes','/obj/machinery/power/terminal')) for o in a): d.rectangle((px,py,px+s-1,py+s-1),outline='magenta',width=2)
    for (x,y,z) in set().union(*networks(t,1)) if networks(t,1) else []:
        if x0<=x<=x1 and y0<=y<=y1:
            px,py=(x-x0)*s,(y1-y)*s; d.rectangle((px+3,py+3,px+s-4,py+s-4),fill='#ffd000')
    for x in range(x0,x1+1,10):
        d.line(((x-x0)*s,0,(x-x0)*s,im.height),fill='#602020'); d.text(((x-x0)*s+1,1),str(x),fill='red')
    for y in range(y0 - y0%10 + 10,y1+1,10):
        d.line((0,(y1-y)*s,im.width,(y1-y)*s),fill='#602020'); d.text((1,(y1-y)*s+1),str(y),fill='red')
    im.save(out)
if __name__=='__main__':
    a=sys.argv; draw(Path(a[1]),a[2],*map(int,a[3:]))
