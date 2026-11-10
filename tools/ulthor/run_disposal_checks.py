"""Build and run only disposal regressions in a copied, hidden Ulthor runtime.

Commit/push first; untracked work must also be backed up before running.
No directory cleanup or links. Only our uniquely named root build files are removed.
"""
import hashlib
import json
from pathlib import Path
import subprocess
import time
import uuid
from run_layout_checks import ROOT, BYOND, plain, scan, copy

OUT = ROOT / 'docs/ulthor_disposals'


def main():
    tracked = subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT).decode().strip('\0').split('\0')
    if subprocess.check_output(['git', 'ls-files', '--deleted'], cwd=ROOT).strip():
        raise RuntimeError('Missing tracked sources')
    scan(ROOT / 'tmp')
    baseline = {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in tracked}
    plain(OUT)
    OUT.mkdir(exist_ok=True)
    token = uuid.uuid4().hex[:10]
    name = 'ulthor_disposals_' + token + '.test'
    runtime = ROOT / '.local/ulthor-disposals' / token
    plain(runtime)
    runtime.mkdir(parents=True)
    environment = '#define FORCE_MAP "/datum/map/ulthor"\n' + (ROOT / 'paradise.dme').read_text(encoding='utf-8-sig')
    for include in ['code/tests/_unit_test.dm', 'code/tests/test_wall_disposal.dm',
                    'code/tests/test_ulthor_disposals.dm', 'tools/ulthor/disposal_probe.dm']:
        environment += f'\n#include "{include}"\n'
    (ROOT / (name + '.dme')).write_text(environment, encoding='utf-8')
    process = None
    try:
        with (OUT / 'runtime-build.log').open('w', encoding='utf-8') as log:
            subprocess.run([str(BYOND / 'dm.exe'), '-DCBT', '-DCIBUILDING', name + '.dme'],
                           cwd=ROOT, stdout=log, stderr=subprocess.STDOUT, check=True, timeout=240)
        for ext in ['dmb', 'rsc']:
            copy(ROOT / (name + '.' + ext), runtime / (name + '.' + ext))
        for dll in ROOT.glob('*.dll'):
            copy(dll, runtime / dll.name)
        for p in tracked:
            if p.startswith(('_maps/', 'config/', 'strings/', 'html/')):
                copy(ROOT / p, runtime / p)
        with (runtime / 'config/maps.txt').open('a', encoding='utf-8') as f:
            f.write('\nDISABLE_AWAY_MISSIONS\nDISABLE_SPACE_RUINS\n')
        config = runtime / 'config/config.txt'
        config.write_text('\n'.join(line for line in config.read_text(encoding='utf-8-sig').splitlines()
                                    if line.strip().upper() != 'HUB') + '\n', encoding='utf-8')
        scan(runtime)
        startup = subprocess.STARTUPINFO()
        startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        startup.wShowWindow = 0
        with (OUT / 'runtime-server.log').open('w', encoding='utf-8') as log:
            process = subprocess.Popen([str(BYOND / 'dd.exe'), name + '.dmb', '-trusted', '-invisible', '-close'],
                                       cwd=runtime, stdout=log, stderr=subprocess.STDOUT, startupinfo=startup)
            print('Runtime started:', runtime, flush=True)
            result = runtime / 'ulthor-disposal-result.json'
            deadline = time.monotonic() + 360
            while not result.exists():
                if process.poll() is not None:
                    raise RuntimeError('Runtime exited without a report')
                if time.monotonic() > deadline:
                    raise TimeoutError('No report in 360 seconds')
                time.sleep(.25)
            report = json.loads(result.read_text(encoding='utf-8'))
            logfile = runtime / report['runtime_log']
            report['runtime_errors'] = logfile.read_text(encoding='utf-8', errors='replace') if logfile.exists() else ''
            report['runtime_directory'] = str(runtime)
            (OUT / 'runtime-result.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
            print(json.dumps(report), flush=True)
            if report['passed'] != report['total'] or report['runtime_errors'].strip():
                raise RuntimeError('Runtime regression failed')
    finally:
        if process is not None and process.poll() is None:
            process.terminate()
            process.wait(timeout=15)
        for ext in ['dme', 'dmb', 'rsc']:
            p = ROOT / (name + '.' + ext)
            plain(p)
            if p.is_file():
                p.unlink()
        changed = [p for p, h in baseline.items() if not (ROOT / p).is_file()
                   or hashlib.sha256((ROOT / p).read_bytes()).hexdigest() != h]
        (OUT / 'source-integrity.json').write_text(json.dumps({'tracked_files': len(baseline), 'changed': changed}, indent=2) + '\n', encoding='utf-8')
        if changed:
            raise RuntimeError('Source integrity changed: ' + str(changed))
        print('All tracked source hashes preserved.', flush=True)


if __name__ == '__main__':
    main()
