"""Reconnect air around the rebuilt gravity generator (user rework, 2026-11-19).

The rework removed the distro/waste trunk that ran along y102 through the
new generator block, cutting atmospherics and the whole east side off the
west half (12 open pipe ends). Both lines are laid again:

* trunk: detective's door (144,102) -> up the x145 passage (the user's stub
  at (145,104)) -> along the south corridor y105 -> corridor line at (149,106);
* branch: from the corridor through the generator door (148,104), down the
  foyer x148 - east to the message server stub at (149,102) - and along y98
  through the SMES room and its doors to the generator's scrubber (154,99)
  and vent (157,98).
Also drops a duplicate cable at (148,98) and adds the missing fittings: tube
lamps in the foyer and the SMES room, a foyer camera, and removes the second
air alarm of the generator area.
Incremental: only the listed tiles change.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
sys.path.insert(0, str(Path(__file__).resolve().parent))
from dmm import DMM  # noqa: E402
from thin_air import pipe_atom, HIDDEN, path  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
N, S, E, W = 1, 2, 4, 8
BOTH = {
    (145, 102): W | N, (145, 103): N | S, (145, 105): S | E, (146, 105): E | W, (147, 105): E | W,
    (148, 105): W | E | S, (149, 105): W | N,
    (148, 104): N | S, (148, 103): N | S, (148, 102): N | S | E, (148, 101): N | S, (148, 100): N | S,
    (148, 99): N | S, (148, 98): N | E,
    (149, 98): E | W, (150, 98): E | W, (151, 98): E | W, (152, 98): E | W, (153, 98): E | W,
}
SUPPLY = {(154, 98): E | W, (155, 98): E | W, (156, 98): E | W}
SCRUB = {(154, 98): W | N}


def main():
    m = DMM.from_file(str(MAP))
    log = []

    def lay(p, k, bits):
        tile = list(m.get_tile((*p, 1)))
        if any((mm := HIDDEN.match(path(a))) and mm[2] == k for a in tile):
            log.append(f'{p} already has {k} - left')
            return
        i = next(i for i, a in enumerate(tile) if a.startswith('/turf'))
        tile.insert(i, pipe_atom(k, bits))
        m.set_tile((*p, 1), tuple(tile))
        log.append(f'{p} + {k} {bits}')

    for p, b in BOTH.items():
        lay(p, 'supply', b)
        lay(p, 'scrubbers', b)
    for p, b in SUPPLY.items():
        lay(p, 'supply', b)
    for p, b in SCRUB.items():
        lay(p, 'scrubbers', b)

    def edit(p, fn, why):
        tile = list(m.get_tile((*p, 1)))
        new = fn(tile)
        if new != tile:
            m.set_tile((*p, 1), tuple(new))
            log.append(f'{p} {why}')

    def dedupe_cable(tile):
        out, seen = [], False
        for a in tile:
            if a == '/obj/structure/cable':
                if seen:
                    continue
                seen = True
            out.append(a)
        return out

    def add(atom):
        return lambda tile: tile if atom in tile else [atom] + tile

    edit((148, 98), dedupe_cable, 'duplicate cable removed')
    edit((158, 100), lambda tile: [a for a in tile if not a.startswith('/obj/machinery/alarm')],
         'second air alarm removed')
    edit((147, 100), add('/obj/machinery/light{dir = 8}'), 'foyer lamp')
    edit((150, 97), add('/obj/machinery/light{dir = 8}'), 'SMES room lamp')
    edit((147, 102), add('/obj/machinery/camera{c_tag = "Gravity Generator Foyer";dir = 4;start_active = 1}'),
         'foyer camera')
    m.to_file(str(MAP))
    print('\n'.join(log))


if __name__ == '__main__':
    main()
