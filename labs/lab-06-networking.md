# Lab 06 — Build the Container Network

**Lesson:** 06 · **Goal:** a segmented network topology where the edge is exposed, the database is internal-only, and the web app can't reach the db — proven by parsing the topology.

## Goal
Design front/back network tiers and validate the security properties: the database publishes no host ports and is unreachable from the front tier; only the edge is exposed.

## Setup
A segmented `docker-compose.yml`:
```yaml
services:
  web:
    image: forge-web:1.0
    networks: [ frontend ]
    ports: [ "3000:3000" ]            # edge: published
  api:
    image: forge-api:1.0
    networks: [ frontend, backend ]   # bridges tiers
  db:
    image: postgres:16.2
    networks: [ backend ]             # internal only — no ports published
networks:
  frontend:
  backend:
    internal: true
```

## Tasks
1. **Two tiers:** `frontend` and `backend` networks; `backend` is `internal: true`.
2. **Edge only:** `web` publishes `3000`; `db` publishes **nothing**.
3. **Segment:** `web` on `frontend` only; `db` on `backend` only; `api` on **both** (the only bridge).
4. **Reachability:** prove web→api (shared frontend) yes; web→db **no** (no shared network); api→db yes; host→db **no** (unpublished).
5. **Validate** by parsing the topology and computing reachability.

## Verify (example)
```js
const { loadYaml } = require('/tmp/pscaffold/validators.cjs');
const fs = require('node:fs'); const assert = require('node:assert');
const c = loadYaml(fs.readFileSync('docker-compose.yml', 'utf8'));
const nets = s => new Set(c.services[s].networks || []);
const canReach = (a, b) => [...nets(a)].some(n => nets(b).has(n));   // share a network?
const published = s => (c.services[s].ports || []).length > 0;
assert.ok(!published('db'), 'database publishes NO host ports');
assert.ok(!nets('db').has('frontend'), 'database not on the frontend network');
assert.strictEqual(c.networks.backend.internal, true, 'backend network is internal');
assert.ok(canReach('web', 'api'), 'web can reach api');
assert.ok(!canReach('web', 'db'), 'web CANNOT reach db');
assert.ok(canReach('api', 'db'), 'api can reach db');
assert.ok(published('web'), 'edge (web) is published');
console.log('NETWORK VERIFIED: db internal-only & unreachable from edge; api bridges; least exposure');
```

## Deliverable
The segmented topology, the passing validation, a reachability table (web→api yes, web→db no, api→db yes, host→db no) before vs after, and a note on the blast-radius reduction.

## Cleanup
```bash
rm -f /tmp/forge-platform/net-check.cjs
```

## Check
`../solutions/lab-06-solution.md`.
