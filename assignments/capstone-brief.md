# Capstone Brief — FORGE-9600: Ship the Project Forge Engineering Platform

> **Epic:** FORGE-9600 · **Role:** Platform Engineer (owner) · **Est. time:** 16–20 hours (staged) · **Submission:** `capstone-submission-template.md`

## The situation
*Project Forge* — a web frontend (M05), an API (M06), and a data layer (M07) — runs only on the original authors' laptops, set up by hand. You own turning it into a reproducible **engineering platform**: one repo, containerized services, a one-command dev environment, a reproducible toolchain, lean production images, a segmented network, automated CI/CD, and a production orchestration setup. You integrate everything from this module into one coherent platform and prove each quality bar with evidence.

The capstone introduces **no new concepts.** It tests **integration, reproducibility, and judgment**: the monorepo, the images, the network, the pipeline, and the orchestration all interact, and reproducibility, security, and operability can't be bolted on at the end.

## Platform scope
A working Forge platform (as infrastructure-as-code) with at least:
- **Monorepo** — apps/packages boundaries, shared packages, enforced dependency direction (Lesson 1).
- **Containerized services** — hygienic, pinned, non-root Dockerfiles with `.dockerignore` (Lesson 2).
- **One-command dev environment** — a compose stack wiring web + api + db, health-gated, with a volume (Lesson 3).
- **Reproducible toolchain** — pinned versions, committed lockfile, dev container matching CI (Lesson 4).
- **Production images** — lean multi-stage, minimal, non-root, healthchecked, no secrets (Lesson 5).
- **Segmented network** — edge exposed, database internal-only, blast radius limited (Lesson 6).
- **CI/CD** — ordered unskippable gates (install→lint→test→build→scan→push), deploy promotes the built image (Lesson 7).
- **Production orchestration** — replicas, probes, resource limits, injected config, zero-downtime rollouts (Lesson 8).

## Build order (follow it)
1. **Repository** — the monorepo with boundaries + enforced dependency direction. (Lesson 1)
2. **Containers + dev environment** — Dockerfiles and the one-command compose stack. (Lessons 2, 3)
3. **Reproducibility** — pinned toolchain, committed lockfile, dev container matching CI. (Lesson 4)
4. **Production images** — lean multi-stage, minimal, non-root, healthchecked. (Lesson 5)
5. **Network** — segmented tiers, edge-only exposure, internal-only database. (Lesson 6)
6. **CI/CD + production** — the unskippable pipeline and the orchestrated production setup; assemble the report. (Lessons 7, 8)

Keep every artifact validating (lint/parse/policy-check green) throughout; build in small, verified increments.

## Phases (stage the work)
- **Phase A — Repository & local dev (monorepo + containers + compose).**
- **Phase B — Reproducibility (pinned toolchain + dev container + production images).**
- **Phase C — Network & automation (segmentation + CI/CD pipeline).**
- **Phase D — Production + the platform report (orchestration manifests + report).**

## Acceptance criteria → rubric mapping
| Acceptance criterion | Rubric category |
|----------------------|-----------------|
| Monorepo: clear boundaries, shared packages, enforced dependency direction | Repository Architecture (15%) |
| One-command dev environment; compose health-gated; fast onboarding | Developer Experience (15%) |
| Containerized services + segmented network: hygienic images, internal-only db | Container Platform (15%) |
| CI/CD with ordered unskippable gates; deploy promotes the built image | Build Automation (10%) |
| Production orchestration: replicas, probes, limits, zero-downtime rollout | Production Readiness (10%) |
| Platform report documents each bar with reproducible evidence | Documentation (10%) |
| Reproducible toolchain, healthchecks, operable rollouts/rollback | Operational Quality (10%) |
| Sound, justified design; right trade-offs; no over-engineering; least privilege | Engineering Judgment (10%) |
| AI used as draft → verify → log | AI Workflow (5%) |

## Deliverables
1. **The working platform** — validating infrastructure-as-code (Dockerfiles lint clean, compose/CI/k8s YAML parses + policy-checks green, monorepo boundaries + reproducibility enforced), reproducible. Reuse the lab generators and validators so the build is checkable.
2. **An engineering-platform report** proving each quality bar with evidence: the enforced monorepo boundaries; the image hygiene lint; the one-command health-gated dev environment; the reproducibility checks; the production-image lint; the segmented network proving the database is unreachable from the edge; the pipeline's ordered unskippable gates and built-image promotion; and the production manifests' replicas/probes/limits/zero-downtime rollout.
3. **The engineering notebook**, including the **AI-usage log**.
4. **A "reproducibility, security & operability" summary** — what each bar guarantees and how you verified it.

## Definition of done
- [ ] Monorepo with boundaries and enforced dependency direction
- [ ] Containerized services; hygienic, pinned, non-root images
- [ ] One-command dev environment (compose) with health-gated startup + persistent data
- [ ] Reproducible toolchain: pinned versions, committed lockfile, dev container matching CI
- [ ] Lean multi-stage production images (minimal, non-root, healthchecked, no secrets)
- [ ] Segmented network: edge exposed, database internal-only, blast radius limited
- [ ] CI/CD: ordered unskippable gates; deploy promotes the built image
- [ ] Production orchestration: replicas, probes, limits, injected config, zero-downtime rollouts
- [ ] Platform report + notebook + AI log complete and reproducible

## The standard
Build once, run anywhere; the artifact is immutable and configuration is injected; infrastructure as code; reproducible, not "works on my machine"; least privilege / minimal surface; automate the path to production; design for failure / operability; DX is a feature. A Dockerfile that lints clean, a compose graph that health-gates the database, a network where the db is unreachable from the edge, a pipeline whose gates actually gate, and a manifest with replicas/probes/limits/zero-downtime rollout are how "engineering platform" becomes true rather than asserted.
