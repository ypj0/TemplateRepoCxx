#!/usr/bin/env bash
set -euo pipefail

# Resolve the project from this script, not from the caller's working directory.
project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
command -v python3 >/dev/null 2>&1 || {
    echo "Error: python3 is required." >&2
    exit 1
}

python3 - "$project_root" <<'PY'
import re
import shutil
import sys
from pathlib import Path

root = Path(sys.argv[1])
name = root.name
# The directory name also becomes a C++ namespace and a CMake target prefix.
keywords = set('''alignas alignof and and_eq asm auto bitand bitor bool break
case catch char char8_t char16_t char32_t class compl concept const consteval
constexpr constinit const_cast continue co_await co_return co_yield decltype
default delete do double dynamic_cast else enum explicit export extern false
float for friend goto if inline int long mutable namespace new noexcept not
not_eq nullptr operator or or_eq private protected public register reinterpret_cast
requires return short signed sizeof static static_assert static_cast struct switch
template this thread_local throw true try typedef typeid typename union unsigned
using virtual void volatile wchar_t while xor xor_eq'''.split())
if (not re.fullmatch(r'[A-Za-z][A-Za-z0-9_]*', name)
        or '__' in name or name in keywords):
    sys.exit('Error: directory name must be a C++ identifier starting with a letter '
             '(no spaces, hyphens, double underscores, or C++ keywords). Rename the directory first.')

cmake = root / 'CMakeLists.txt'
match = re.search(r'(?m)^project\(\s*([A-Za-z][A-Za-z0-9_]*)\s', cmake.read_text())
if not match:
    sys.exit('Error: cannot read the current project name from CMakeLists.txt.')
old = match.group(1)
old_include = root / 'include' / old
new_include = root / 'include' / name
if old != name and new_include.exists():
    sys.exit(f'Error: destination already exists: {new_include}')
if old != name and (not old_include.is_dir() or old_include.is_symlink()):
    sys.exit(f'Error: expected a regular public header directory: {old_include}')

# Only edit project sources/configuration; never traverse Git, build artifacts,
# dependency trees, or this initialization script.
files = [cmake, root / 'CMakePresets.json', root / 'README.md']
for folder in ('src', 'app', 'include', 'test', 'example', '.vscode'):
    for path in (root / folder).rglob('*'):
        if (path.is_file() and
                (path.name == 'CMakeLists.txt' or
                 path.suffix in {'.cpp', '.hpp', '.h', '.cc', '.cxx', '.cmake', '.json'})):
            files.append(path)

updates = []
if old != name:
    # One substitution pass avoids cascading replacements when names overlap.
    replacements = {old: name}
    if old.upper() != old:
        replacements[old.upper()] = name.upper()
    pattern = re.compile(r'(?<![A-Za-z0-9_])(' +
                         '|'.join(re.escape(key) for key in replacements) +
                         r')(?=$|[^A-Za-z0-9_]|_)')
    for path in files:
        if path.is_symlink() or any(p.is_symlink() for p in path.parents if p != root):
            sys.exit(f'Error: refusing to modify a symbolic link: {path}')
        content = path.read_text()
        updated = pattern.sub(lambda m: replacements[m.group(1)], content)
        if updated != content:
            updates.append((path, updated))

build = root / 'build'
stale_cache = False
if build.is_dir() and not build.is_symlink():
    for cache in build.rglob('CMakeCache.txt'):
        for line in cache.read_text().splitlines():
            if line.startswith('CMAKE_HOME_DIRECTORY:INTERNAL='):
                stale_cache |= line.split('=', 1)[1] != str(root)

# Discard stale artifacts. Never follow a build symlink to an external directory.
# Repeated runs without a rename or move leave a valid build untouched.
if (build.exists() or build.is_symlink()) and (old != name or stale_cache):
    if build.is_symlink() or build.is_file():
        build.unlink()
    else:
        shutil.rmtree(build)
    print('Removed old build directory; no backup created.')
for path, content in updates:
    path.write_text(content)
if old != name:
    old_include.rename(new_include)

print(f'Project: {old} -> {name}' if old != name else f'Project already named {name}.')
print('Next: cmake --preset debug && cmake --build --preset debug --parallel')
PY
