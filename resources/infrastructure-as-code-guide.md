# Infrastructure as Code Guide

## The principle
Infrastructure is **declarative, versioned, reviewable text** — not buttons clicked in a console. Dockerfiles, compose files, CI pipelines, and Kubernetes manifests live in the repo, change via pull request, and are applied by automation.

## Why
- **Reviewable:** an infra change is a diff a teammate can read and approve.
- **Reproducible:** the same files produce the same environment — no undocumented console state.
- **Auditable / revertible:** Git history shows who changed what, when, and lets you roll back.
- **Testable:** you can parse/lint/policy-check the artifacts (this whole module) before they ship.

## Declarative, not imperative
You declare the *desired state* ("3 replicas, these limits, this image") and let the tool converge reality to it — instead of scripting the steps to get there. The manifest is the source of truth.

## Validate it like code
- Lint Dockerfiles (pinned base, multi-stage, non-root, healthcheck).
- Parse compose/CI/k8s YAML and assert structure + policy.
- Test pure policy logic (boundaries, reachability, gate order) in Node.

## Config vs artifact
The image is the immutable artifact (build once); configuration is injected per environment. IaC versions both — the manifests and the config references — without baking secrets in.

## Gotchas
- "Just SSH in and fix it" — undocumented drift that no one can reproduce or review.
- Hand-clicked console changes; secrets committed in plaintext manifests.
- Infra changes that skip review because they're "just config."
