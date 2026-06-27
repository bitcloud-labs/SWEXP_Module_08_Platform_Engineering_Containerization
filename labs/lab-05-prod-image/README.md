# Lab 05 — Engineer Production Images

**Goal:** a **multi-stage**, minimal, non-root, healthchecked production image with
production-only dependencies and **no baked secrets** — proven by a production-image lint.

## What you do

Complete [`Dockerfile`](Dockerfile). It must:

1. **Be multi-stage:** a build stage `FROM <pinned-base> AS build`, then a separate runtime
   stage `FROM <pinned-base> AS runtime`. The toolchain/dev deps stay in the build stage.
2. **Use a minimal, pinned base** (e.g. `node:22.13-bookworm-slim`, not `:latest`).
3. **Install production-only deps** in the runtime stage — `npm ci --omit=dev` and/or
   `ENV NODE_ENV=production`.
4. **Copy only the build artifact** into runtime — at least one `COPY --from=build ...`
   (e.g. `COPY --from=build /app/dist ./dist`), not the whole tree.
5. **Run non-root** (`USER node`).
6. **Declare a `HEALTHCHECK`.**
7. **Bake no secrets** (no `ENV`/`ARG` named `*PASSWORD*`/`*SECRET*`/`*TOKEN*`/`*API_KEY*`).

```bash
npx bats labs/lab-05-prod-image/tests
```

## Definition of done

- Tests green.
- An analysis of the size/attack-surface reduction from multi-stage + minimal base +
  `--omit=dev`, and confirmation of non-root + healthcheck + no secrets.
