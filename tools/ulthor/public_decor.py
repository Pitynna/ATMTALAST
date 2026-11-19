"""Decor for Ulthor's public rooms (user, 2026-11-19). One-time, additive.

Per room: wall pieces on free faces of solid walls (about one per 18 floor
tiles, at least 4 tiles apart), potted plants in free inner corners (about
one per 30 tiles), flower vases on empty tables, a sign outside the main
door where the room has one (OPEN neon at the bar, ARCADE, GARDEN...).
The dorm lounge's bare plasteel becomes carpet. Never touches maintenance
or hallways (hallways: hall_decor.py).
"""
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import hall_decor as H  # noqa: E402

RNG = random.Random(1119)
OFFICIAL = '/obj/structure/sign/poster/official/random'
CONTRA = '/obj/structure/sign/poster/contraband/random'
ROOMS = {
    '/area/station/service/bar': dict(
        wall=['/obj/structure/goon_wallfish', CONTRA, CONTRA, '/obj/structure/goon_candelabra/lit',
              '/obj/structure/goon_candelabra/lit', '/obj/structure/goon_clock', '/obj/structure/sign/goon/poster/rat'],
        outside='/obj/structure/sign/goon/open_neon/on'),
    '/area/station/service/library': dict(
        wall=['/obj/structure/sign/painting/library', '/obj/structure/sign/painting/library', '/obj/structure/goon_clock',
              '/obj/structure/sign/goon/portrait', '/obj/structure/goon_candelabra/lit', '/obj/structure/sign/goon/portrait/scientist']),
    '/area/station/service/chapel': dict(wall=['/obj/structure/goon_candelabra/lit'] * 4),
    '/area/station/service/chapel/office': dict(wall=['/obj/structure/goon_candelabra/lit', '/obj/structure/sign/goon/frame']),
    '/area/station/commons/dorms': dict(
        wall=[OFFICIAL, '/obj/structure/goon_clock', '/obj/structure/sign/goon/poster/capy_king', OFFICIAL,
              '/obj/structure/sign/goon/poster/explore'],
        carpet='/turf/simulated/floor/carpet'),
    '/area/station/commons/locker': dict(wall=[OFFICIAL, '/obj/structure/sign/goon/iso/no_smoking', '/obj/structure/sign/goon/gym']),
    '/area/station/commons/arcade': dict(wall=[CONTRA, '/obj/structure/sign/goon/poster/laser_power'],
                                         outside='/obj/structure/sign/goon/arcade'),
    '/area/station/commons/pet_store': dict(wall=['/obj/structure/sign/goon/poster/capy_king', '/obj/structure/sign/goon/poster/rat']),
    '/area/station/service/barber': dict(wall=['/obj/structure/sign/goon/frame', '/obj/structure/sign/goon/poster/new_you']),
    '/area/station/legal/courtroom': dict(wall=['/obj/structure/sign/goon/portrait', '/obj/structure/goon_clock', '/obj/structure/sign/goon/certificate']),
    '/area/station/commons/storage/tools': dict(wall=['/obj/structure/sign/goon/poster/pack_smart', '/obj/structure/sign/goon/iso/ppe']),
    '/area/station/commons/storage/primary': dict(wall=['/obj/structure/sign/goon/poster/pack_smart', '/obj/structure/sign/goon/iso/mandatory']),
    '/area/station/hallway/secondary/garden': dict(wall=[], outside='/obj/structure/sign/goon/garden', hallway=True),
}


def room_free(M, p, area):
    """Floor of this room with nothing standing on it."""
    if M.area(p) != area or not M.floor(p) or M.door(p):
        return False
    for a in M.tile(p):
        b = H.base(a)
        if b.startswith(('/turf', '/area', '/obj/effect/turf_decal', '/obj/structure/cable', '/obj/machinery/atmospherics/pipe',
                         '/obj/structure/disposalpipe', '/obj/machinery/light', '/obj/structure/sign', '/obj/machinery/camera')):
            continue
        if '/directional/' in b or H.re.search(r'pixel_[xy] = -?(2[0-9]|3[0-9])', a):
            continue
        return False
    return True


def sign_face(M, p, d):
    """Like face_free, but a door sign may also hang on a window (shop-window neon)."""
    w = H.nb(p, d)
    if M.window(w) and not M.door(w):
        return not any(H.base(a).startswith(('/obj/structure/sign', '/obj/machinery')) for a in M.tile(w)) and             not any(f'{H.PIX[d]}' in a for a in M.tile(p))
    return H.face_free(M, p, d)


def decorate(M, area, cfg):
    tiles = [(x, y) for x in range(1, M.m.size.x + 1) for y in range(1, M.m.size.y + 1)
             if M.area((x, y)) == area and M.floor((x, y))]
    if not tiles:
        return
    if cfg.get('carpet'):
        for p in tiles:
            t = M.turf(p)
            if H.base(t) == '/turf/simulated/floor/plasteel' and not M.door(p) and not M.window(p):
                M.set_turf(p, cfg['carpet'])
                M.log['carpet tiles'] += 1
    # wall pieces
    want = max(1, len(tiles) // 18) if cfg['wall'] else 0
    pool = list(cfg['wall'])
    RNG.shuffle(pool)
    hung = []
    spots = [(p, d) for p in sorted(tiles) for d in 'NSWE' if H.face_free(M, p, d)]
    RNG.shuffle(spots)
    for p, d in spots:
        if len(hung) >= want or not pool:
            break
        if any(abs(p[0] - q[0]) + abs(p[1] - q[1]) < 4 for q in hung):
            continue
        atom = pool.pop()
        if not pool:
            pool = list(cfg['wall'])
            RNG.shuffle(pool)
        M.add(p, f'{atom}{{{H.PIX[d]}}}', 'room wall pieces')
        hung.append(p)
    # plants in corners
    if not cfg.get('hallway'):
        planted = []
        for p in sorted(tiles, key=lambda _: RNG.random()):
            if len(planted) >= max(1, len(tiles) // 30):
                break
            walls = [d for d in 'NSWE' if M.wall(H.nb(p, d)) or M.window(H.nb(p, d))]
            if len(walls) != 2 or set(walls) in ({'N', 'S'}, {'E', 'W'}):
                continue
            if not room_free(M, p, area) or H.door_near(M, p) or any(abs(p[0] - q[0]) + abs(p[1] - q[1]) < 5 for q in planted):
                continue
            M.add(p, RNG.choice(H.PLANTS), 'room plants')
            planted.append(p)
        for p in tiles:  # vases on empty tables
            t = M.tile(p)
            if any(H.base(a).startswith('/obj/structure/table') for a in t) and not any(
                    H.base(a).startswith(('/obj/item', '/obj/machinery')) for a in t) and RNG.random() < 0.4:
                M.add(p, '/obj/item/goon_vase/random', 'room vases')
    # sign outside the main door
    if cfg.get('outside'):
        for p in sorted(tiles):
            for d in 'NSWE':
                door = H.nb(p, d)
                out = H.nb(door, d)
                if not M.door(door) or not M.hall(out) or not M.floor(out):
                    continue
                # hang it on the room's wall right beside the door, seen from the corridor
                for sd in (('E', 'W') if d in 'NS' else ('N', 'S')):
                    q = H.nb(out, sd)
                    if M.floor(q) and M.hall(q) and sign_face(M, q, H.OPP[d]):
                        M.add(q, f'{cfg["outside"]}{{{H.PIX[H.OPP[d]]}}}', 'door signs')
                        return


def main():
    M = H.Map()
    if any(H.base(a) == '/obj/structure/sign/goon/open_neon/on' for p in M.m.grid for a in M.m.dictionary[M.m.grid[p]]):
        sys.exit('public room decor already placed; this script runs once')
    for area, cfg in ROOMS.items():
        decorate(M, area, cfg)
    M.m.to_file(str(H.MAP))
    for k, v in sorted(M.log.items()):
        print(f'{k}: {v}')


if __name__ == '__main__':
    main()
