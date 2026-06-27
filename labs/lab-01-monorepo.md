# Lab 01 — Reorganize Project Forge into a Monorepo

**Lesson:** 01 · **Goal:** a monorepo layout with shared packages and an enforced dependency direction (apps → packages, no cycles).

## Goal
Define the Forge monorepo and prove the dependency boundaries with a check that fails a bad layout and passes the correct one.

## Setup
The layout and workspace config:
```
forge/
├── package.json            # { "private": true, "workspaces": ["apps/*","packages/*"] }
├── apps/
│   ├── web/                # depends on @forge/types, @forge/ui
│   └── api/                # depends on @forge/types
└── packages/
    ├── types/              # the shared Order contract (no deps)
    └── ui/                 # depends on @forge/types
```
Express the dependency graph as data (from each package's manifest `dependencies`):
```js
const graph = {
  'apps/web':       ['packages/types', 'packages/ui'],
  'apps/api':       ['packages/types'],
  'packages/ui':    ['packages/types'],
  'packages/types': [],
};
```

## Tasks
1. **Lay out the workspace.** Root `package.json` with `workspaces: ["apps/*","packages/*"]`; `apps/web`, `apps/api`, `packages/types`, `packages/ui`.
2. **Extract shared code.** Move the duplicated `Order` type into `@forge/types`; the apps depend on it instead of copy-pasting.
3. **Enforce dependency direction.** Run a boundary check: apps may depend on packages; **a package must not depend on an app**; **no cycles**.
4. **Prove it.** A deliberately-wrong graph (a package depending on an app, or a cycle) must fail; the correct graph passes.

## Verify (example — using the shared validators)
```js
const { checkMonorepoBoundaries } = require('/tmp/pscaffold/validators.cjs');
const assert = require('node:assert');
const good = { 'apps/web':['packages/types','packages/ui'], 'apps/api':['packages/types'], 'packages/ui':['packages/types'], 'packages/types':[] };
assert.deepStrictEqual(checkMonorepoBoundaries(good), [], 'valid: apps→packages, no cycles');
const badDir = { 'packages/types':['apps/web'], 'apps/web':[] };          // package → app
assert.ok(checkMonorepoBoundaries(badDir).length >= 1, 'package depending on app is rejected');
const cycle = { 'packages/a':['packages/b'], 'packages/b':['packages/a'] }; // cycle
assert.ok(checkMonorepoBoundaries(cycle).some(i => /cycle/.test(i)), 'cycle detected');
console.log('MONOREPO VERIFIED: apps→packages enforced; package→app and cycles rejected');
```

## Deliverable
The monorepo layout + workspace config, the extracted shared package, and the passing boundary check (with the bad-layout failures shown) — plus a note on the drift the old copy-paste caused.

## Cleanup
```bash
rm -f /tmp/forge-platform/monorepo.cjs
```

## Check
`../solutions/lab-01-solution.md`.
