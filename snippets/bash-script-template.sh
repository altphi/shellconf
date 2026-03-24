#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") <arg>"
    exit 1
}

[[ $# -lt 1 ]] && usage

