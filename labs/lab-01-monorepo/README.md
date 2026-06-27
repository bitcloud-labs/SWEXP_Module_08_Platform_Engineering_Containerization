# Lab 01 — Monorepo Boundary Check

**Goal:** enforce the dependency direction of the Forge monorepo — **apps may depend on
packages, but a package must never depend on an app, and there must be no cycles.**

## The model

A monorepo's dependency graph is just data. We express it as a flat edge list, one edge
per line, `consumer -> dependency`:

```
apps/web -> packages/types
apps/web -> packages/ui
apps/api -> packages/types
packages/ui -> packages/types
packages/types ->
```

(A node with nothing after the arrow has no dependencies.)

## What you do

Complete [`solution.sh`](solution.sh). It takes one argument — a path to an edge-list file —
and **prints each boundary violation, one per line** (and exits `0`). A clean graph prints
**nothing**. You must catch two kinds of violation:

1. **Wrong direction** — a `packages/*` node depending on an `apps/*` node. Print a line
   containing the word `boundary` and the offending edge.
2. **Cycle** — a direct two-node cycle: `A -> B` *and* `B -> A`. Print a line containing the
   word `cycle`.

Hints: split each line on `->` with `awk` or parameter expansion; trim whitespace; a
`packages/* -> apps/*` edge is a `boundary` violation; for cycles, for every edge `A -> B`
check whether the reverse edge `B -> A` also exists.

Run the tests:

```bash
npx bats labs/lab-01-monorepo/tests
```

## Definition of done

- The **correct** graph (`fixtures/good.deps`) prints nothing and exits 0.
- A `packages/* -> apps/*` graph prints a `boundary` line.
- A cyclic graph prints a `cycle` line.
- `npm run grade` shell-syntax gate stays clean.

## Submit

Commit and push. The autograder scores it.
