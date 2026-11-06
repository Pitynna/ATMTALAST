"""Compile and test the ATMTA port in a fresh runtime, never using junctions.

Run only after saving and pushing current work. Runtime files are retained under
.git/atmta-port-runs; this tool never cleans directories or runs project helpers.
"""

import hashlib
import json
import os
from pathlib import Path
import shutil
import stat
import subprocess
import time
import uuid


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "docs/atmta_port_validation"
BYOND = Path(os.environ.get("BYOND_BIN", "E:/BYONDa220/bin"))


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT).decode().strip()


def check_plain_path(path):
    """Inspect components themselves, without traversing reparse points."""
    for component in (path, *path.parents):
        if component == ROOT.parent:
            break
        if component.exists() and component.lstat().st_file_attributes & stat.FILE_ATTRIBUTE_REPARSE_POINT:
            raise RuntimeError(f"Reparse point is not permitted: {component}")


def copy_file(source, target):
    check_plain_path(source)
    check_plain_path(target.parent)
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, target)


def main():
    if git("ls-files", "--deleted"):
        raise RuntimeError("Tracked files are missing; refusing to start a server")
    OUTPUT.mkdir(parents=True, exist_ok=True)
    tracked = git("ls-files").splitlines()
    baseline = {name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest() for name in tracked}
    runtime = ROOT / ".git/atmta-port-runs" / uuid.uuid4().hex
    check_plain_path(runtime.parent)
    runtime.mkdir(parents=True)
    name = "atmta_port_runtime.test"
    environment = '#define FORCE_MAP "/datum/map/ulthor"\n' + (ROOT / "paradise.dme").read_text(encoding="utf-8-sig")
    environment += '\n#include "code/tests/_unit_test.dm"\n#include "code/tests/test_atmta_port.dm"\n#include "tools/ci/atmta_port_probe.dm"\n'
    (ROOT / f"{name}.dme").write_text(environment, encoding="utf-8")
    with (OUTPUT / "build.log").open("w", encoding="utf-8") as log:
        subprocess.run([str(BYOND / "dm.exe"), "-DCBT", "-DCIBUILDING", f"{name}.dme"], cwd=ROOT, stdout=log, stderr=subprocess.STDOUT, check=True, timeout=180)
    for extension in ("dmb", "rsc"):
        copy_file(ROOT / f"{name}.{extension}", runtime / f"{name}.{extension}")
    for path in ROOT.glob("*.dll"):
        copy_file(path, runtime / path.name)
    # Only versioned configuration is copied; local credentials and data are excluded.
    for name_in_repo in tracked:
        if name_in_repo.startswith(("_maps/", "config/", "strings/", "html/", "icons/", "code/datums/greyscale/json_configs/")):
            copy_file(ROOT / name_in_repo, runtime / name_in_repo)
    (runtime / "wardrobe").mkdir()
    result_path = runtime / "atmta-port-result.json"
    print(f"Starting isolated runtime: {runtime}", flush=True)
    startup = subprocess.STARTUPINFO()
    startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    startup.wShowWindow = 0
    try:
        with (OUTPUT / "server.log").open("w", encoding="utf-8") as log:
            process = subprocess.Popen([str(BYOND / "dd.exe"), f"{name}.dmb", "-trusted", "-invisible", "-close"], cwd=runtime, stdout=log, stderr=subprocess.STDOUT, startupinfo=startup)
            try:
                deadline = time.monotonic() + 300
                while not result_path.exists():
                    if process.poll() is not None:
                        raise RuntimeError("Test server exited without a report")
                    if time.monotonic() > deadline:
                        raise TimeoutError("No ATMTA test report within 300 seconds")
                    time.sleep(0.25)
                report = json.loads(result_path.read_text(encoding="utf-8"))
                runtime_log = runtime / report["runtime_log"]
                errors = runtime_log.read_text(encoding="utf-8", errors="replace") if runtime_log.exists() else ""
                error_lines = [line for line in errors.splitlines() if "Runtime in " in line or "runtime error:" in line.lower()]
                report["runtime_errors"] = error_lines
                (OUTPUT / "runtime.log").write_text(errors, encoding="utf-8")
                report["runtime_directory"] = str(runtime)
                previews = OUTPUT / "wardrobe"
                previews.mkdir(exist_ok=True)
                for preview in (runtime / "wardrobe").glob("*.png"):
                    copy_file(preview, previews / preview.name)
                (OUTPUT / "result.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
                print(json.dumps(report, ensure_ascii=False), flush=True)
                if report["passed"] != report["total"] or error_lines or not report["prison_parashas"] or report["ordinary_prison_toilets"]:
                    raise RuntimeError("ATMTA checks failed; inspect the saved report")
            finally:
                if process.poll() is None:
                    process.terminate()
                    process.wait(timeout=15)
    finally:
        changed = [name for name, digest in baseline.items() if not (ROOT / name).is_file() or hashlib.sha256((ROOT / name).read_bytes()).hexdigest() != digest]
        if changed:
            raise RuntimeError(f"Tracked source files changed during the run: {changed}")
        print("All tracked files retain their original SHA-256 hashes.", flush=True)


if __name__ == "__main__":
    main()
