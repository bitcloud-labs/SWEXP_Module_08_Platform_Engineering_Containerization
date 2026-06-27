# Lab 07 — Automate the Build Platform

**Lesson:** 07 · **Goal:** a CI/CD pipeline with ordered, unskippable gates that deploys the built image — proven by parsing the pipeline and checking the policy.

## Goal
Define the Forge pipeline as YAML and validate the policy: ordered stages (install → lint → test → build → scan → push), a deploy gated on the build job, deploy promotes the **built (SHA-tagged)** image, and the install is deterministic.

## Setup
`.github/workflows/ci.yml`:
```yaml
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: npm ci
      - run: npm run lint
      - run: npm test
      - run: docker build -t forge-api:${{ github.sha }} .
      - run: trivy image forge-api:${{ github.sha }}
      - run: docker push forge-api:${{ github.sha }}
  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    steps:
      - run: kubectl set image deploy/forge-api api=forge-api:${{ github.sha }}
```

## Tasks
1. **Ordered stages** in the build job: `npm ci` → lint → test → build → scan → push.
2. **Gates are real:** the pipeline stops on any failing step (a failed test means no build/push/deploy).
3. **Deploy is gated:** `deploy` declares `needs: build` (only runs if build fully passed).
4. **Promote, don't rebuild:** deploy sets the image to the **SHA-tagged** artifact built+tested+scanned (not a rebuild, not `:latest`).
5. **Deterministic install** (`npm ci`).
6. **Validate** by parsing the YAML and checking these policies.

## Verify (example)
```js
const { loadYaml } = require('/tmp/pscaffold/validators.cjs');
const fs = require('node:fs'); const assert = require('node:assert');
const wf = loadYaml(fs.readFileSync('ci.yml', 'utf8'));
const steps = wf.jobs.build.steps.map(s => s.run || '').join('\n');
const order = ['npm ci', 'lint', 'test', 'docker build', 'trivy', 'docker push'];
let last = -1;
for (const stage of order) { const i = steps.indexOf(stage); assert.ok(i > last, 'stage in order: ' + stage); last = i; }
assert.strictEqual(wf.jobs.deploy.needs, 'build', 'deploy gated on build');
const deployStep = wf.jobs.deploy.steps.map(s => s.run || '').join('\n');
assert.ok(/forge-api:\$\{\{ github.sha \}\}/.test(deployStep), 'deploy promotes the SHA-tagged built image');
assert.ok(!/:latest/.test(deployStep), 'deploy does not use :latest');
assert.ok(/npm ci/.test(steps) && !/npm install/.test(steps), 'deterministic install');
console.log('CI VERIFIED: ordered gates (install→lint→test→build→scan→push), deploy needs build, promotes built image');
```

## Deliverable
The pipeline config, the passing validation (ordered gating stages, scan present, `deploy needs build`, promotes the SHA-tagged image, deterministic install), and a note on a release incident the unskippable pipeline prevents.

## Cleanup
```bash
rm -f /tmp/forge-platform/ci-check.cjs
```

## Check
`../solutions/lab-07-solution.md`.
