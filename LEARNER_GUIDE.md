# Learner Guide — Platform Engineering & Containerization

## You are a platform engineer
Every lesson is an **engineering ticket** turning *Project Forge* into a reproducible platform. Approach each as real work: write the infrastructure-as-code, validate it, and document your reasoning. The goal isn't memorizing Docker flags — it's the reproducibility, security, and operability judgment to own a platform other engineers build on and that ships safely without heroics.

## The ideas that matter most
- **Build once, run anywhere.** One immutable image per service runs identically everywhere; configuration is injected, never baked.
- **Infrastructure as code.** Dockerfiles, compose, pipelines, manifests are declarative, versioned, reviewable text — validate them like code.
- **Reproducible, not "works on my machine."** Pin versions, commit lockfiles, deterministic installs, dev containers.
- **Least privilege / minimal surface.** Non-root, minimal bases, no secrets in images, expose the minimum, segment the network.
- **Automate the path to production.** CI/CD is the only way to ship; the gates are unskippable; promote the tested image.
- **Design for failure / operability.** Health probes, resource limits, zero-downtime rollouts (Modules 03/06 carry).
- **Developer experience is a feature.** One command to run the whole platform locally.

## How each lesson works
1. **Read the ticket and the deep dive.**
2. **Do the lab.** Write the artifact, **predict** the lint findings / policy result, then verify by parsing/linting.
3. **Investigate** — push from "it parses" to "I can show the naive version failing and mine passing, and explain what each check prevents."
4. **Run the AI exercise** — draft → verify → log, deliberately.
5. **Submit the assignment** and **update your notebook.**
6. **Check the solution** to validate your reasoning — after you've done the work.

Track progress in `dashboard.html`.

## What every assignment must include
- **What you built** and *why this design* — what's pinned, multi-stage, health-gated, segmented; what gates the pipeline; what's injected vs baked.
- **Evidence:** the Dockerfile lint (naive → clean), the parsed YAML structure/policy, the logic-check results (boundaries, reachability, gate order, reproducibility).
- **The fix at the cause** — a pinned base, a multi-stage split, a health gate, a network tier, a deploy gate, injected secrets.
- **AI-usage log:** draft → verify → log.
- **Clean commits** (Module 02 habits).

## Using AI responsibly
AI drafts infra fast and confidently, and is often wrong in ways that are *expensive* on a platform — `:latest`, root containers, baked secrets, a published database, a pipeline whose gates don't gate. You have concrete verifiers: lint the Dockerfile, parse the YAML, run the policy logic. `resources/ai-workflow-guide.md` maps the failure modes.

## The standard
A Dockerfile you didn't lint isn't trusted; a manifest you didn't parse may not declare what you think; a pipeline you didn't policy-check may have a gate that doesn't gate. The linters, parsers, and policy checks are the arbiters — not confidence. Build once, run anywhere only holds if the artifact and its config are actually what you verified.

## How you're graded
Against `ASSESSMENT_RUBRIC.md` — on repository architecture, developer experience, the container platform, build automation, production readiness, operability, and judgment, with evidence. An image that "runs" but is root, `:latest`, and ships the toolchain, or a manifest with one replica and no limits, scores poorly regardless of the happy path.
