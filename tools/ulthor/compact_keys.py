"""Reuse old DMM keys for edited tiles and drop unused keys (keeps diffs small).
python compact_keys.py OLD.dmm  (rewrites Ulthor.dmm in place)"""
import sys
from collections import defaultdict
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools/mapmerge2'))
from dmm import DMM
MAP = ROOT / '_maps/map_files/Ulthor/Ulthor.dmm'
old = DMM.from_file(sys.argv[1])
new = DMM.from_file(MAP)
used = set(new.grid.values())
# new key -> set of old keys of the cells it covers
origin = defaultdict(set)
for c, k in new.grid.items():
    origin[k].add(old.grid[c])
users = defaultdict(set)
for k, olds in origin.items():
    for o in olds:
        users[o].add(k)
rename = {}
for k, olds in origin.items():
    if k in old.dictionary and old.dictionary[k] == new.dictionary[k]:
        continue
    if len(olds) == 1:
        o = next(iter(olds))
        if o not in used and users[o] == {k} and o not in rename.values():
            rename[k] = o
tiles = {k: new.dictionary[k] for k in used}
for c, k in list(new.grid.items()):
    if k in rename:
        new.grid[c] = rename[k]
new.dictionary.clear()
for k in set(new.grid.values()):
    new.dictionary[k] = tiles[k if k not in rename.values() else next(a for a, b in rename.items() if b == k)] if k in rename.values() else tiles[k]
new.to_file(MAP)
print('renamed', len(rename), 'keys; total', len(new.dictionary))
