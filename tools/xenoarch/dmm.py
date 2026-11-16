"""Small DMM reader/writer for map porting tools (classic and TGM formats)."""
import re
from pathlib import Path

ATOM_SPLIT = re.compile(r',(?=\s*/)')


def split_atoms(content):
    """Split a key's content into atom strings, respecting {} and quotes."""
    atoms, depth, quote, start = [], 0, False, 0
    i = 0
    while i < len(content):
        c = content[i]
        if quote:
            if c == '\\':
                i += 2
                continue
            if c == '"':
                quote = False
        elif c == '"':
            quote = True
        elif c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
        elif c == ',' and depth == 0:
            atoms.append(content[start:i].strip())
            start = i + 1
        i += 1
    tail = content[start:].strip()
    if tail:
        atoms.append(tail)
    return atoms


def atom_type(atom):
    return atom.split('{', 1)[0].strip()


def atom_vars(atom):
    """Return an ordered dict of var -> raw value text."""
    if '{' not in atom:
        return {}
    body = atom.split('{', 1)[1].rsplit('}', 1)[0]
    result, depth, quote, start = {}, 0, False, 0
    parts = []
    i = 0
    while i < len(body):
        c = body[i]
        if quote:
            if c == '\\':
                i += 2
                continue
            if c == '"':
                quote = False
        elif c == '"':
            quote = True
        elif c in '({[':
            depth += 1
        elif c in ')}]':
            depth -= 1
        elif c == ';' and depth == 0:
            parts.append(body[start:i])
            start = i + 1
        i += 1
    parts.append(body[start:])
    for part in parts:
        part = part.strip()
        if not part:
            continue
        name, value = part.split('=', 1)
        result[name.strip()] = value.strip()
    return result


def make_atom(path, variables=None):
    if not variables:
        return path
    return path + '{' + '; '.join(f'{k} = {v}' for k, v in variables.items()) + '}'


class DMM:
    def __init__(self):
        self.keys = {}      # key -> list of atom strings
        self.grid = {}      # (x, y, z) -> key
        self.key_len = 3
        self.size = (0, 0, 0)

    @classmethod
    def load(cls, path):
        text = Path(path).read_text(encoding='utf-8', errors='replace')
        dmm = cls()
        pos = 0
        key_re = re.compile(r'"([a-zA-Z]+)" = \(')
        while True:
            m = key_re.match(text, pos)
            if not m:
                # skip comments/blank lines
                nl = text.find('\n', pos)
                if text.startswith('//', pos) or text[pos:nl].strip() == '':
                    if nl < 0:
                        break
                    pos = nl + 1
                    continue
                break
            key = m.group(1)
            dmm.key_len = len(key)
            i = m.end()
            depth, quote = 1, False
            while depth:
                c = text[i]
                if quote:
                    if c == '\\':
                        i += 1
                    elif c == '"':
                        quote = False
                elif c == '"':
                    quote = True
                elif c == '(':
                    depth += 1
                elif c == ')':
                    depth -= 1
                i += 1
            content = text[m.end():i - 1]
            content = re.sub(r'\s*\n\s*', ' ', content)
            dmm.keys[key] = split_atoms(content)
            pos = i
        block_re = re.compile(r'\((\d+),(\d+),(\d+)\) = \{"\s*\n(.*?)\n\s*"\}', re.S)
        maxx = maxy = maxz = 0
        blocks = list(block_re.finditer(text, pos))
        for b in blocks:
            bx, by, bz = int(b.group(1)), int(b.group(2)), int(b.group(3))
            lines = b.group(4).split('\n')
            kl = dmm.key_len
            if len(blocks) > 1 and all(len(l.strip()) == kl for l in lines):
                # TGM: one column per block, top row first
                height = len(lines)
                for row, line in enumerate(lines):
                    y = height - row
                    dmm.grid[(bx, y, bz)] = line.strip()
                maxx, maxy = max(maxx, bx), max(maxy, height)
            else:
                height = len(lines)
                for row, line in enumerate(lines):
                    line = line.strip()
                    y = height - row
                    for col in range(len(line) // kl):
                        dmm.grid[(bx + col, y, bz)] = line[col * kl:(col + 1) * kl]
                        maxx = max(maxx, bx + col)
                maxy = max(maxy, height)
            maxz = max(maxz, bz)
        dmm.size = (maxx, maxy, maxz)
        return dmm

    def tile(self, x, y, z=1):
        return self.keys[self.grid[(x, y, z)]]

    def save_tgm(self, path, header='//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE'):
        """Write a single-z TGM map. Keys are reassigned compactly in sorted order."""
        maxx, maxy, maxz = self.size
        assert maxz == 1
        used = {}
        for y in range(1, maxy + 1):
            for x in range(1, maxx + 1):
                used[self.grid[(x, y, 1)]] = True
        out = [header]
        order = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
        for key in sorted(used, key=lambda k: [order.index(c) for c in k]):
            atoms = self.keys[key]
            out.append(f'"{key}" = (')
            for n, atom in enumerate(atoms):
                tail = ',' if n < len(atoms) - 1 else ')'
                type_path = atom_type(atom)
                variables = atom_vars(atom)
                if variables:
                    out.append(type_path + '{')
                    items = list(variables.items())
                    for m, (k, v) in enumerate(items):
                        out.append(f'\t{k} = {v}' + (';' if m < len(items) - 1 else ''))
                    out.append('\t}' + tail)
                else:
                    out.append(type_path + tail)
        out.append('')
        for x in range(1, maxx + 1):
            out.append(f'({x},1,1) = {{"')
            for y in range(maxy, 0, -1):
                out.append(self.grid[(x, y, 1)])
            out.append('"}')
        Path(path).write_text('\n'.join(out) + '\n', encoding='utf-8', newline='\n')

    def new_key(self, atoms):
        """Return an existing key for these atoms or allocate a new one."""
        if not hasattr(self, '_reverse'):
            self._reverse = {tuple(v): k for k, v in self.keys.items()}
        t = tuple(atoms)
        if t in self._reverse:
            return self._reverse[t]
        letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
        n = len(self.keys)
        while True:
            k, v = '', n
            for _ in range(self.key_len):
                k = letters[v % 52] + k
                v //= 52
            if k not in self.keys:
                break
            n += 1
        self.keys[k] = list(atoms)
        self._reverse[t] = k
        return k
