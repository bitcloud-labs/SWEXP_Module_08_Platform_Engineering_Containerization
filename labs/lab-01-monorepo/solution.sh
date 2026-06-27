#!/usr/bin/env bash
# Lab 01 — Monorepo boundary check. See README.md.
# Usage: ./solution.sh <edge-list-file>
#   Print each boundary violation on its own line (and exit 0).
#   A clean graph prints nothing.
set -euo pipefail
graph="${1:?usage: solution.sh <edge-list-file>}"

# Each line is "consumer -> dependency" (dependency may be empty).

# TODO 1: print a line containing the word "boundary" for every edge where a
#         packages/* node depends on an apps/* node (wrong direction).

# TODO 2: print a line containing the word "cycle" for every direct two-node
#         cycle: an edge "A -> B" whose reverse edge "B -> A" also exists.
