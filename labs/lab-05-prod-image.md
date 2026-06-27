# Lab 05 — Engineer Production Images

**Lesson:** 05 · **Goal:** a multi-stage, minimal, non-root, healthchecked production image with production-only deps and no secrets — proven by the production-image linter.

## Goal
Engineer a production Dockerfile that keeps the build toolchain out of the final image and ships only the runtime artifact, and prove it against a stricter production lint.

## Setup
A **naive** single-stage image (what to fix):
```dockerfile
FROM node
COPY . .
RUN npm install
CMD ["node", "server.js"]
```
Your **production** Dockerfile (multi-stage):
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
RUN npm ci --omit=dev
COPY --from=build /app/dist ./dist
USER node
HEALTHCHECK --interval=30s CMD node healthcheck.js
CMD ["node", "dist/server.js"]
```

## Tasks
1. **Multi-stage:** build in one stage, ship a clean runtime stage (toolchain/dev deps stay behind).
2. **Minimal, non-root base** (`-slim`; `USER node`).
3. **Production-only deps** in the runtime stage (`npm ci --omit=dev` / `NODE_ENV=production`).
4. **Copy only the artifact** (`COPY --from=build /app/dist ./dist`), not the whole tree.
5. **HEALTHCHECK**, and **no baked secrets**.
6. **Lint with the production linter** — the naive image fails with specific findings; yours passes.

## Verify (example — using the shared validators)
```js
const { lintProdImage } = require('/tmp/pscaffold/validators.cjs');
const assert = require('node:assert');
const naive = `FROM node
COPY . .
RUN npm install
CMD ["node","server.js"]`;
const prod = `FROM node:22.13-bookworm-slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
FROM node:22.13-bookworm-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production
COPY package*.json ./
RUN npm ci --omit=dev
COPY --from=build /app/dist ./dist
USER node
HEALTHCHECK CMD node healthcheck.js
CMD ["node","dist/server.js"]`;
const naiveIssues = lintProdImage(naive);
assert.ok(naiveIssues.length >= 4, 'naive flagged: ' + naiveIssues.join('; '));
assert.strictEqual(lintProdImage(prod).length, 0, 'production image clean');
console.log('PROD IMAGE VERIFIED: naive flagged [' + naiveIssues.join('; ') + ']; production multi-stage clean');
```

## Deliverable
The multi-stage production Dockerfile, the before/after production lint, an analysis of the size/attack-surface reduction attributed to specific choices (multi-stage, minimal base, `--omit=dev`), and confirmation of non-root + healthcheck + no secrets.

## Cleanup
```bash
rm -f /tmp/forge-platform/prod-lint.cjs
```

## Check
`../solutions/lab-05-solution.md`.
