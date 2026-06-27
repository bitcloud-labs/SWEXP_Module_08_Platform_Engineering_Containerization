# Platform Setup Guide

## The toolchain
You write **infrastructure-as-code** — Dockerfiles and YAML (compose, CI, Kubernetes). The verification tools are plain Node, no container runtime needed:
```bash
mkdir -p /tmp/forge-platform && cd /tmp/forge-platform
npm init -y && npm i js-yaml      # a real YAML parser for compose/CI/k8s
```

## Why no Docker/Kubernetes here
These artifacts are **declarative**: their correctness is whether they *declare* the right thing. You verify that by parsing and policy-checking the real files — the same files run unchanged on a machine with Docker/Kubernetes. (`js-yaml` is CommonJS: `const yaml = require('js-yaml')`.)

## The verify loop
| Tool | Verifies |
|------|----------|
| Dockerfile linter | pinned base, multi-stage, non-root, healthcheck, layer order, .dockerignore |
| `yaml.load(...)` + asserts | compose graph, CI pipeline policy, k8s manifest structure |
| `node` logic tests | dependency boundaries, reproducibility, network reachability, gate order |

## A minimal validator
```js
const yaml = require('js-yaml');
const fs = require('node:fs');
const doc = yaml.load(fs.readFileSync('docker-compose.yml', 'utf8'));
// assert what you intended: services, wiring, health gates, ports...
```

## Gotchas
- `js-yaml` is CommonJS — use `require`, not `import ... from` in an `.mjs`.
- Validate the artifact you actually ship (don't lint a different file than you build).
- The same Dockerfile/compose/manifest is the source of truth everywhere — keep it in the repo, reviewed.
