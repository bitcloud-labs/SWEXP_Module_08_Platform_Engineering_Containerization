# Production Image Guide

## Multi-stage: build in one stage, ship a clean one
```dockerfile
FROM node:22.13-bookworm-slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:22.13-bookworm-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production
COPY package*.json ./
RUN npm ci --omit=dev          # production deps only
COPY --from=build /app/dist ./dist   # ONLY the artifact
USER node
HEALTHCHECK CMD node healthcheck.js
CMD ["node", "dist/server.js"]
```
The compilers and dev dependencies stay in `build` and never reach production.

## Minimal base = smaller + safer
`-slim` drops hundreds of MB; **distroless** goes further (no shell, no package manager) — less size and less attack surface (no shell for an attacker). Trade-off: harder to `exec`/debug.

## Only the artifact ships
Final image = runtime + production deps + built output. Not source, not dev deps, not build cache. Fewer things to have a CVE.

## Non-root, healthcheck, no secrets
Non-negotiable for production: a non-root `USER`, a `HEALTHCHECK` the orchestrator consumes, and no secrets baked in (they're injected at runtime).

## Size & surface are metrics
Image size (pull/deploy time, storage) and package/CVE count are real production numbers. Multi-stage + minimal base typically turns >1 GB into tens-to-low-hundreds of MB — attribute the win to specific choices.

## Gotchas
- Single-stage shipping the toolchain; a fat base; `COPY . .` into the final stage.
- Root in production; baked secrets; no healthcheck.
