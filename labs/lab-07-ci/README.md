# Lab 07 — Automate the Build Platform

**Goal:** a CI/CD pipeline with **ordered, unskippable gates** that **promotes the built
image** — proven by parsing the pipeline and checking the policy.

## What you do

Complete [`ci.yml`](ci.yml) — a GitHub Actions workflow. (We grade it as `ci.yml` in this
folder; in a real repo it would live at `.github/workflows/ci.yml`.) It must:

1. **A `build` job with ordered steps**, in this order:
   `npm ci` → `lint` → `test` → `docker build` → `trivy` (scan) → `docker push`.
   Use the commit SHA to tag the image, e.g.
   `docker build -t forge-api:${{ github.sha }} .`
2. **Deterministic install** — `npm ci`, **not** `npm install`.
3. **A `deploy` job gated on build** — `deploy` declares `needs: build` (it only runs if
   build fully passed).
4. **Promote, don't rebuild** — the deploy step sets the image to the **SHA-tagged** artifact
   (`forge-api:${{ github.sha }}`) and must **not** use `:latest`.

```bash
npx bats labs/lab-07-ci/tests
```

## How it's graded

`python3` parses the workflow YAML and checks: stage ordering in `build`, deterministic
install, `deploy.needs == build`, the deploy promotes the SHA-tagged image, and no `:latest`.

## Definition of done

- Tests green.
- A note on a release incident the unskippable pipeline prevents.
