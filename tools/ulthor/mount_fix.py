"""Move Ulthor wall mounts off windows, doors and thin air (user, 2026-11-19).

Uses mount_audit.py. Each bad mount moves to the nearest free face of a solid
wall in the same room: first another side of its own tile, then floor tiles
up to 4 steps away. /directional/ types change their side suffix; offset
types keep their offset size and point it at the new wall. External airlock
buttons (they stand outside by design) and maintenance (user keeps it as
is) are left alone. One-time; re-running finds nothing to do.
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import hall_decor as H  # noqa: E402
import mount_audit as A  # noqa: E402

NAME = {'N': 'north', 'S': 'south', 'E': 'east', 'W': 'west'}
VEC = {'N': (0, 1), 'S': (0, -1), 'E': (1, 0), 'W': (-1, 0)}


def moved(atom, old, new):
    b = H.base(atom)
    if old is None:  # stood on a window tile with no offset
        if b in ('/obj/item/radio/intercom', '/obj/machinery/firealarm', '/obj/machinery/alarm', '/obj/machinery/light_switch',
                 '/obj/machinery/newscaster', '/obj/structure/extinguisher_cabinet', '/obj/machinery/power/apc'):
            return b + '/directional/' + NAME[new] + (atom[len(b):] if '{' in atom else '')
        atom = b + '{' + ';'.join(x for x in [(atom.split('{', 1)[1][:-1] if '{' in atom else ''), 'pixel_y = 32'] if x) + '}'
    if '/directional/' in b:
        return atom.replace('/directional/' + NAME[old], '/directional/' + NAME[new], 1)
    px = re.search(r'pixel_x = (-?\d+)', atom)
    py = re.search(r'pixel_y = (-?\d+)', atom)
    mag = max(abs(int(px[1])) if px else 0, abs(int(py[1])) if py else 0)
    body = atom.split('{', 1)[1][:-1] if '{' in atom else ''
    parts = [p for p in body.split(';') if p.strip() and not p.strip().startswith(('pixel_x', 'pixel_y'))]
    dx, dy = VEC[new]
    if dx:
        parts.append(f'pixel_x = {dx * mag}')
    if dy:
        parts.append(f'pixel_y = {dy * mag}')
    return b + '{' + ';'.join(parts) + '}'


def spot_ok(M, q, area, s, origin):
    """Same room, same kind of floor (no jumping from a tiled room into a plating chamber), solid free wall."""
    if M.window(origin):  # from a window tile: only onto the room's tiled floor
        same_floor = H.base(M.turf(q)).startswith('/turf/simulated/floor/plasteel')
    else:
        same_floor = H.base(M.turf(q)) == H.base(M.turf(origin))
    return M.area(q) == area and same_floor and M.floor(q) and not M.door(q) and H.face_free(M, q, s) and \
        not any(H.base(a).startswith(('/obj/machinery/vending', '/obj/machinery/computer', '/obj/machinery/mass_driver',
                                      '/obj/item/twohanded/required/kirbyplants', '/obj/structure/chair/sofa'))
                for a in M.tile(q))


def main():
    M = H.Map()
    todo = [r for r in A.problems(M) if not H.base(r[2]).startswith('/obj/machinery/access_button')]
    done, failed = [], []
    for p, s, atom, why, area in todo:
        target = None
        for side in [x for x in 'NSEW' if x != s]:
            if spot_ok(M, p, area, side, p):
                target = (p, side)
                break
        if not target:
            best = None
            for dx in range(-4, 5):
                for dy in range(-4, 5):
                    q = (p[0] + dx, p[1] + dy)
                    dist = abs(dx) + abs(dy)
                    if not dist or dist > 4:
                        continue
                    for side in 'NSEW':
                        if spot_ok(M, q, area, side, p):
                            key = (dist, side != s)
                            if best is None or key < best[0]:
                                best = (key, q, side)
            if best:
                target = (best[1], best[2])
        if not target:
            failed.append((p, atom))
            continue
        q, side = target
        t = list(M.tile(p))
        t.remove(atom)
        M.m.set_tile((p[0], p[1], 1), tuple(t))
        M.add(q, moved(atom, s, side), 'moved')
        done.append((p, s, why, q, side, H.base(atom)))
    M.m.to_file(str(H.MAP))
    for p, s, why, q, side, b in done:
        print(f'{b}: {p} {s} ({why}) -> {q} {side}')
    for p, a in failed:
        print('NOT MOVED', p, a[:90])
    print('moved:', len(done), 'failed:', len(failed))


if __name__ == '__main__':
    main()
