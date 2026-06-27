# Lesson 09 — Project Forge Engineering Platform

> **Role:** Platform Engineer · **Competency:** Engineering Platform Release · **Track:** CAP · **Est. time:** 16–20 hours

---

## 🎫 Engineering Ticket

```
EPIC:        FORGE-9600
TITLE:       Ship the Project Forge engineering platform
PRIORITY:    P1 — module capstone
TYPE:        Epic (integrative)
DESCRIPTION: You own turning Forge into a reproducible engineering platform.
             Integrate everything: a monorepo with shared packages, containerized
             services, a one-command dev environment, a reproducible toolchain, lean
             production images, a segmented container network, an automated CI/CD
             pipeline, and a production orchestration setup with health, limits, and
             zero-downtime rollouts. Ship a coherent platform and a report that
             proves each quality bar with evidence.

ACCEPTANCE CRITERIA: (full mapping in assignments/capstone-brief.md)
  - Monorepo: clear apps/packages boundaries, shared packages, enforced dependency direction
  - Containerized services with hygienic, pinned, non-root images
  - One-command dev environment (compose) with health-gated startup and persistent data
  - Reproducible toolchain: pinned versions, committed lockfile, dev container matching CI
  - Lean multi-stage production images (minimal, non-root, healthchecked, no secrets)
  - Segmented network: edge exposed, database internal-only, blast radius limited
  - CI/CD: ordered unskippable gates (install→lint→test→build→scan→push), deploy promotes the built image
  - Production orchestration: replicas, probes, resource limits, injected config, zero-downtime rollouts
  - An engineering-platform report proves each bar with reproducible evidence
```

## 🏢 Business Context

This is the job: take Forge from "runs on the authors' laptops" to a platform a team can develop, build, ship, and operate reproducibly. Shipping a platform is an exercise in integration and judgment — the monorepo, the images, the network, the pipeline, and the orchestration all interact, and reproducibility, security, and operability can't be bolted on at the end. Any one piece is straightforward; composing them into a platform other engineers build on, and that ships safely without heroics, is the skill.

## 🎯 Learning Objectives

Integrate every module competency into a shippable platform: a monorepo with shared packages; containerized services; a one-command dev environment; a reproducible toolchain; lean production images; a segmented network; an automated CI/CD pipeline; and production orchestration with health, limits, and zero-downtime rollouts — all as versioned infrastructure-as-code with evidence.

## 📚 Technical Deep Dive

No new concepts — the capstone tests **integration, reproducibility, and judgment.** The full specification, the platform scope, the recommended build order, and the acceptance-criteria → rubric mapping live in **`assignments/capstone-brief.md`**; read it first and trace each criterion to the evidence you'll produce.

A sound build order (detailed in the brief):

1. **Repository** — the monorepo with apps/packages boundaries and enforced dependency direction (Lesson 1).
2. **Containers + dev environment** — Dockerfiles and a one-command compose stack (Lessons 2, 3).
3. **Reproducibility** — pinned toolchain, committed lockfile, dev container matching CI (Lesson 4).
4. **Production images** — lean multi-stage, minimal, non-root, healthchecked (Lesson 5).
5. **Network** — segmented tiers, edge-only exposure, internal-only database (Lesson 6).
6. **CI/CD + production** — the unskippable pipeline and the orchestrated production setup; assemble the report (Lessons 7, 8).

Keep every artifact validating (lint/parse/policy-check green) throughout; build in small, verified increments.

## 🧪 Hands-on Labs

The capstone *is* the lab. The Dockerfiles, compose files, network topology, pipeline, and manifests reuse the earlier lab generators and validators, so you ship real, checkable infrastructure-as-code rather than prose, and the evidence (lints, parses, policy checks) is reproducible.

## 🔍 Engineering Investigation

Investigation is the deliverable. The engineering-platform report must show, with evidence: the monorepo's enforced dependency boundaries; the container images passing the hygiene lint; the one-command dev environment with health-gated startup; the reproducibility checks (pinned + lockfile + dev container); the production images passing the production lint (multi-stage, minimal, non-root, healthcheck, no secrets); the segmented network proving the database is unreachable from the edge; the CI/CD pipeline's ordered unskippable gates and built-image promotion; and the production manifests' replicas, probes, limits, and zero-downtime rollout. End with a "reproducibility, security & operability" summary: what each bar guarantees and how you verified it.

## 🤖 AI Engineering Exercise

Use AI throughout as a professional would — to draft a Dockerfile, a compose file, a pipeline, a manifest — **but every use follows draft → verify (parse/lint the config, run the build/policy logic, check the property) → log.** Maintain an AI-usage log. The recurring failures to catch: `:latest` and single-stage images, root containers, baked secrets, published databases, flat networks, non-gating pipelines, deploys that rebuild instead of promote, single replicas, and missing probes/limits. The linters, the parsers, and the policy checks are the arbiters.

## 📝 Assignment

Ship the Forge engineering platform per `assignments/capstone-brief.md`, using `assignments/capstone-submission-template.md`. Your submission is the working, validating infrastructure-as-code plus an **engineering-platform report** proving each quality bar with evidence, and the engineering notebook (including the AI-usage log).

## 🚀 Stretch Goal

Go beyond the brief in one production-grade way a real team would value — e.g. autoscaling (HPA), image signing/provenance in the pipeline, a staged rollout with smoke tests and automatic rollback, secret management with a real secret store, or observability (metrics/dashboards) wired into the platform — and justify it with evidence.

## ✅ Definition of Done

- [ ] Monorepo with apps/packages boundaries and enforced dependency direction
- [ ] Containerized services; hygienic, pinned, non-root images
- [ ] One-command dev environment (compose) with health-gated startup + persistent data
- [ ] Reproducible toolchain: pinned versions, committed lockfile, dev container matching CI
- [ ] Lean multi-stage production images (minimal, non-root, healthchecked, no secrets)
- [ ] Segmented network: edge exposed, database internal-only, blast radius limited
- [ ] CI/CD: ordered unskippable gates; deploy promotes the built image
- [ ] Production orchestration: replicas, probes, limits, injected config, zero-downtime rollouts
- [ ] Engineering-platform report + notebook + AI log complete and reproducible

## 🪞 Reflection

Which integration decision had the widest blast radius across the platform? Where did a reproducibility, security, or operability bar force a change you'd have skipped under time pressure — and why was building it in cheaper than the outage or the "works on my machine" hunt it prevents?
