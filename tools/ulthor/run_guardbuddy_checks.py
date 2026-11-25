"""Build a private Ulthor test round and run the Guardbuddy gameplay probe."""

import hashlib
import json
import os
from pathlib import Path
import stat
import subprocess
import time
import uuid

from run_layout_checks import BYOND, ROOT, copy, plain, scan


def git_paths(*arguments):
    return [
        Path(os.fsdecode(path))
        for path in subprocess.check_output(
            ["git", "ls-files", "-z", *arguments], cwd=ROOT
        ).split(b"\0")
        if path
    ]


def hash_file(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def prepare_runtime(runtime, tracked):
    for path in tracked:
        if path.parts[0] in {"_maps", "config", "strings", "html", "icons", "sound"} or path.as_posix().startswith(
            ("code/datums/greyscale/json_configs/", "tgui/public/")
        ):
            copy(ROOT / path, runtime / path)
    for path in ROOT.glob("*.dll"):
        copy(path, runtime / path.name)
    source_assets = ROOT / "tgui/public"
    scan(source_assets)
    for path in source_assets.glob("*"):
        if path.is_file():
            copy(path, runtime / "tgui/public" / path.name)
    with (runtime / "config/maps.txt").open("a", encoding="utf-8") as config:
        config.write("\nDISABLE_AWAY_MISSIONS\nDISABLE_SPACE_RUINS\n")
    scan(runtime)


def run_probe():
    if git_paths("--deleted"):
        raise RuntimeError("Tracked files are missing")
    upstream = subprocess.check_output(["git", "rev-parse", "@{upstream}"], cwd=ROOT)
    if upstream != subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT):
        raise RuntimeError("Push the current checkpoint before running a test server")
    scan(ROOT / "tmp")
    token = uuid.uuid4().hex[:10]
    scratch = ROOT / ".local" / f"guardbuddy-{token}"
    runtime = scratch / "runtime"
    backup = scratch / "working-files"
    plain(scratch)
    runtime.mkdir(parents=True)
    tracked = git_paths("--cached")
    untracked = git_paths("--others", "--exclude-standard")
    baseline = {path: hash_file(ROOT / path) for path in tracked + untracked}
    separately_saved = untracked + [
        Path(path) for path in subprocess.check_output(
            ["git", "diff", "HEAD", "--name-only"], cwd=ROOT, text=True
        ).splitlines()
    ]
    for path in separately_saved:
        copy(ROOT / path, backup / path)
        if hash_file(backup / path) != baseline[path]:
            raise RuntimeError(f"Working file backup does not match: {path}")

    target = ROOT / f"guardbuddy_{token}.test.dme"
    environment = '#define FORCE_MAP "/datum/map/ulthor"\n'
    environment += (ROOT / "paradise.dme").read_text(encoding="utf-8-sig")
    environment += '\n#include "tools/ulthor/guardbuddy_probe.dm"\n'
    print(f"Guardbuddy run: {scratch}", flush=True)
    server = None
    try:
        target.write_text(environment, encoding="utf-8")
        with (scratch / "build.log").open("w", encoding="utf-8") as log:
            subprocess.run(
                [str(BYOND / "dm.exe"), "-DCBT", "-DCIBUILDING", target.name],
                cwd=ROOT, stdout=log, stderr=subprocess.STDOUT, check=True, timeout=180,
            )
        prepare_runtime(runtime, tracked)
        for suffix in (".dmb", ".rsc"):
            artifact = target.with_suffix(suffix)
            copy(artifact, runtime / artifact.name)
        scan(runtime)
        with (scratch / "server.log").open("w", encoding="utf-8") as log:
            startup = subprocess.STARTUPINFO()
            startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
            startup.wShowWindow = 0
            server = subprocess.Popen(
                [str(BYOND / "dd.exe"), target.with_suffix(".dmb").name, "-trusted", "-invisible", "-close"],
                cwd=runtime, stdout=log, stderr=subprocess.STDOUT, startupinfo=startup,
            )
            result = runtime / "guardbuddy-result.json"
            deadline = time.monotonic() + 450
            while not result.exists():
                if server.poll() is not None:
                    raise RuntimeError(f"DreamDaemon exited with code {server.returncode}")
                if time.monotonic() > deadline:
                    raise TimeoutError("Guardbuddy probe did not finish")
                time.sleep(0.5)
            report = json.loads(result.read_text(encoding="utf-8"))
            runtime_log = runtime / report["runtime_log"]
            report["runtime_errors"] = runtime_log.read_text(encoding="utf-8", errors="replace") if runtime_log.exists() else ""
            (scratch / "result.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
            print(json.dumps(report, indent=2), flush=True)
            if not all(check["passed"] for check in report["checks"]) or "Runtime in " in report["runtime_errors"]:
                raise RuntimeError("Guardbuddy gameplay checks failed")
    finally:
        if server is not None and server.poll() is None:
            server.terminate()
            server.wait(timeout=15)
        for suffix in (".dme", ".dmb", ".rsc"):
            artifact = target.with_suffix(suffix)
            if artifact.is_file() and not artifact.lstat().st_file_attributes & stat.FILE_ATTRIBUTE_REPARSE_POINT:
                artifact.unlink()
        changed = [str(path) for path, digest in baseline.items() if not (ROOT / path).is_file() or hash_file(ROOT / path) != digest]
        (scratch / "integrity.json").write_text(
            json.dumps({"checked": len(baseline), "changed": changed}, indent=2), encoding="utf-8"
        )
        if changed:
            raise RuntimeError(f"Source tree changed during test: {changed}")


if __name__ == "__main__":
    run_probe()
