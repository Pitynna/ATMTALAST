"""Verify the prison-toilet edit against the baseline recorded in ATMTA_PORT.json.

Requires mapmerge2's bidict dependency. This checker reads maps and never saves them.
"""

import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools/mapmerge2"))
from dmm import DMM


def main():
    manifest = json.loads((ROOT / "docs/ATMTA_PORT.json").read_text(encoding="utf-8"))
    name = "_maps/map_files/Ulthor/Ulthor.dmm"
    original = DMM.from_bytes(subprocess.check_output(["git", "show", f"{manifest['baseline_ref']}:{name}"], cwd=ROOT))
    current = DMM.from_file(ROOT / name)
    assert original.grid == current.grid, "Map coordinates or dictionary keys changed"
    changes = []
    for pos in original.grid:
        before = original.get_tile(pos)
        after = current.get_tile(pos)
        if before == after:
            continue
        assert any(atom.startswith("/area/station/security/prison") for atom in before), pos
        expected = tuple(atom.replace("/obj/structure/toilet", "/obj/structure/toilet/parasha", 1) if atom.startswith("/obj/structure/toilet") else atom for atom in before)
        assert after == expected, f"Unexpected content change at {pos}"
        changes.append(list(pos))
    assert len(changes) == 3, changes
    report = {"cells_checked": len(original.grid), "changed_cells": changes, "only_prison_toilets_changed": True}
    print(json.dumps(report))


if __name__ == "__main__":
    main()
