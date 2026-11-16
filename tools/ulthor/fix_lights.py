"""Ulthor lighting rule (user, 2026-11-16), applied to the current map.

* Corridors (every hallway area, airlock vestibules included) and ordinary
  rooms use tube lights: /obj/machinery/light/small
  becomes /obj/machinery/light (same dir).
* Small bulbs stay in small dark closets: rooms of at most SMALL_ROOM floor
  tiles and rooms dark by purpose (cold rooms, morgue, server, evidence,
  vault, execution, emergency storage), shuttles, the turbine room and solar
  substations.
* Maintenance passages are dark: lamps added there since the original map
  (commit ORIGINAL) are removed; the original ones stay.
"""
import hashlib
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
sys.path.insert(0, str(Path(__file__).resolve().parent))
from dmm import DMM  # noqa: E402
from rooms import Station  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
ORIGINAL = '061994cb'
SMALL = '/obj/machinery/light/small'
SMALL_ROOM = 12
DARK = ('/area/shuttle', '/area/station/maintenance/turbine', '/area/station/maintenance/solars',
        'coldroom', '/area/station/medical/morgue', '/area/station/science/server', '/area/station/security/evidence',
        '/area/station/command/vault', '/area/station/security/hallway/execution', 'emergency_storage')
PASSAGES = '/area/station/maintenance/ulthor_'
HALLWAY = '/area/station/hallway'
STAMP = ROOT / 'docs/ulthor_air/lights_output.sha256'


def is_lamp(a):
    p = a.split('{')[0]
    return p == '/obj/machinery/light' or p.startswith(('/obj/machinery/light/small', '/obj/machinery/light/spot'))


def main():
    own = STAMP.is_file() and STAMP.read_text().strip() == hashlib.sha256(MAP.read_bytes()).hexdigest()
    if not own and subprocess.run(['git', 'diff', '--quiet', '--', str(MAP)], cwd=ROOT).returncode:
        sys.exit('Ulthor.dmm has uncommitted edits (StrongDMM?) - commit them first.')
    m = DMM.from_file(str(MAP))
    tmp = ROOT / 'docs/ulthor_air/_original.dmm'
    tmp.write_bytes(subprocess.run(['git', 'show', f'{ORIGINAL}:_maps/map_files/Ulthor/Ulthor.dmm'], cwd=ROOT,
                                   capture_output=True, check=True).stdout)
    orig = DMM.from_file(str(tmp))
    tmp.unlink()
    orig_lamps = {(x, y) for (x, y, z), k in orig.grid.items() if any(is_lamp(a) for a in orig.dictionary[k])}
    room_size = {}
    for comp in Station(m).rooms():
        for p in comp:
            room_size[p] = len(comp)
    changed = {'tube': 0, 'removed': 0}
    for (x, y, z) in list(m.grid):
        tile = list(m.get_tile((x, y, z)))
        area = tile[-1]
        new = []
        for a in tile:
            if not is_lamp(a):
                new.append(a)
            elif area.startswith(PASSAGES) and (x, y) not in orig_lamps:
                changed['removed'] += 1
            elif a.startswith(SMALL) and not any(d in area for d in DARK) \
                    and (room_size.get((x, y), 99) > SMALL_ROOM or area.startswith(HALLWAY)):
                new.append('/obj/machinery/light' + a[len(SMALL):])
                changed['tube'] += 1
            else:
                new.append(a)
        if new != tile:
            m.set_tile((x, y, z), tuple(new))
    m.to_file(str(MAP))
    STAMP.write_text(hashlib.sha256(MAP.read_bytes()).hexdigest() + '\n')
    print(f"small bulbs -> tube lights: {changed['tube']}; lamps removed from maintenance passages: "
          f"{changed['removed']}")


if __name__ == '__main__':
    main()
