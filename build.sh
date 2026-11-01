#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 [debug|release]"
    echo "Configure and build the project (default: debug)."
}

if [[ $# -gt 1 ]]; then
    usage >&2
    exit 2
fi

case "${1:-debug}" in
    debug|release) preset="${1:-debug}" ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
esac

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
cmake --preset "$preset"
cmake --build --preset "$preset" --parallel
