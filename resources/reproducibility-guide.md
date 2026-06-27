# Reproducibility Guide

## Determinism = same inputs → same outputs
A build should depend only on committed inputs (source, pinned versions, lockfiles), never on what's installed on the host.

## Pin versions; commit the lockfile
```jsonc
{ "engines": { "node": "22.13.x" }, "packageManager": "pnpm@9.7.0",
  "dependencies": { "express": "4.19.2" } }   // pinned, not "^4"
```
- A loose range (`^4`) resolves differently over time/machines.
- A committed lockfile records exact resolved versions.
- Install with **`npm ci`** (installs the lockfile exactly), not `npm install` (re-resolves).

## The dev container = environment as code
```jsonc
// .devcontainer/devcontainer.json
{ "image": "mcr.microsoft.com/devcontainers/javascript-node:22",
  "postCreateCommand": "npm ci" }
```
Everyone codes in the same OS/runtime/tools — and the same as CI. Pin its image (ideally by digest).

## Dev matches CI matches production base
One reproducible toolchain everywhere, so "passes locally" predicts "passes in CI", and the production image (Lesson 5) builds from the same base.

## Layered reproducibility
Lockfiles pin **dependencies**; the dev container pins the **environment**; the image pins the **runtime**.

## Gotchas
- `npm install` instead of `npm ci`; lockfile uncommitted.
- Unpinned toolchain (Node/PM); a dev container that drifts from CI/production.
