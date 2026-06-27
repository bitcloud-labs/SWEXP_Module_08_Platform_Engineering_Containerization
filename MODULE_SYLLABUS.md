# Module Syllabus — Platform Engineering & Containerization

## Description
A ticket-driven module that turns *Project Forge* from "runs on the authors' laptops" into a reproducible **engineering platform**. Across 10 lessons and a capstone, you operate as a Platform Engineer closing tickets that move from reorganizing the code into a monorepo, through containerizing services and a one-command dev environment, making the toolchain reproducible, engineering lean production images, segmenting the network, automating an unskippable CI/CD pipeline, and operating a production container platform — culminating in shipping the platform. The emphasis is on **reproducibility, security, and operability**: build once and run anywhere, the artifact is immutable and configuration is injected, infrastructure is code, and the path to production is automated.

## Prerequisites
- The Forge apps from earlier modules (M05 web, M06 API, M07 data) as the thing being packaged.
- Comfort at a command line and solid Git (Modules 01–02).
- Basic TypeScript/Node (Module 04) — the apps and the validators run on Node.
- **Node.js** and **npm**; a YAML parser for the validators (`npm i js-yaml`). **No Docker or Kubernetes is required** — the artifacts are declarative and verified by parsing/linting.

## Pacing Options

| Track | Cadence | Duration |
|-------|---------|----------|
| Intensive (bootcamp) | ~1 lesson/day; capstone over the last 4–5 days | ~2–3 weeks |
| Part-time (cohort) | 2 lessons/week | ~6 weeks |
| Self-paced | 1 lesson per sitting; capstone when ready | flexible |

Most lessons are 3–4 hours including the lab; the capstone is 16–20 hours.

## Module Arc

| Phase | Lessons | Focus |
|-------|---------|-------|
| Foundations | 0 | the toolchain; build once, run anywhere |
| Repository & Local Dev | 1–3 | monorepo; containerize; one-command compose |
| Reproducibility | 4–5 | dev containers; production image engineering |
| Networking & Automation | 6–7 | container network segmentation; CI/CD |
| Production | 8 | production orchestration (replicas, probes, limits, rollouts) |
| Capstone | 9 | ship the full Forge engineering platform with evidence |

## Lesson Structure
Every lesson follows the same shape: **Engineering Ticket → Business Context → Learning Objectives → Technical Deep Dive → Hands-on Labs → Engineering Investigation → AI Engineering Exercise → Assignment → Stretch Goal → Definition of Done → Reflection.**

## Labs
Every lab carries the Forge platform forward and is **verified** by parsing and policy-checking the real artifacts: a Dockerfile **linter** (pinned base, multi-stage, non-root, healthcheck, layer order, `.dockerignore`), a real **YAML parser** (`js-yaml`) for compose/CI/Kubernetes (asserting the graph, the pipeline policy, the manifest properties), and **Node logic tests** (dependency boundaries, reproducibility, network reachability, gate order). There is **no container runtime** — the artifacts are declarative, so correctness is whether they declare the right thing; the same files run unchanged where Docker/Kubernetes exist.

## Deliverables
- **Per lesson:** a completed lab, an assignment via `assignments/submission-template.md`, and an engineering-notebook entry (what you built → evidence → fixes → AI log).
- **Capstone:** the working, validating infrastructure-as-code platform, an engineering-platform report proving each quality bar with evidence (enforced monorepo boundaries, image hygiene lint, a health-gated one-command dev environment, the reproducibility checks, the production-image lint, a segmented network proving the db is unreachable from the edge, the pipeline's ordered unskippable gates and built-image promotion, and the production manifests' replicas/probes/limits/zero-downtime rollout), and the notebook — per `assignments/capstone-brief.md`.

## Final Assessment
Graded against `ASSESSMENT_RUBRIC.md`: Repository Architecture (15%), Developer Experience (15%), Container Platform (15%), Build Automation (10%), Production Readiness (10%), Documentation (10%), Operational Quality (10%), Engineering Judgment (10%), AI Workflow (5%).

## Support Materials
- `resources/` — platform setup; monorepo; Dockerfile; Docker Compose; reproducibility; production images; container networking; CI/CD; Kubernetes production; Dockerfile-lint reference; infrastructure-as-code; AI-workflow; notebook template.
- `dashboard.html` — an interactive progress tracker.
- `solutions/` — worked solutions (lint findings, parsed structure, policy results reproducible) to check against.
- `instructor-notes/` — per-lesson facilitation guidance.

## Academic & Professional Integrity
AI assistance is **encouraged**, used as a professional would: every use follows **draft → verify (parse/lint the config, run the build/policy logic, check the property) → log.** The recurring failures to catch — `:latest`/single-stage images, root containers, baked secrets, published databases, flat networks, non-gating pipelines, rebuild-for-deploy, single replicas, missing probes/limits — are exactly what the linters and policy checks exist to surface. Unverified AI output in deliverables counts against you, and security/reproducibility shortcuts especially: a platform mistake ships to every environment.
