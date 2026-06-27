# Lab 02 — Containerize the Platform

**Lesson:** 02 · **Goal:** a hygienic Dockerfile + `.dockerignore` for the Forge API, proven by a best-practice linter.

## Goal
Write a Dockerfile that pins its base, orders layers for caching, runs non-root, has a healthcheck, and a `.dockerignore` that keeps the context clean — and prove it against a linter that fails a naive version.

## Setup
A **naive** Dockerfile (what to fix):
```dockerfile
FROM node:latest
COPY . .
RUN npm install
CMD ["node", "server.js"]
```
Your **target** Dockerfile:
```dockerfile
FROM node:22.13-bookworm-slim
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
USER node
HEALTHCHECK CMD node healthcheck.js
CMD ["node", "dist/server.js"]
```
And `.dockerignore`:
```
node_modules
.git
.env
*.log
dist
```

## Tasks
1. **Pin the base** (`node:22.13-bookworm-slim`, not `:latest`).
2. **Order for caching:** copy `package*.json` and `npm ci` **before** `COPY . .`, so code changes don't reinstall deps.
3. **Run non-root** (`USER node`).
4. **Add a `HEALTHCHECK`.**
5. **Ship a `.dockerignore`** excluding `node_modules`, `.git`, `.env`, logs.
6. **Lint both** — the naive Dockerfile must fail with specific findings; yours must pass clean.

## Verify (example — using the shared validators)
```js
const { lintDockerfile, lintDockerignore } = require('/tmp/pscaffold/validators.cjs');
const assert = require('node:assert');
const naive = `FROM node:latest
COPY . .
RUN npm install
CMD ["node","server.js"]`;
const good = `FROM node:22.13-bookworm-slim
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
USER node
HEALTHCHECK CMD node healthcheck.js
CMD ["node","dist/server.js"]`;
const naiveIssues = lintDockerfile(naive);
assert.ok(naiveIssues.length >= 3, 'naive flagged: ' + naiveIssues.join('; '));
assert.strictEqual(lintDockerfile(good).length, 0, 'target clean');
assert.strictEqual(lintDockerignore('node_modules\n.git\n.env\n*.log\ndist').length, 0, '.dockerignore complete');
console.log('DOCKERFILE VERIFIED: naive flagged [' + naiveIssues.join('; ') + ']; target + .dockerignore clean');
```

## Deliverable
The Dockerfile + `.dockerignore`, the before/after lint (naive findings → clean), and a note on what each fixed finding prevents in production.

## Cleanup
```bash
rm -f /tmp/forge-platform/dockerfile-lint.cjs
```

## Check
`../solutions/lab-02-solution.md`.
