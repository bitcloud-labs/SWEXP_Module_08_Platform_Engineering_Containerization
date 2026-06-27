# SWEXP Module 08 — Platform Engineering & Containerization

**Theme:** Build Once. Run Anywhere — transform Project Forge into a reproducible engineering platform with a monorepo, containers, automated builds, and production-ready infrastructure.

You are a **Platform Engineer**. Forge is three apps built across earlier modules — a web frontend (M05), an API (M06), and a data layer (M07) — that currently run only on the original authors' laptops, set up by hand. Across 10 ticket-driven lessons you reorganize Forge into a monorepo, containerize its services, wire a one-command dev environment, make the toolchain reproducible, engineer lean production images, segment the container network, automate an unskippable CI/CD pipeline, stand up a production orchestration platform, and ship it.

The ethos, in every lesson: **build once, run anywhere**; **the artifact is immutable, configuration is injected**; **infrastructure as code**; **reproducible, not "works on my machine"**; **least privilege / minimal surface**; **automate the path to production**; **design for failure / operability**; and **developer experience is a feature**. AI is used as **draft → verify (parse/lint the config, run the build/policy logic, check the property) → log**.

## How You Work Here

| Step | What it means |
|------|---------------|
| Pick up a ticket | Each lesson is an engineering ticket (`DOCK-2001`, `CI-4010`, …) with acceptance criteria |
| Write infrastructure as code | Dockerfiles, compose, pipelines, manifests — declarative, versioned, reviewable |
| Validate the artifact | Lint Dockerfiles; parse and policy-check YAML; test the logic |
| Build once, inject config | One immutable image per service; configuration comes from the environment |
| Least privilege | Non-root images, minimal bases, no secrets baked in, the database off the edge |
| Automate the path | The CI/CD pipeline is the only way to ship; its gates are unskippable |
| Verify AI | Draft → verify (lint / parse / policy-check) → log |

## Learning Outcomes

By the end you will be able to:
- Organize a monorepo with shared packages and an enforced dependency direction.
- Containerize a service with a hygienic, pinned, non-root, cache-friendly Dockerfile.
- Stand up a one-command dev environment with Docker Compose (health-gated, persistent).
- Make the toolchain reproducible: pinned versions, committed lockfiles, dev containers.
- Engineer lean multi-stage production images (minimal, non-root, healthchecked, no secrets).
- Design a segmented container network where the database is unreachable from the edge.
- Automate an unskippable CI/CD pipeline that promotes the tested image.
- Operate a production container platform: replicas, probes, limits, zero-downtime rollouts.
- Ship a coherent engineering platform with evidence for each quality bar.

## Lesson Index

| # | Lesson | Competency | Ticket |
|---|--------|-----------|--------|
| 0 | Welcome to the Platform Engineering Team | Platform Engineering Orientation | PLAT-1000 |
| 1 | Reorganize Project Forge | Monorepo Architecture | REPO-1010 |
| 2 | Containerize the Platform | Docker Fundamentals | DOCK-2001 |
| 3 | Build a One-Command Development Environment | Docker Compose | COMPOSE-2010 |
| 4 | Eliminate "Works on My Machine" | Development Containers | DEVENV-3001 |
| 5 | Engineer Production Images | Image Engineering | IMG-3010 |
| 6 | Build the Container Network | Container Networking | NET-4001 |
| 7 | Automate the Build Platform | Build Automation | CI-4010 |
| 8 | Build the Production Container Platform | Production Containers | PROD-5001 |
| 9 | Project Forge Engineering Platform | Engineering Platform Release | FORGE-9600 |

Phases: **Foundations** (0) → **Repository & Local Dev** (1–3) → **Reproducibility** (4–5) → **Networking & Automation** (6–7) → **Production** (8) → **Capstone** (9).

## Repository Layout

```
.
├── README.md                      # this file
├── MODULE_SYLLABUS.md             # pacing, structure, deliverables
├── LEARNER_GUIDE.md               # how to operate as a platform engineer here
├── INSTRUCTOR_GUIDE.md            # facilitation and assessment
├── COMPETENCY_MATRIX.md           # lesson → competency → skills
├── ASSESSMENT_RUBRIC.md           # grading weights and performance levels
├── dashboard.html                 # interactive progress dashboard (open in a browser)
├── Lesson_00.md … Lesson_09.md    # the 10 lessons
├── labs/                          # hands-on labs (lint Dockerfiles; parse/policy-check YAML; test logic)
├── solutions/                     # worked solutions / answer keys
├── resources/                     # monorepo, Dockerfile, compose, reproducibility, images, networking, CI/CD, k8s + more
├── assignments/                   # submission templates + capstone brief
└── instructor-notes/              # per-lesson facilitation notes
```

## Getting Started

1. Read `resources/platform-setup-guide.md`; set up the toolchain (Lesson 0 / `labs/lab-00-setup.md`).
2. Start your engineering notebook from `resources/engineering-notebook-template.md`.
3. Open `dashboard.html` in your browser to track progress through the lessons and phases.
4. Open `Lesson_00.md` and pick up your first ticket. Keep the relevant `resources/` references open as you build.

**Verification.** The deliverables are infrastructure-as-code, so verification means **parsing and policy-checking the real artifacts**: a Dockerfile **linter** (pinned base, multi-stage, non-root, healthcheck, layer order, `.dockerignore`), a real **YAML parser** for compose/CI/Kubernetes (asserting the graph, the pipeline policy, the manifest properties), and **Node logic tests** (dependency boundaries, reproducibility, network reachability, gate order). There is **no container runtime** here — the artifacts are declarative, and the same files run unchanged where Docker/Kubernetes exist.
