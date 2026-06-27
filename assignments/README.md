# Assignments — Platform Engineering & Containerization

Each lesson has an assignment described in its `Lesson_NN.md`. Submit every one using `submission-template.md`, and back every claim with evidence — lint output, parsed structure, and policy-check results.

| File | Purpose |
|------|---------|
| `submission-template.md` | per-lesson submission format |
| `capstone-brief.md` | the full FORGE-9600 engineering-platform specification |
| `capstone-submission-template.md` | the capstone platform-report format |

## What every submission must include
- **What you built** and *why this design* — what's pinned, multi-stage, health-gated, segmented; what gates the pipeline; what's injected vs baked.
- **Evidence:** the Dockerfile lint (naive → clean), the parsed YAML structure/policy, the logic-check results (boundaries, reachability, gate order, reproducibility).
- **The fix at the cause** — a pinned base, a multi-stage split, a health gate, a network tier, a deploy gate, injected secrets.
- **AI-usage log:** draft → verify (parse/lint the config, run the policy logic) → log.
- **Clean commits** (your Module 02 Git skills apply).

## Grading
Against `../ASSESSMENT_RUBRIC.md`. The recurring standard: **build once, run anywhere; the artifact is immutable, configuration is injected; infrastructure as code; reproducible, not "works on my machine"; least privilege / minimal surface; automate the path to production; design for failure / operability; DX is a feature.**
