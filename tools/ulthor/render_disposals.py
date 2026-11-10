"""Static diagnostic sheets: real DMI frames on schematic map tiles and pipe routes."""
from pathlib import Path
from PIL import Image, ImageDraw
from check_disposals import ROOT, MAP, DMM, inventory, mask, DELTA, step
from render_layout import dmi


def main():
    out = ROOT / 'docs/ulthor_disposals'
    out.mkdir(exist_ok=True)
    tiles, pipes, bins, outlets = inventory(DMM.from_file(MAP))
    sheet = Image.new('RGB', (4 * 240, 260), '#18212b')
    draw = ImageDraw.Draw(sheet)
    frames = dmi('icons/goonstation/objects/disposal_wall.dmi')
    examples = [(80, 103, 1), (126, 102, 1), (95, 118, 1), (111, 187, 1)]
    for i, p in enumerate(examples):
        panel = Image.new('RGBA', (96, 96), '#30363d')
        pd = ImageDraw.Draw(panel)
        for dy in range(-1, 2):
            for dx in range(-1, 2):
                q = (p[0] + dx, p[1] + dy, 1)
                wall = any(t.startswith('/turf/simulated/wall') for t, v in tiles[q])
                x, y = (dx + 1) * 32, (1 - dy) * 32
                pd.rectangle((x, y, x + 31, y + 31), fill='#8e9ca7' if wall else '#414c55', outline='#222c34')
        _, values = bins[p]
        direction = int(values['dir'])
        index = {2: 0, 1: 1, 4: 2, 8: 3}[direction]
        y = 32 - int(values.get('pixel_y', '0'))
        for state in ['disposal', 'disposal-handle', 'disposal-ready']:
            panel.alpha_composite(frames[state][index], (32, y))
        sheet.paste(panel.resize((192, 192), Image.Resampling.NEAREST), (i * 240 + 20, 38))
        draw.text((i * 240 + 20, 12), f'{p[0]},{p[1]}  dir={direction}', fill='white')
    draw.text((20, 240), 'Actual DMI + mapped offsets; schematic walls/floors (not an in-game screenshot)', fill='#d0d7de')
    sheet.save(out / 'wall-bins.png')
    scale = 6
    plan = Image.new('RGB', (150 * scale, 120 * scale), '#101820')
    pd = ImageDraw.Draw(plan)
    def point(p):
        return (p[0] - 50) * scale + scale // 2, (200 - p[1]) * scale + scale // 2
    for p, atoms in tiles.items():
        if not (50 <= p[0] < 200 and 81 <= p[1] <= 200):
            continue
        x, y = point(p)
        typ = next(t for t, v in atoms if t.startswith('/turf'))
        color = '#515c66' if '/wall' in typ else '#29343e' if '/floor' in typ else '#101820'
        pd.rectangle((x-3, y-3, x+2, y+2), fill=color)
    for p, (typ, values) in pipes.items():
        ports = mask(typ, int(values['dir']))
        x, y = point(p)
        for d in DELTA:
            if ports & d:
                pd.line((x, y, *point(step(p, d))), fill='#f3b84c', width=2)
    for p in bins:
        x, y = point(p)
        pd.ellipse((x-3, y-3, x+3, y+3), fill='#6bd6ff')
    for p in outlets:
        x, y = point(p)
        pd.rectangle((x-4, y-4, x+4, y+4), fill='#70ff92')
        pd.text((x+6, y-10), f'{p[0]},{p[1]}', fill='white')
    plan.save(out / 'pipe-network.png')


if __name__ == '__main__':
    main()
