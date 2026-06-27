# Dockerfile Lint Reference

A checklist of the best-practice checks the labs enforce. Use it as a pre-commit review for any Dockerfile.

## Base image
- [ ] Pinned tag (not `:latest`, ideally a digest) — reproducible builds.
- [ ] Minimal base (`-slim`/distroless) for size and attack surface.

## Layer order (cache)
- [ ] `COPY package*.json` + install **before** `COPY . .`.
- [ ] Rarely-changing instructions before often-changing ones.

## Runtime hygiene
- [ ] `USER` is non-root.
- [ ] `HEALTHCHECK` defined (the orchestrator consumes it).
- [ ] Config/secrets come from the environment — none baked in.

## Production (multi-stage) — additionally
- [ ] ≥ 2 `FROM` stages: build tooling stays in the build stage.
- [ ] Runtime installs production-only deps (`--omit=dev` / `NODE_ENV=production`).
- [ ] Final stage copies **only the artifact** (`COPY --from=build ...`), not `COPY . .`.

## Build context
- [ ] `.dockerignore` excludes `node_modules`, `.git`, `.env`, logs, build output.

## What each prevents
| Check | Prevents |
|-------|----------|
| pinned base | non-reproducible builds |
| layer order | slow builds (cache busting) |
| non-root | root compromise inside the container |
| healthcheck | the orchestrator can't tell health |
| multi-stage / `--omit=dev` | shipping the toolchain + dev deps |
| only-artifact copy | bloated image, leaked source |
| `.dockerignore` | leaked `.env`/`.git`, bloated context |
