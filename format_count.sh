#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

find include src app example test -type f \
    \( -name '*.hpp' -o -name '*.cpp' \) -print0 \
    | xargs -0 -r clang-format -i

if command -v cloc >/dev/null 2>&1; then
    cloc include src app example test
else
    echo "Formatting complete; install cloc to also count source lines."
fi
