# FORGE-9600 Capstone Submission — [Your Name]

**Date:** [date] · **Time spent:** [hours] · **Repo:** [link]

## Executive summary
2–4 sentences: what you shipped, your platform approach (the build order), and the headline result — what the platform guarantees about reproducibility, security, and operability, and how you know.

## Per-phase record
Repeat for each phase (A repo & local dev → B reproducibility → C network & automation → D production + report).

### Phase X — [name]
- **What I built:** [monorepo / Dockerfiles / compose / dev container / production images / network / pipeline / manifests]
- **Key decisions & why:** [boundaries, pinning, multi-stage, health gates, segmentation, gates, rollout]
- **Evidence:** Dockerfile lint / YAML parse + policy / logic-check results / before-after

```dockerfile
# or yaml — representative artifact for this phase
```

## Repository architecture
The monorepo layout; the shared packages; the passing dependency-boundary check (apps → packages, no cycles).

## Developer experience
The one-command dev environment (compose), the health-gated startup, the before/after onboarding (manual steps → one command).

## Container platform
The hygienic images (lint clean) and the segmented network (db unpublished, off the frontend, backend internal); the reachability table.

## Reproducibility
Pinned toolchain + committed lockfile + `npm ci`; the dev container matching CI; the reproducibility check passing.

## Production images
The multi-stage production Dockerfile; the production lint passing; the size/attack-surface reduction attributed to specific choices.

## Build automation
The pipeline's ordered unskippable gates (install→lint→test→build→scan→push); `deploy needs build`; deploy promotes the SHA-tagged built image.

## Production readiness & operability
The Deployment + Service: replicas ≥ 2, rolling update (`maxUnavailable: 0`), requests+limits, liveness+readiness, pinned image, injected secrets; a trace of a zero-downtime rollout + rollback.

## Reproducibility, security & operability summary
What each bar guarantees and how you verified it.

## AI-usage log
| Asked | AI suggested | Verified (lint/parse/policy) | Outcome |
|-------|-------------|------------------------------|---------|
| | | | |
Include at least one case where a check **overruled** the AI (e.g. `:latest`, single-stage image, root container, published database, non-gating pipeline, single replica, no limits/probes).

## Reflection
The integration decision with the widest blast radius; where a reproducibility/security/operability bar forced a change you'd have skipped under time pressure; how you'd evolve the platform next (autoscaling, signing, observability).

---
**Self-check vs rubric:** [ ] Repository Architecture [ ] Developer Experience [ ] Container Platform [ ] Build Automation [ ] Production Readiness [ ] Documentation [ ] Operational Quality [ ] Engineering Judgment [ ] AI Workflow
