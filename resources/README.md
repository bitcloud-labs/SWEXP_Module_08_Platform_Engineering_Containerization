# Resources — Platform Engineering & Containerization

Working references to keep open while you build the Forge platform. Quick-reference cheatsheets and playbooks, not reading assignments.

| Resource | Use it for |
|----------|-----------|
| `platform-setup-guide.md` | the toolchain + the parse/lint verify loop |
| `monorepo-guide.md` | workspaces, package boundaries, dependency direction |
| `dockerfile-guide.md` | layers, cache, pinning, non-root, .dockerignore |
| `docker-compose-guide.md` | name discovery, health-gated depends_on, volumes, ports |
| `reproducibility-guide.md` | pin versions, lockfiles, npm ci, dev containers |
| `production-image-guide.md` | multi-stage, minimal/distroless, size & surface |
| `container-networking-guide.md` | tiers, published-vs-internal, internal:true, least privilege |
| `cicd-guide.md` | ordered unskippable gates, scan, promote-not-rebuild |
| `kubernetes-production-guide.md` | replicas, probes, requests/limits, rolling updates |
| `dockerfile-lint-reference.md` | the best-practice checks, as a checklist |
| `infrastructure-as-code-guide.md` | declarative, versioned, reviewable infra |
| `ai-workflow-guide.md` | draft → verify (parse/lint/policy-check) → log |
| `engineering-notebook-template.md` | the notebook structure you submit |

**Threads through all of them:** build once, run anywhere; the artifact is immutable, configuration is injected; infrastructure as code; reproducible, not "works on my machine"; least privilege / minimal surface; automate the path to production; design for failure / operability; developer experience is a feature.
