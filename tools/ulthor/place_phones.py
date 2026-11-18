"""Put landline phones on the department desks of Ulthor.

Usage: python -I tools/ulthor/place_phones.py [--write]

Edits the current Ulthor.dmm in place (incrementally, never regenerating). Tiles that already have a
landline phone are skipped, so running it twice changes nothing. Desks were picked by looking at each
room: a table next to a chair, not a counter with a windoor; where a machine already sits on the desk
the phone is moved to the edge with pixel_x.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM  # noqa: E402

MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
DESK = '/obj/machinery/landline_phone'

# (x, y, expected area, pixel_x)
DESKS = [
	(125, 164, '/area/station/command/bridge', 0),
	(143, 164, '/area/station/command/office/captain', -6),
	(109, 159, '/area/station/command/office/hop', 0),
	(113, 116, '/area/station/command/office/hos', -6),
	(152, 144, '/area/station/command/office/ce', 0),
	(140, 184, '/area/station/command/office/cmo', 0),
	(165, 164, '/area/station/command/office/rd', 0),
	(81, 124, '/area/station/command/office/qm', -6),
	(108, 159, '/area/station/command/office/ntrep', 8),
	(105, 164, '/area/station/command/office/blueshield', 0),
	(119, 102, '/area/station/legal/office/magistrate', -6),
	(123, 118, '/area/station/security/warden', -8),
	(134, 117, '/area/station/security/main', -8),
	(170, 111, '/area/station/security/checkpoint', -8),
	(136, 101, '/area/station/security/detectives_office', 0),
	(160, 119, '/area/station/engineering/engine', -6),
	(166, 145, '/area/station/engineering/atmos', -6),
	(159, 137, '/area/station/engineering/ulthor_monitoring', 0),
	(123, 181, '/area/station/medical/medbay', 0),
	(114, 173, '/area/station/medical/chemistry', 8),
	(165, 153, '/area/station/science/research/lobby', -6),
	(171, 174, '/area/station/science/rnd', -6),
	(164, 175, '/area/station/science/robotics/ulthor', 0),
	(83, 133, '/area/station/cargo/storage', 0),
	(96, 131, '/area/station/cargo/miningdock', -6),
	(82, 148, '/area/station/service/bar', 0),
	(72, 148, '/area/station/service/kitchen', -6),
	(82, 101, '/area/station/service/library', 0),
	(86, 178, '/area/station/service/chapel/office', 6),
	(89, 165, '/area/janitor', -6),
]

# (x, y, expected area, wall side) for rooms without a free desk
WALLS = [
	(79, 160, '/area/hydroponics', 'north'),
]


def base(atom):
	return atom.split('{')[0]


def main():
	m = DMM.from_file(MAP)
	changed = 0
	for x, y, area, px in DESKS:
		tile = list(m.get_tile((x, y, 1)))
		names = [base(a) for a in tile]
		assert names[-1] == area, f'({x},{y}) is {names[-1]}, expected {area}'
		if any(n.startswith(DESK) for n in names):
			continue
		tables = [i for i, n in enumerate(names) if n.startswith('/obj/structure/table')]
		assert tables, f'({x},{y}) has no table'
		atom = DESK if not px else f'{DESK}{{pixel_x = {px}}}'
		tile.insert(tables[-1] + 1, atom)
		m.set_tile((x, y, 1), tuple(tile))
		changed += 1
		print(f'desk phone at ({x},{y}) {area}')
	for x, y, area, side in WALLS:
		tile = list(m.get_tile((x, y, 1)))
		names = [base(a) for a in tile]
		assert names[-1] == area, f'({x},{y}) is {names[-1]}, expected {area}'
		if any(n.startswith(DESK) for n in names):
			continue
		turf = next(i for i, n in enumerate(names) if n.startswith('/turf'))
		tile.insert(turf, f'{DESK}/wall/directional/{side}')
		m.set_tile((x, y, 1), tuple(tile))
		changed += 1
		print(f'wall phone at ({x},{y}) {area}')
	print('phones placed:', changed)
	if '--write' in sys.argv and changed:
		m.to_file(MAP)
		print('written', MAP)


if __name__ == '__main__':
	main()
