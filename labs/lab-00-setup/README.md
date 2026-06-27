# Lab 00 — Toolchain, Config Validation & a Dockerfile Lint

**Goal:** validate the two artifact types you'll write all module — a YAML **config** and a
**Dockerfile** — the way you'd type-check code.

## What you do

Edit the two starter files in this folder:

1. **[`config.yml`](config.yml)** — a tiny service config. It must declare:
   - `service: forge-api`
   - `port:` a positive integer (use `8080`)
   - `replicas:` an integer `>= 1` (use `2`)

2. **[`Dockerfile`](Dockerfile)** — a first, hygienic Dockerfile. It must:
   - **Pin** its base image (a real tag, **not** `:latest` and not untagged) —
     e.g. `FROM node:22.13-bookworm-slim`.
   - Run as a **non-root** user (`USER node`, not `USER root`).
   - Declare a `HEALTHCHECK`.

Run the tests:

```bash
npx bats labs/lab-00-setup/tests
# or everything: npm run grade
```

## How it's graded

`config.yml` is parsed with `python3` (PyYAML if present, else a tiny fallback parser) and
its keys/values are asserted. The `Dockerfile` is statically linted with `grep`/`awk` — the
same checks `hadolint` would start with.

## Definition of done

- `npx bats labs/lab-00-setup/tests` is green.
- In your LMS notebook: explain "build once, run anywhere", and why a pinned base + non-root
  + healthcheck matter before you ever run the image.
