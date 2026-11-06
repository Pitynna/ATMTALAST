"""Compile and run the real server temp-cleanup regression without junctions."""

import json
import os
from pathlib import Path
import subprocess
import time


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "docs/chat_repair"
BYOND = Path(os.environ.get("BYOND_BIN", "E:/BYONDa220/bin"))


def main():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    result_file = OUTPUT / "temp-cleanup-result.json"
    if result_file.exists():
        result_file.unlink()  # One owned file; never recurse into any directory.
    name = "chat_temp_cleanup.test"
    environment = (
        "#define CBT\n#define CIBUILDING\n"
        + (ROOT / "paradise.dme").read_text(encoding="utf-8-sig")
        + '\n#include "code/tests/_unit_test.dm"\n'
        + '#include "code/tests/test_server_temp_cleanup.dm"\n'
        + '#include "tools/ci/server_temp_cleanup_probe.dm"\n'
    )
    (ROOT / f"{name}.dme").write_text(environment, encoding="utf-8")
    with (OUTPUT / "temp-test-build.log").open("w", encoding="utf-8") as log:
        subprocess.run(
            [str(BYOND / "dm.exe"), f"{name}.dme"],
            cwd=ROOT, stdout=log, stderr=subprocess.STDOUT, check=True, timeout=120,
        )
    with (OUTPUT / "temp-test-runtime.log").open("w", encoding="utf-8") as log:
        startup = subprocess.STARTUPINFO()
        startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        startup.wShowWindow = 0
        process = subprocess.Popen(
            [str(BYOND / "dreamdaemon.exe"), f"{name}.dmb", "-trusted", "-close", "-invisible"],
            cwd=ROOT, stdout=log, stderr=subprocess.STDOUT, startupinfo=startup,
        )
        try:
            deadline = time.monotonic() + 90
            while time.monotonic() < deadline:
                if result_file.exists():
                    report = json.loads(result_file.read_text(encoding="utf-8"))
                    print(json.dumps(report))
                    if not report["passed"]:
                        raise SystemExit(1)
                    break
                if process.poll() is not None:
                    raise RuntimeError("Test server exited before reporting a result")
                time.sleep(0.25)
            else:
                raise TimeoutError("No temp-cleanup test result after 90 seconds")
        finally:
            if process.poll() is None:
                process.terminate()
                process.wait(timeout=15)


if __name__ == "__main__":
    main()
