# Lab 00 — Toolchain, Config Validation & a Dockerfile Lint

**Lesson:** 00 · **Goal:** set up the platform toolchain and validate the two artifact types you'll write all module — a YAML config and a Dockerfile.

## Goal
Confirm you can parse/validate a config file and lint a Dockerfile, and trace one artifact from source to a running environment.

## Setup
```bash
mkdir -p /tmp/forge-platform && cd /tmp/forge-platform
npm init -y >/dev/null
npm i js-yaml
```
A tiny YAML config (`config.yml`) and a first Dockerfile (`Dockerfile`):
```yaml
# config.yml
service: forge-api
port: 8080
replicas: 2
```
```dockerfile
# Dockerfile
FROM node:22.13-bookworm-slim
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
USER node
HEALTHCHECK CMD node healthcheck.js
CMD ["node", "server.js"]
```

## Tasks
1. **Validate the config.** Parse `config.yml` with `js-yaml` and assert it has the keys you intended (`service`, `port`, `replicas`) with sane values — the way you'd type-check code.
2. **Lint the Dockerfile.** Parse the instructions and check basic hygiene: pinned (non-`latest`) base, a non-root `USER`, a `HEALTHCHECK`. (You'll deepen this in Lesson 2.)
3. **Trace an artifact.** In your notebook, follow one Forge app: source → built image → which environments run the same image, and what's configuration vs baked-in.
4. **Build-once explainer.** Write 5–8 sentences on what "build once, run anywhere" buys a team.

## Verify (example)
```js
// verify.cjs
const yaml = require('js-yaml');
const fs = require('node:fs');
const assert = require('node:assert');
const cfg = yaml.load(fs.readFileSync('config.yml', 'utf8'));
assert.strictEqual(cfg.service, 'forge-api');
assert.ok(cfg.port > 0 && cfg.replicas >= 1, 'sane config values');
// minimal Dockerfile lint
const df = fs.readFileSync('Dockerfile', 'utf8');
assert.ok(!/FROM\s+\S+:latest/i.test(df), 'base image not :latest');
assert.ok(/^USER (?!root)/im.test(df), 'runs non-root');
assert.ok(/HEALTHCHECK/i.test(df), 'has healthcheck');
console.log('SETUP VERIFIED: config parses + Dockerfile passes basic lint');
```
```bash
node verify.cjs
```

## Deliverable
`node --version`; the validated config; the Dockerfile lint result; and the artifact-lifecycle sketch for one Forge app.

## Cleanup
```bash
rm -f /tmp/forge-platform/verify.cjs   # keep the project; later labs build on it
```

## Check
`../solutions/lab-00-solution.md`.
