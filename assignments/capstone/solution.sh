#!/usr/bin/env bash
# Capstone — monorepo boundary check for the assembled platform. See README.md.
# Usage: ./solution.sh [edge-list-file]   (defaults to platform/forge.deps)
#   Print each boundary/cycle violation on its own line (and exit 0).
#   A clean platform prints nothing.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
graph="${1:-$here/platform/forge.deps}"

# Reuse your Lab 01 skill against platform/forge.deps:
# TODO 1: print a "boundary" line for every packages/* -> apps/* edge.
# TODO 2: print a "cycle"  line for every direct two-node cycle (A->B and B->A).
