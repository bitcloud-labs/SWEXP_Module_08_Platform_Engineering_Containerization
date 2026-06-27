# Capstone — FORGE-9600: Ship the Project Forge Engineering Platform

> **Epic:** FORGE-9600 · **Role:** Platform Engineer (owner) · **Submission:**
> `../capstone-submission-template.md`

## The situation

*Project Forge* — a web frontend, an API, and a data layer — runs only on the original
authors' laptops, set up by hand. You own turning it into a reproducible **engineering
platform**: one repo, containerized services, a segmented network, automated CI/CD, and a
production orchestration setup. The capstone introduces **no new concepts** — it tests
**integration, reproducibility, and judgment** by making every bar from Labs 01–08 hold at
once, in one place.

You assemble the platform under [`platform/`](platform/) and prove each bar with the same
kinds of checks the labs used. The autograder grades your files — it never starts a cluster.

## What you build (in `platform/`)

1. **Monorepo boundaries** — [`platform/forge.deps`](platform/forge.deps): the dependency
   edge list (`consumer -> dependency`). Must respect apps→packages, **no** package→app, **no**
   cycles. (Lab 01)
2. **Production image** — [`platform/Dockerfile`](platform/Dockerfile): multi-stage, pinned,
   non-root, healthchecked, production-only deps, no baked secrets. (Labs 02 & 05)
3. **Segmented dev/runtime topology** —
   [`platform/docker-compose.yml`](platform/docker-compose.yml): web + api + db, the db
   internal-only (publishes nothing, not reachable from `web`), the edge published. (Labs 03 & 06)
4. **CI/CD** — [`platform/.github/workflows/ci.yml`](platform/.github/workflows/ci.yml):
   ordered unskippable gates (npm ci → lint → test → docker build → trivy → docker push),
   `deploy` gated on `build`, promotes the SHA-tagged image, never `:latest`. (Lab 07)
5. **Production orchestration** — [`platform/k8s/deployment.yml`](platform/k8s/deployment.yml):
   Deployment + Service; replicas ≥ 2, zero-downtime rolling update, requests+limits, both
   probes, pinned image, secrets by reference. (Lab 08)

## The integration script

Complete [`solution.sh`](solution.sh): it runs the **monorepo boundary check** against
`platform/forge.deps` and prints every violation (a clean platform prints nothing and exits
0). This is the same skill as Lab 01, now wired against your capstone repo — it's the one
gate that's a real script, so the shell-syntax gate covers your platform too.

## How it's graded

```bash
npx bats assignments/capstone/tests
# or grade the whole module: npm run grade
```

Static checks on the Dockerfile; `python3` parses the compose, CI, and k8s YAML; your
`solution.sh` runs the boundary check. Every bar must hold simultaneously.

## Deliverables

1. The working platform under `platform/` (all checks green).
2. An engineering-platform report proving each bar with evidence (see
   `../capstone-submission-template.md`).
3. The engineering notebook + the AI-usage log.
4. A "reproducibility, security & operability" summary — what each bar guarantees and how you
   verified it.
