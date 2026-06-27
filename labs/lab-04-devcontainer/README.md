# Lab 04 — Eliminate "Works on My Machine"

**Goal:** a reproducible toolchain — pinned versions, a committed lockfile, a deterministic
install, and a pinned dev-container image — proven by a reproducibility check.

## What you do

Edit the three starter files in this folder:

1. **[`package.json`](package.json):**
   - `engines.node` pinned to an exact version (starts with a digit, e.g. `22.13.x`).
   - `packageManager` pinned (e.g. `pnpm@9.7.0`).
   - every entry in `dependencies` pinned to an **exact** version — **no** `^` or `~`
     (e.g. `"express": "4.19.2"`).

2. **[`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json):**
   - `image` **pinned** to a tag (contains `:` followed by a tag, not a bare `node`).
   - `postCreateCommand` installs deterministically: it must use `npm ci`
     (or `--frozen-lockfile`), **not** `npm install`.

3. **[`package-lock.json`](package-lock.json):** commit a real lockfile (it must exist and be
   valid JSON). A `npm install` in this folder will generate one for you.

```bash
npx bats labs/lab-04-devcontainer/tests
```

## How it's graded

`python3` reads the two JSON files and applies the reproducibility rules above; a "drifty"
setup (floating deps, no lockfile, `npm install`, unpinned image) would be flagged.

## Definition of done

- Tests green.
- A note on a host-drift bug a pinned dev container eliminates.
