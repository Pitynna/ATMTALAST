"""Validate Ulthor's DMM invariants; optionally compare hull geometry to the original.

Install the standard mapmerge2 dependency (bidict) before running this script.
"""
import argparse
from collections import Counter
import hashlib
import json
import re
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools/mapmerge2"))
from dmm import DMM


def split_variables(text):
    """Split var edits while preserving strings and nested DM lists."""
    result = []
    start = 0
    depth = 0
    quote = None
    escaped = False
    for index, character in enumerate(text):
        if escaped:
            escaped = False
            continue
        if character == "\\":
            escaped = True
            continue
        if quote:
            if character == quote:
                quote = None
        elif character in ("\"", "'"):
            quote = character
        elif character in "([{":
            depth += 1
        elif character in ")]}":
            depth -= 1
        elif character == ";" and depth == 0:
            result.append(text[start:index].strip())
            start = index + 1
    if quote or depth:
        raise ValueError("Unbalanced string or nested value in DMM variable edits")
    result.append(text[start:].strip())
    return [value for value in result if value]


def parse_map_atom(atom):
    if "{" not in atom:
        return atom, {}
    path, edits = atom.split("{", 1)
    variables = {}
    for edit in split_variables(edits[:-1]):
        name, value = edit.split("=", 1)
        variables[name.strip()] = value.strip()
    return path, variables


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--original", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    path = ROOT / "_maps/map_files/Ulthor/Ulthor.dmm"
    station = DMM.from_file(path)
    failures = []
    areas = Counter()
    starts = Counter()
    apcs = Counter()
    controls = []
    linked_doors = []
    driver_ids = set()
    camera_tags = Counter()
    for pos in station.grid:
        tile = station.get_tile(pos)
        parsed = [parse_map_atom(atom) for atom in tile]
        turfs = [typ for typ, _ in parsed if typ.startswith("/turf")]
        zones = [typ for typ, _ in parsed if typ.startswith("/area")]
        if len(turfs) != 1 or len(zones) != 1:
            failures.append(f"{pos}: expected one turf and one area")
            continue
        areas[zones[0]] += 1
        if zones[0] in ("/area", "/area/space") and turfs[0].startswith("/turf/simulated/floor"):
            failures.append(f"{pos}: interior floor painted as farspace")
        cable_count = sum(typ.startswith("/obj/structure/cable") for typ, _ in parsed)
        if cable_count > 1:
            failures.append(f"{pos}: stacked old cable segments")
        for typ, variables in parsed:
            if typ.startswith("/obj/effect/landmark/start/"):
                starts[typ.rsplit("/", 1)[1]] += 1
            if typ.startswith("/obj/machinery/power/apc"):
                apcs[zones[0]] += 1
            invalid_keys = [key for key in variables if not re.fullmatch(r"[A-Za-z_][A-Za-z_0-9]*", key)]
            if invalid_keys:
                failures.append(f"{pos}: malformed variable names {invalid_keys}")
            if typ == "/obj/machinery/door_control":
                controls.append((pos, variables.get("id"), variables.get("normaldoorcontrol") == "1"))
            if typ.startswith(("/obj/machinery/door/poddoor", "/obj/machinery/door/airlock")):
                linked_doors.append((pos, variables.get("id_tag"), "/airlock" in typ))
            if typ == "/obj/machinery/driver_button":
                driver_ids.add(variables.get("id_tag"))
            if typ.startswith("/obj/machinery/camera"):
                camera_tags[variables.get("c_tag", "")] += 1
            obsolete = {key for key in variables if key.endswith("_access_txt") or key in ("d1", "d2", "pump_direction", "scrub_N2O", "scrub_Toxins")}
            if obsolete:
                failures.append(f"{pos}: obsolete fields {sorted(obsolete)}")
            if "/trinary/filter" in typ and variables.get("filter_type", "").isdigit():
                failures.append(f"{pos}: numeric gas filter ID")
    for area, count in apcs.items():
        if count > 1 or area.startswith("/area/space"):
            failures.append(f"{area}: {count} APCs sharing an invalid circuit")
    control_ids = {identifier for _, identifier, _ in controls} | driver_ids
    for position, identifier, airlock_control in controls:
        if not any(target_id == identifier and airlock == airlock_control for _, target_id, airlock in linked_doors):
            failures.append(f"{position}: door control has no matching target {identifier}")
    for position, identifier, airlock in linked_doors:
        if not airlock and identifier not in control_ids:
            failures.append(f"{position}: blast door has no mapped controller {identifier}")
    for tag, count in camera_tags.items():
        if not tag or count > 1:
            failures.append(f"Camera label {tag!r} must be nonempty and unique")
    mandatory = {"civilian", "captain", "hop", "chief_engineer", "engineer", "atmospheric", "cmo", "doctor", "chemist", "geneticist", "virologist", "research_director", "scientist", "roboticist", "head_of_security", "warden", "detective", "security_officer", "quartermaster", "cargo_technician", "shaft_miner", "chef", "bartender", "botanist", "janitor", "librarian", "chaplain", "clown", "mime", "ai", "cyborg"}
    missing = mandatory - starts.keys()
    if missing:
        failures.append(f"Missing job starts: {sorted(missing)}")
    report = {"size": list(station.size), "tiles": len(station.grid), "sha256": hashlib.sha256(path.read_bytes()).hexdigest(), "apcs": sum(apcs.values()), "start_markers": sum(starts.values()), "camera_count": sum(camera_tags.values()), "door_controls": len(controls), "blast_doors": sum(not airlock for _, _, airlock in linked_doors), "jobs": dict(starts), "areas": dict(areas), "failures": failures}
    if args.original:
        original = DMM.from_file(args.original)
        changes = []
        def category(tile):
            # The old source sometimes contains two turfs; the last one wins.
            turf = [parse_map_atom(a)[0] for a in tile if a.startswith("/turf")][-1]
            if "/wall" in turf:
                return "wall"
            if "/floor" in turf or "/plating" in turf:
                return "floor"
            return "space"
        for pos in original.grid:
            before, after = category(original.get_tile(pos)), category(station.get_tile(pos))
            if before != after:
                changes.append({"position": list(pos), "before": before, "after": after})
        report["original_sha256"] = hashlib.sha256(args.original.read_bytes()).hexdigest()
        report["geometry_changes"] = changes
        if list(original.size) != list(station.size):
            failures.append("Map dimensions changed")
    if args.output:
        args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Ulthor: {len(station.grid)} tiles, {sum(apcs.values())} APCs, {sum(starts.values())} job starts; {len(failures)} failures")
    for failure in failures:
        print(failure)
    return bool(failures)


if __name__ == "__main__":
    sys.exit(main())
