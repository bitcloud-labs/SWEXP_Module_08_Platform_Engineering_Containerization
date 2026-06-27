# Lab 08 — Build the Production Container Platform

**Lesson:** 08 · **Goal:** production manifests (Deployment + Service) with replicas, probes, resource limits, a pinned image, and zero-downtime rollout — proven by parsing and policy-checking the YAML.

## Goal
Author the Forge production manifests and validate the production properties a naive single-container setup lacks.

## Setup
A **naive** Deployment (what to fix):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata: { name: forge-api }
spec:
  replicas: 1
  template:
    spec:
      containers:
        - name: api
          image: forge-api:latest
```
Your **production** Deployment:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata: { name: forge-api }
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate: { maxUnavailable: 0, maxSurge: 1 }
  template:
    spec:
      containers:
        - name: api
          image: forge-api:1.4.2
          resources:
            requests: { cpu: "100m", memory: "128Mi" }
            limits:   { cpu: "500m", memory: "256Mi" }
          readinessProbe: { httpGet: { path: /readyz, port: 8080 }, initialDelaySeconds: 5 }
          livenessProbe:  { httpGet: { path: /healthz, port: 8080 }, periodSeconds: 10 }
          envFrom:
            - secretRef: { name: forge-api-secrets }
```

## Tasks
1. **Replicas ≥ 2** (redundancy + headroom).
2. **Rolling update** with `maxUnavailable: 0` (zero-downtime).
3. **Resource requests and limits** (scheduler guarantee + cap).
4. **Both probes:** readiness (traffic) and liveness (restart) — keep liveness trivial, readiness dependency-aware (Module 06).
5. **Pinned image** (`forge-api:1.4.2`, not `latest`); **config/secrets via references** (`secretRef`), not inline plaintext.
6. **Validate** by parsing the YAML — the naive manifest fails with specific findings; the production one passes.

## Verify (example)
```js
const { loadYaml } = require('/tmp/pscaffold/validators.cjs');
const fs = require('node:fs'); const assert = require('node:assert');
function lintManifest(d) {
  const issues = [];
  if (!(d.spec.replicas >= 2)) issues.push('replicas < 2 (no redundancy)');
  if (d.spec.strategy?.type !== 'RollingUpdate' || d.spec.strategy.rollingUpdate?.maxUnavailable !== 0) issues.push('not zero-downtime rolling update');
  const c = d.spec.template.spec.containers[0];
  if (!c.resources?.limits?.cpu || !c.resources?.limits?.memory) issues.push('no resource limits');
  if (!c.resources?.requests) issues.push('no resource requests');
  if (!c.readinessProbe) issues.push('no readiness probe');
  if (!c.livenessProbe) issues.push('no liveness probe');
  if (/:latest$/.test(c.image) || !/:/.test(c.image)) issues.push('image not pinned (:latest or untagged)');
  return issues;
}
const prod = loadYaml(fs.readFileSync('deployment.yml', 'utf8'));
assert.strictEqual(lintManifest(prod).length, 0, 'production manifest clean');
const naive = loadYaml(`apiVersion: apps/v1
kind: Deployment
spec:
  replicas: 1
  template: { spec: { containers: [ { name: api, image: forge-api:latest } ] } }`);
const naiveIssues = lintManifest(naive);
assert.ok(naiveIssues.length >= 5, 'naive flagged: ' + naiveIssues.join('; '));
console.log('PRODUCTION VERIFIED: prod manifest clean; naive flagged [' + naiveIssues.join('; ') + ']');
```

## Deliverable
The Deployment + Service manifests, the passing validation (replicas ≥ 2, rolling update `maxUnavailable: 0`, requests+limits, both probes, pinned image, referenced secrets), a trace of a zero-downtime rollout + rollback, and a note on what each property prevents in an incident.

## Cleanup
```bash
rm -f /tmp/forge-platform/manifest-check.cjs
```

## Check
`../solutions/lab-08-solution.md`.
