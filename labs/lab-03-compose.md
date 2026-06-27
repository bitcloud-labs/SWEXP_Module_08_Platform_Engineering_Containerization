# Lab 03 — Build a One-Command Development Environment

**Lesson:** 03 · **Goal:** a `docker-compose.yml` that brings up web + api + db, wired by name, health-gated, with a persistent volume — proven by parsing the compose graph.

## Goal
Define the whole Forge stack in one compose file and validate the wiring: name-based connections, health-gated startup, a persistent DB volume, and only the intended published ports.

## Setup
`docker-compose.yml`:
```yaml
services:
  db:
    image: postgres:16.2
    environment: { POSTGRES_PASSWORD: devpass }
    volumes: [ "forge-data:/var/lib/postgresql/data" ]
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "postgres"]
      interval: 5s
  api:
    build: ./apps/api
    environment: { DATABASE_URL: "postgres://postgres:devpass@db:5432/forge" }
    depends_on:
      db: { condition: service_healthy }
    ports: [ "8080:8080" ]
  web:
    build: ./apps/web
    environment: { API_URL: "http://api:8080" }
    depends_on:
      api: { condition: service_started }
    ports: [ "3000:3000" ]
volumes:
  forge-data:
```

## Tasks
1. **Define all three services** (web, api, db) in one file.
2. **Wire by name:** the api's `DATABASE_URL` points at `db`, the web's `API_URL` at `api` — service names, not IPs.
3. **Health-gate startup:** `api depends_on db: { condition: service_healthy }`, backed by the db's `healthcheck`.
4. **Persist data:** a named volume on the db.
5. **Publish only what developers need** (web 3000, api 8080).
6. **Validate the graph** by parsing the YAML and asserting the wiring.

## Verify (example)
```js
const { loadYaml } = require('/tmp/pscaffold/validators.cjs');
const fs = require('node:fs'); const assert = require('node:assert');
const c = loadYaml(fs.readFileSync('docker-compose.yml', 'utf8'));
assert.ok(c.services.db && c.services.api && c.services.web, 'three services');
assert.strictEqual(c.services.api.depends_on.db.condition, 'service_healthy', 'api waits for healthy db');
assert.ok(c.services.db.healthcheck, 'db has a healthcheck');
assert.ok((c.services.db.volumes || []).some(v => /forge-data/.test(v)), 'db has a persistent volume');
assert.ok(/@db:/.test(c.services.api.environment.DATABASE_URL), 'api connects to db by name');
assert.ok(/api:/.test(c.services.web.environment.API_URL), 'web connects to api by name');
console.log('COMPOSE VERIFIED: 3 services, name-wired, health-gated, volume + ports');
```

## Deliverable
The `docker-compose.yml`, the passing validation (name wiring, health-gated `depends_on`, persistent volume, published ports), and the before/after of developer setup (manual steps → one command).

## Cleanup
```bash
rm -f /tmp/forge-platform/compose-check.cjs
```

## Check
`../solutions/lab-03-solution.md`.
