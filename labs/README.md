# Labs — Platform Engineering & Containerization

Hands-on labs for each lesson. You turn Forge into a reproducible platform, carried forward lesson to lesson. Because the deliverables are **infrastructure-as-code** (Dockerfiles, compose/CI/Kubernetes YAML), verification is done by **parsing and policy-checking the real artifacts**, not by hand-waving:

- **Parse the real config.** Compose, CI, and Kubernetes YAML are parsed with a real YAML parser (`js-yaml`) and asserted against the structure/policy you intended — a Deployment really has replicas+limits+probes, a compose graph really health-gates the database, a pipeline really orders its gates.
- **Lint the Dockerfiles.** A Dockerfile linter parses the instructions and checks best practices — pinned (non-`latest`) base, multi-stage, non-root `USER`, `HEALTHCHECK`, cache-friendly layer order, `.dockerignore` hygiene, no baked secrets. A deliberately-bad file fails with specific findings; the good one passes.
- **Test the policy logic in Node.** Dependency-boundary rules, reproducibility checks, network reachability, and pipeline-gate logic are pure functions asserted with `node`.

There is **no container runtime** here (no `docker`/`kubectl`), and that's fine: the point of these lessons is the *declarative artifact* and whether it declares what you intended. The same files run unchanged on a machine with Docker/Kubernetes.

## How to use a lab
1. Read the matching `Lesson_NN.md` first.
2. Run the **Setup** (a generator writes the artifacts under `/tmp/forge-platform`).
3. Work the **Tasks**, parsing/linting the artifacts as you go.
4. Produce the **Deliverable** for your engineering notebook (include the lint output, the parse/policy results, the before/after).
5. Check your reasoning against `solutions/lab-NN-solution.md`.

## Ground rules
- **Build once, run anywhere.** One immutable image per service; configuration injected, never baked.
- **Infrastructure as code.** Everything is versioned, reviewable text — validate it like you'd type-check code.
- **Reproducible, not "works on my machine."** Pin versions, commit lockfiles, deterministic installs.
- **Least privilege / minimal surface.** Non-root, minimal bases, no secrets in images, expose the minimum.
- **Evidence, not assertion.** Paste the real lint findings, the parsed structure, the policy-check results.

## Prerequisites
- **Node.js** and **npm**. A YAML parser for the validators: `npm i js-yaml` (used in CommonJS: `const yaml = require('js-yaml')`).
- The validators are plain Node scripts — no Docker or Kubernetes required.

## Lab index
| # | Lab | Focus |
|---|-----|-------|
| 0 | `lab-00-setup.md` | toolchain; validate a config + lint a Dockerfile |
| 1 | `lab-01-monorepo.md` | monorepo layout + dependency-boundary check |
| 2 | `lab-02-dockerfile.md` | Dockerfile + `.dockerignore` hygiene lint |
| 3 | `lab-03-compose.md` | one-command dev env; health-gated compose graph |
| 4 | `lab-04-devcontainer.md` | pinned toolchain + lockfile + dev container (reproducibility) |
| 5 | `lab-05-prod-image.md` | multi-stage minimal non-root production image |
| 6 | `lab-06-networking.md` | segmented network; internal-only database |
| 7 | `lab-07-ci.md` | CI/CD pipeline with ordered, unskippable gates |
| 8 | `lab-08-production.md` | production manifests: replicas, probes, limits, rollout |

The Lesson 09 capstone reuses these to ship the full Forge engineering platform.
