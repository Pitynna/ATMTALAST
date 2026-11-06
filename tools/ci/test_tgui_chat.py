"""Smoke-test the built chat in Chrome without a running BYOND server.

Build TGUI first, then run this script with Python. CHROME_BINARY can override
the browser path. Only synthetic messages and a separate browser profile are used.
"""

import html
import json
import os
from pathlib import Path
import re
import shutil
import subprocess


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "tmp" / "chat_repair" / "browser-tests"
CHROME = os.environ.get("CHROME_BINARY") or shutil.which("google-chrome") or str(
    Path(os.environ.get("PROGRAMFILES", "C:/Program Files"))
    / "Google/Chrome/Application/chrome.exe"
)

FIXTURE = r"""<!doctype html><meta charset="utf-8">
<meta id="tgui:windowId" content="browseroutput">
<link rel="stylesheet" href="../../../tgui/public/tgui-panel.bundle.css">
<style>html,body,#react-root{height:100%;margin:0}</style>
<div id="react-root"></div><pre id="test-result">RUNNING</pre>
<script>
window.testState = {errors: [], sent: [], winsets: [], subscriptions: []};
addEventListener('error', e => testState.errors.push(e.message));
addEventListener('unhandledrejection', e => testState.errors.push(String(e.reason)));
localStorage.clear();
const initialState = __INITIAL_STATE__;
// Delay saved-state loading so incoming messages exercise the startup queue.
window.hubStorage = {
  getItem: key => key === 'paradise-chat-state'
    ? new Promise(resolve => setTimeout(() => resolve(initialState), 500))
    : localStorage.getItem(key),
  setItem: (key, value) => localStorage.setItem(key, value),
  removeItem: key => localStorage.removeItem(key),
  clear: () => localStorage.clear(),
};
window.Byond = {
  windowId: 'browseroutput', storageCdn: null,
  subscribe: cb => { testState.subscriptions.push(cb); return () => {}; },
  subscribeTo: (type, cb) => {
    testState.subscriptions.push((t, p) => { if (t === type) cb(p); });
    return () => {};
  },
  sendMessage: (...args) => testState.sent.push(args),
  winset: (...args) => testState.winsets.push(args),
  winget: async () => ({size: '900x800'}),
  command: () => {}, saveBlob: () => {}, loadCss: () => {}, loadJs: () => {},
};
function message(sequence, text) {
  const payload = JSON.stringify({sequence, content: {type: 'ooc', text}});
  testState.subscriptions.forEach(cb => cb('chat/message', payload));
}
</script>
<script src="../../../tgui/public/tgui-panel.bundle.js"></script>
<script>
setTimeout(() => message(0, 'Сообщение до загрузки настроек.'), 50);
setTimeout(() => {
  message(1, 'Проверка чата: сообщения отображаются.');
  message(2, 'Проверка повторов: один экземпляр.');
  message(2, 'Проверка повторов: один экземпляр.');
  message(4, 'Проверка пропущенного сообщения.');
  message(3, 'Восстановленное сообщение.');
}, 1000);
setTimeout(() => {
  const chat = document.querySelector('.Chat');
  const text = chat?.textContent || '';
  const checks = {
    mounted: !!chat,
    russianMessage: text.includes('Проверка чата: сообщения отображаются.'),
    queuedOnce: text.split('Сообщение до загрузки настроек.').length === 2
      && !chat?.querySelector('.Chat__badge'),
    deduplicated: text.split('Проверка повторов: один экземпляр.').length === 2,
    resendRequested: testState.sent.some(v => v[0] === 'chat/resend' && v[1] === 3),
    recoveredMessage: text.includes('Восстановленное сообщение.'),
    panelActivated: testState.winsets.some(v =>
      v[0] === 'output_selector.legacy_output_selector'
      && v[1]?.left === 'output_browser'),
    noErrors: testState.errors.length === 0,
  };
  document.getElementById('test-result').textContent = JSON.stringify({
    pass: Object.values(checks).every(Boolean), checks, errors: testState.errors,
  });
}, 2500);
</script>"""


def main():
    for name in ("tgui-panel.bundle.js", "tgui-panel.bundle.css"):
        if not (ROOT / "tgui/public" / name).is_file():
            raise SystemExit(f"Build TGUI first: missing {name}")
    OUTPUT.mkdir(parents=True, exist_ok=True)
    cases = {
        "fresh": None,
        "obsolete": json.dumps({"version": -1}),
        "invalid": json.dumps({"version": 5}),
        "malformed": "{",
    }
    failed = False
    for case, state in cases.items():
        fixture = OUTPUT / f"{case}.html"
        fixture.write_text(
            FIXTURE.replace("__INITIAL_STATE__", json.dumps(state)),
            encoding="utf-8",
        )
        args = [
            CHROME,
            "--headless=new",
            "--disable-gpu",
            "--no-first-run",
            "--no-default-browser-check",
            "--allow-file-access-from-files",
            "--disable-background-networking",
            f"--user-data-dir={OUTPUT / 'profile'}",
            "--virtual-time-budget=4000",
            "--dump-dom",
            fixture.as_uri(),
        ]
        result = subprocess.run(args, capture_output=True, timeout=40)
        dom = result.stdout.decode("utf-8", errors="replace")
        (OUTPUT / f"{case}-dom.html").write_text(dom, encoding="utf-8")
        (OUTPUT / f"{case}-stderr.log").write_bytes(result.stderr)
        match = re.search(r'<pre id="test-result">(.*?)</pre>', dom, re.S)
        report = json.loads(html.unescape(match[1])) if match else {"pass": False}
        (OUTPUT / f"{case}-result.json").write_text(
            json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8"
        )
        passed = result.returncode == 0 and report["pass"]
        print(f"{'PASS' if passed else 'FAIL'} {case}: {report}")
        failed |= not passed
    raise SystemExit(int(failed))


if __name__ == "__main__":
    main()
