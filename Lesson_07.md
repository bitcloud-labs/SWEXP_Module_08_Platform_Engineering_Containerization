# Lesson 07 — Automate the Build Platform

> **Role:** Platform Engineer · **Competency:** Build Automation · **Track:** CI · **Est. time:** 4 hours

---

## 🎫 Engineering Ticket

```
TICKET:      CI-4010
TITLE:       Builds and deploys are run by hand and skip steps under pressure
PRIORITY:    P1
TYPE:        Automation
DESCRIPTION: Today someone builds the images and pushes them manually; under
             pressure, tests or scans get skipped, and a bad build reaches users.
             Build the CI/CD pipeline: on every change, automatically install,
             lint, test, build the image, scan it, and push it — with deploys gated
             on the whole pipeline passing. The pipeline becomes the only path to
             production, so quality gates can't be skipped.

ACCEPTANCE CRITERIA:
  - A pipeline runs on every push/PR: install → lint → test → build → scan → push
  - Stages run in order; a failing stage stops the pipeline (no skipping gates)
  - Deploy is gated on all prior stages passing (and uses the built image)
  - Builds are cached/reproducible; the pipeline is defined as versioned config
```

## 🏢 Business Context

If shipping depends on a human remembering every step, steps get skipped — especially under pressure, which is exactly when skipping is most dangerous. CI/CD makes the pipeline the only path to production: every change automatically runs the same install, lint, test, build, scan, and push, and nothing deploys unless all of it passes. The quality gates become unskippable, the build becomes reproducible, and "did someone run the tests?" stops being a question. Automating the path to production is what lets a team ship often *and* safely.

## 🎯 Learning Objectives

- Define a CI/CD pipeline as versioned configuration
- Order stages so a failure stops the pipeline (unskippable gates)
- Gate deployment on all prior stages passing, using the built artifact
- Make builds cached and reproducible

## 📚 Technical Deep Dive

**The pipeline is versioned config.** Like everything else this module, CI is declarative text in the repo, reviewed in PRs:

```yaml
# .github/workflows/ci.yml (shape is similar across CI systems)
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci                      # deterministic install (Lesson 4)
      - run: npm run lint
      - run: npm test                    # gate: tests must pass
      - run: docker build -t forge-api:${{ github.sha }} .   # build the image
      - run: trivy image forge-api:${{ github.sha }}         # scan for vulnerabilities
      - run: docker push forge-api:${{ github.sha }}         # push to registry
  deploy:
    needs: build                         # gate: only if build job fully passed
    if: github.ref == 'refs/heads/main'
    steps:
      - run: kubectl set image deploy/forge-api api=forge-api:${{ github.sha }}
```

**Stages run in order; failure stops the line.** install → lint → test → build → scan → push. If tests fail, the pipeline stops *before* building and pushing — a broken build never reaches the registry, let alone production. The gates are unskippable because they're not optional steps a human chooses to run.

**Deploy is gated on the whole pipeline.** `deploy needs build`: deployment only happens if every prior stage passed, and it deploys the **exact image** that was built, tested, and scanned (tagged by commit SHA) — the build-once-run-anywhere artifact, promoted, not rebuilt.

**Scan as a gate.** Building the image isn't enough — scan it for known vulnerabilities (CVEs in base image / dependencies) and fail the pipeline on serious findings, so a vulnerable image doesn't ship. Security becomes part of the unskippable path.

**Reproducible, cached builds.** Use the deterministic install (`npm ci`, Lesson 4) and cache dependency/layer caches between runs so the pipeline is both reproducible and fast. The image built in CI is the artifact that runs in production.

**The pipeline is the only path to production.** No manual `docker push` to prod, no hand-deploys. If it didn't go through the pipeline, it doesn't ship — that's what makes the gates meaningful.

### Common gotchas
- Stages that don't actually gate (tests run but the pipeline continues on failure).
- Rebuilding the image for deploy instead of promoting the tested one (different artifact!).
- No vulnerability scan, so known-CVE images ship.
- Manual deploys that bypass the pipeline (gates become theater).
- Non-deterministic install (`npm install`) making CI flaky.

## 🧪 Hands-on Labs

Work through **`labs/lab-07-ci.md`**. You'll define the Forge CI/CD pipeline as YAML and a validator will parse it and assert the **pipeline policy**: the stages exist and are in order (install → lint → test → build → scan → push), `deploy` declares `needs: build` (gated), the deploy uses the **built image tag** (not a rebuild or `latest`), and the install is the deterministic one. A pipeline that lets tests fail without stopping, or rebuilds for deploy, fails the checks; the correct one passes.

## 🔍 Engineering Investigation

Trace a change through the pipeline: where does a failing test stop it, and what never happens as a result (no build, no push, no deploy)? Confirm the validator reports the ordered stages, the `deploy needs build` gate, the scan stage, and that deploy uses the SHA-tagged built image. Note one incident that "the pipeline is the only path to prod" would have prevented.

## 🤖 AI Engineering Exercise

Ask an AI to "write a CI pipeline for this app." **Verify** stages are ordered and actually gate (failure stops the line), there's a vulnerability scan, deploy is gated on prior stages and promotes the built image (not a rebuild/`latest`), and the install is deterministic. **Log** where it let a stage fail silently or rebuilt for deploy and your fix.

## 📝 Assignment

Submit the pipeline config, the passing validation (ordered gating stages, scan, `deploy needs build`, promotes the built image, deterministic install), and a note on a release incident the unskippable pipeline prevents.

## 🚀 Stretch Goal

Add image signing / provenance (sign the built image, verify the signature before deploy) or a staged rollout gate (deploy to staging, run smoke tests, then promote to prod), and explain the supply-chain or safety guarantee it adds.

## ✅ Definition of Done

- [ ] Pipeline runs on push/PR: install → lint → test → build → scan → push
- [ ] Stages ordered; a failure stops the pipeline (unskippable gates)
- [ ] Deploy gated on all prior stages; promotes the built (SHA-tagged) image
- [ ] Deterministic, cached builds; pipeline defined as versioned config
- [ ] Validation passes

## 🪞 Reflection

Which gate would have been skipped under deadline pressure if a human ran it? Why must deploy promote the *tested* image rather than rebuild — what could differ if it rebuilt?
