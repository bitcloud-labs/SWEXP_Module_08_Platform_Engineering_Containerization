# Lab 04 — Eliminate "Works on My Machine"

**Lesson:** 04 · **Goal:** a reproducible toolchain — pinned versions, committed lockfile, deterministic install, and a dev container — proven by a reproducibility check.

## Goal
Make the dev environment deterministic and prove it: pinned toolchain, a lockfile installed with `npm ci`, and a pinned dev-container image matching CI.

## Setup
`package.json` (pinned toolchain) and a dev container config:
```jsonc
// package.json
{ "name": "forge", "engines": { "node": "22.13.x" }, "packageManager": "pnpm@9.7.0",
  "dependencies": { "express": "4.19.2" } }     // pinned, not "^4"
```
```jsonc
// .devcontainer/devcontainer.json
{ "image": "mcr.microsoft.com/devcontainers/javascript-node:22",
  "postCreateCommand": "npm ci" }                // deterministic install, not npm install
```
A committed `package-lock.json` (present in the repo).

## Tasks
1. **Pin the toolchain:** `engines.node` and `packageManager` to exact versions.
2. **Pin dependencies + commit the lockfile;** install with **`npm ci`** (installs the lockfile exactly), not `npm install` (re-resolves).
3. **Define a dev container** with a **pinned** image so every engineer codes in the same environment.
4. **Match CI:** the install command and base used in the dev container are what CI uses (Lesson 7).
5. **Validate reproducibility:** a "drifty" setup (floating deps, no lockfile, `npm install`, unpinned Node) fails; the pinned one passes.

## Verify (example)
```js
const assert = require('node:assert');
function checkReproducibility(pkg, devcontainer, hasLockfile) {
  const issues = [];
  if (!pkg.engines || !/^\d/.test((pkg.engines.node||'').replace(/[~^]/,''))) issues.push('node not pinned');
  if (!pkg.packageManager) issues.push('package manager not pinned');
  if (!hasLockfile) issues.push('lockfile not committed');
  if (!/npm ci|--frozen-lockfile/.test(devcontainer.postCreateCommand || '')) issues.push('non-deterministic install');
  if (!/:\S/.test(devcontainer.image || '')) issues.push('dev container image not pinned');
  for (const [, v] of Object.entries(pkg.dependencies || {})) if (/^[\^~]/.test(v)) issues.push('floating dependency: ' + v);
  return issues;
}
const goodPkg = { engines:{node:'22.13.x'}, packageManager:'pnpm@9.7.0', dependencies:{express:'4.19.2'} };
const goodDc  = { image:'mcr.microsoft.com/devcontainers/javascript-node:22', postCreateCommand:'npm ci' };
assert.deepStrictEqual(checkReproducibility(goodPkg, goodDc, true), [], 'pinned setup reproducible');
const driftyPkg = { dependencies:{ express:'^4' } };
const driftyDc  = { image:'node', postCreateCommand:'npm install' };
assert.ok(checkReproducibility(driftyPkg, driftyDc, false).length >= 4, 'drifty setup flagged');
console.log('REPRODUCIBILITY VERIFIED: pinned+lockfile+ci+pinned-image clean; drifty flagged');
```

## Deliverable
The pinned toolchain + committed lockfile + `npm ci` install, the dev-container config, the passing reproducibility check (with drifty failures shown), and a note on a host-drift bug the dev container eliminates.

## Cleanup
```bash
rm -f /tmp/forge-platform/repro-check.cjs
```

## Check
`../solutions/lab-04-solution.md`.
