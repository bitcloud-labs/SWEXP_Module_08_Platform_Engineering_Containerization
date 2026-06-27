# CI/CD Guide

## The pipeline is versioned config
```yaml
on: [push, pull_request]
jobs:
  build:
    steps:
      - run: npm ci                                       # deterministic
      - run: npm run lint
      - run: npm test                                      # gate
      - run: docker build -t forge-api:${{ github.sha }} . # build the image
      - run: trivy image forge-api:${{ github.sha }}       # scan
      - run: docker push forge-api:${{ github.sha }}       # push
  deploy:
    needs: build                                           # gate
    if: github.ref == 'refs/heads/main'
    steps:
      - run: kubectl set image deploy/forge-api api=forge-api:${{ github.sha }}
```

## Ordered, unskippable gates
install → lint → test → build → scan → push. A failing step stops the line — a broken or vulnerable build never reaches the registry, let alone production. Gates aren't optional steps a human chooses to run.

## Promote, don't rebuild
Deploy sets the image to the **exact SHA-tagged artifact** that was built, tested, and scanned (build once, run anywhere). Rebuilding for deploy could produce a different image than what you tested.

## Scan as a gate
Fail the pipeline on serious CVEs in the base/dependencies so a vulnerable image doesn't ship — security on the unskippable path.

## The pipeline is the only path to production
No manual `docker push` to prod, no hand-deploys. If it didn't go through the pipeline, it doesn't ship — that's what makes the gates meaningful.

## Gotchas
- Stages that don't actually gate (continue on failure).
- Rebuilding for deploy instead of promoting; deploying `:latest`.
- No scan; non-deterministic `npm install`; manual deploys bypassing the pipeline.
