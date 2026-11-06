"""Compile and run Ulthor checks in a unique copied runtime, without links.

Run after committing/pushing the source. Retains logs under docs/ulthor_layout.
Only this script's individually named temporary build files are unlinked.
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

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'docs/ulthor_layout'
BYOND=Path('E:/BYONDa220/bin')


def plain(path):
    for p in (path,*path.parents):
        if p.exists() and p.lstat().st_file_attributes & stat.FILE_ATTRIBUTE_REPARSE_POINT:
            raise RuntimeError('Reparse point: '+str(p))


def scan(path):
    plain(path)
    if not path.exists():return
    for e in os.scandir(path):
        st=e.stat(follow_symlinks=False)
        if st.st_file_attributes & stat.FILE_ATTRIBUTE_REPARSE_POINT:raise RuntimeError('Reparse point: '+e.path)
        if e.is_dir(follow_symlinks=False):scan(Path(e.path))


def copy(src,dst):
    plain(src);plain(dst.parent);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst)


def main():
    tracked=subprocess.check_output(['git','ls-files','-z'],cwd=ROOT).decode().strip('\0').split('\0')
    if subprocess.check_output(['git','ls-files','--deleted'],cwd=ROOT).strip():raise RuntimeError('Missing tracked sources')
    scan(ROOT/'tmp')
    baseline={p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in tracked}
    token=uuid.uuid4().hex[:10]
    name='ulthor_layout_'+token+'.test'
    runtime=ROOT/'.local/ulthor-runs'/token
    plain(runtime);runtime.mkdir(parents=True)
    environment='#define FORCE_MAP "/datum/map/ulthor"\n'+(ROOT/'paradise.dme').read_text(encoding='utf-8-sig')
    environment+='\n#include "code/tests/_unit_test.dm"\n#include "code/tests/test_ulthor.dm"\n#include "code/tests/test_ulthor_systems.dm"\n#include "tools/ulthor/layout_probe.dm"\n'
    (ROOT/(name+'.dme')).write_text(environment,encoding='utf-8')
    process=None
    try:
        with (OUT/'runtime-build.log').open('w',encoding='utf-8') as log:
            subprocess.run([str(BYOND/'dm.exe'),'-DCBT','-DCIBUILDING',name+'.dme'],cwd=ROOT,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=180)
        for ext in ['dmb','rsc']:copy(ROOT/(name+'.'+ext),runtime/(name+'.'+ext))
        for dll in ROOT.glob('*.dll'):copy(dll,runtime/dll.name)
        for p in tracked:
            if p.startswith(('_maps/','config/','strings/','html/')):copy(ROOT/p,runtime/p)
        copy(OUT/'fixture-expectations.json',runtime/'ulthor-layout-expectations.json')
        config=runtime/'config/maps.txt'
        with config.open('a',encoding='utf-8') as f:f.write('\nDISABLE_AWAY_MISSIONS\nDISABLE_SPACE_RUINS\n')
        config=runtime/'config/config.txt'
        if config.exists():config.write_text('\n'.join(l for l in config.read_text(encoding='utf-8-sig').splitlines() if l.strip().upper()!='HUB')+'\n',encoding='utf-8')
        scan(runtime)
        startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
        with (OUT/'runtime-server.log').open('w',encoding='utf-8') as log:
            process=subprocess.Popen([str(BYOND/'dd.exe'),name+'.dmb','-trusted','-invisible','-close'],cwd=runtime,stdout=log,stderr=subprocess.STDOUT,startupinfo=startup)
            result=runtime/'ulthor-layout-result.json';deadline=time.monotonic()+360
            print('Runtime started:',runtime,flush=True)
            while not result.exists():
                if process.poll() is not None:raise RuntimeError('Runtime exited before producing its report')
                if time.monotonic()>deadline:raise TimeoutError('No report in 360 seconds')
                time.sleep(.25)
            report=json.loads(result.read_text(encoding='utf-8'))
            logfile=runtime/report['runtime_log']
            report['runtime_errors']=logfile.read_text(encoding='utf-8',errors='replace') if logfile.exists() else ''
            report['runtime_directory']=str(runtime)
            (OUT/'runtime-result.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
            print(json.dumps(report),flush=True)
            if report['passed']!=report['total'] or report['runtime_errors'].strip():raise RuntimeError('Runtime checks failed')
    finally:
        if process is not None and process.poll() is None:process.terminate();process.wait(timeout=15)
        # No recursive cleanup. Only this run's exact temporary build files.
        for ext in ['dme','dmb','rsc']:
            p=ROOT/(name+'.'+ext);plain(p)
            if p.is_file():p.unlink()
        changed=[p for p,h in baseline.items() if not (ROOT/p).is_file() or hashlib.sha256((ROOT/p).read_bytes()).hexdigest()!=h]
        (OUT/'source-integrity.json').write_text(json.dumps({'tracked_files':len(baseline),'changed':changed},indent=2)+'\n',encoding='utf-8')
        if changed:raise RuntimeError('Sources changed during runtime: '+str(changed))
        print('All tracked source hashes preserved.',flush=True)


if __name__=='__main__':main()
