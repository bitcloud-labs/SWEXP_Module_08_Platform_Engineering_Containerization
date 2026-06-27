# Engineering Notebook — Template

Your professional record. One entry per lesson/lab. Evidence is lint output, parsed structure, and policy-check results.

---

## [Date] — Lesson NN: [Title] (TICKET-ID)

### Ticket / goal
What was asked; the acceptance criteria / Definition of Done.

### What I built
The Dockerfile / compose file / pipeline / manifests / monorepo layout, and the key decisions — what's pinned, what's multi-stage, what's health-gated, what's segmented, what gates the pipeline, what's injected vs baked. *Why* this design.

### Evidence
- **Dockerfile lint:** the findings on the naive version → clean pass on yours.
- **YAML parse + policy:** the asserted structure (compose graph, pipeline order, manifest properties).
- **Logic checks:** dependency boundaries / reachability / gate order / reproducibility results.
- **Before/after:** naive artifact's failures → corrected artifact's clean pass.

### Fixes
What I changed and why it addresses the cause (a pinned base, a multi-stage split, a health gate, a network tier, a deploy gate, injected secrets) — not a workaround.

### AI usage log
- Asked: …
- AI suggested: …
- Verified: linted / parsed / policy-checked → …
- Outcome: accepted / corrected because …

### Reflection
What this taught me; where a reproducibility/security/operability bar caught something; what I'd design differently.

---

**Standards:** build once, run anywhere; the artifact is immutable, configuration is injected; infrastructure as code; reproducible, not "works on my machine"; least privilege / minimal surface; automate the path to production; design for failure / operability; DX is a feature; **draft → verify → log** for AI.
