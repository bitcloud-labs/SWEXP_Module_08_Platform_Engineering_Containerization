# Lab 02 — Containerize the Platform

**Goal:** a hygienic `Dockerfile` + `.dockerignore` for the Forge API, plus a tiny image you
actually **build and run** to prove the toolchain works end to end.

## What you do

### 1. Author the hygienic `Dockerfile` (static lint)

Edit [`Dockerfile`](Dockerfile) so it passes the linter. It must:

1. **Pin the base** — a real tag, **not** `:latest` (e.g. `FROM node:22.13-bookworm-slim`).
2. **Order layers for caching** — `COPY package*.json ./` and the install (`RUN npm ci`)
   **before** `COPY . .`, so a source change doesn't reinstall dependencies.
3. **Run non-root** — `USER node` (not root).
4. **Add a `HEALTHCHECK`.**
5. Use a deterministic install (`npm ci`, **not** `npm install`).
6. **No baked secrets** — no `ENV`/`ARG` named like a secret (`*PASSWORD*`, `*SECRET*`,
   `*TOKEN*`, `*API_KEY*`).

### 2. Author the `.dockerignore` (static lint)

Edit [`.dockerignore`](.dockerignore) so it excludes at least: `node_modules`, `.git`,
`.env`, and logs (`*.log`).

### 3. Build a tiny image for real

Edit [`greeting/Dockerfile`](greeting/Dockerfile) — a minimal **alpine/busybox** image whose
`CMD` prints exactly `forge-up`. The grader runs `docker build` then `docker run` on it and
checks the output. Keep it tiny (no installs) so the build is fast.

```bash
npx bats labs/lab-02-dockerfile/tests
```

> The real-build test needs Docker. If Docker is unavailable locally, that single test will
> fail but the static-lint tests still run; CI has Docker.

## Definition of done

- `Dockerfile` and `.dockerignore` pass the lint tests.
- `greeting/Dockerfile` builds and `docker run` prints `forge-up`.
- A note on what each fixed finding prevents in production.
