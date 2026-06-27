# SWEXP Module 08 — Platform Engineering & Containerization (Interactive Workspace)

This is a **work-along starter workspace**, not a set of lessons to read. You learn by
shipping infrastructure-as-code: you author Dockerfiles, a `docker-compose.yml`, a CI
pipeline, and Kubernetes manifests, then an **autograder** checks each one against the
quality bar (lint clean, parses, policy-checks green).

> The conceptual lessons, deep-dive guides, and the engineering-notebook template live in
> the LMS and in [`resources/`](resources/). This repo is the hands-on half.

## How it works

Every exercise is a self-contained folder under [`labs/`](labs/) (and the capstone under
[`assignments/`](assignments/)). Each folder contains:

- A `README.md` — the ticket: goal, what to do, and the definition of done.
- A **starter artifact with `# TODO`s** — the file *you* edit. Depending on the lab this is a
  `Dockerfile`, a `docker-compose.yml`, a `ci.yml`, a `deployment.yml`, a `package.json`,
  and/or a `solution.sh`.
- `tests/*.bats` — the **spec**. These are the executable acceptance criteria. Read them.
- `fixtures/` — supporting files some labs need.

You finish a lab when its tests are green.

## Grading model (fast, deterministic, mostly Docker-free)

The autograder grades your **files**, not a live cluster:

- **Dockerfiles** are graded with static checks (pinned base, non-root `USER`,
  `HEALTHCHECK`, multi-stage, no baked secrets, a complete `.dockerignore`).
- **compose / CI / k8s YAML** is graded by **parsing** it with `python3` and asserting the
  required services, networks, gates, probes, limits, and image pinning.
- **shell scripts** (e.g. the monorepo boundary check) are run directly under `bats`.
- Exactly **one** lab does a real `docker build` (a tiny `alpine` image) to prove your
  Dockerfile actually builds. Everything else is build-free, so grading is fast and reliable.

## Quick start

```bash
npm install            # installs bats (the test runner)

# work one lab:
npx bats labs/lab-00-setup/tests
# or grade everything (what CI runs):
npm run grade
```

`npm run grade` prints a per-exercise scoreboard and writes `grade-report.md`. It exits
non-zero until **every** test passes and every shell script parses cleanly. Push your branch
and the **Autograde** GitHub Action runs the same grader and comments your score on the PR.

## The labs

| # | Folder | You author | Graded by |
|---|--------|-----------|-----------|
| 00 | `labs/lab-00-setup` | `config.yml` + a first `Dockerfile` | YAML parse + Dockerfile lint |
| 01 | `labs/lab-01-monorepo` | `solution.sh` (boundary check) | bats (runs your script) |
| 02 | `labs/lab-02-dockerfile` | `Dockerfile` + `.dockerignore` | static lint **+ one real `docker build`** |
| 03 | `labs/lab-03-compose` | `docker-compose.yml` | YAML parse (services, health-gate, volume) |
| 04 | `labs/lab-04-devcontainer` | `package.json` + `.devcontainer/devcontainer.json` | reproducibility checks |
| 05 | `labs/lab-05-prod-image` | multi-stage `Dockerfile` | production-image lint |
| 06 | `labs/lab-06-networking` | segmented `docker-compose.yml` | YAML reachability checks |
| 07 | `labs/lab-07-ci` | `ci.yml` (a GitHub Actions workflow) | pipeline policy parse |
| 08 | `labs/lab-08-production` | `deployment.yml` (Deployment + Service) | manifest policy parse |
| — | `assignments/capstone` | integrate all of the above | static + parse checks |

## Requirements

- **Node 20+** (for `bats` and the grader).
- **python3** (for YAML/JSON parsing in the graders) — preinstalled in the dev container.
- **Docker** — only `lab-02` does a real build; if Docker is unavailable that one build test
  will fail but every other test still runs. The CI runner (and the dev container) have Docker.

The fastest way in: open this repo in **GitHub Codespaces** (Code → Codespaces → Create) or
in VS Code Dev Containers — the [`.devcontainer`](.devcontainer/) gives you Node, python3,
Docker, and the `gh` CLI with zero setup.

## Submitting

Commit and push your branch. The autograder scores it automatically and comments on your PR.
Record your reasoning, trade-offs, and AI-usage log in the engineering notebook
(`resources/engineering-notebook-template.md`) and the submission templates under
[`assignments/`](assignments/).
