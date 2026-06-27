# Lesson NN Submission — [Your Name]

**Ticket:** [e.g. DOCK-2001] · **Date:** [date] · **Lesson:** [title]

## 1. Goal / Definition of Done
What the ticket asked; the acceptance criteria you met.

## 2. What I built
The Dockerfile / compose file / pipeline / manifests / monorepo layout, and *why this design*. Note key decisions: what's pinned, multi-stage, health-gated, segmented; what gates the pipeline; what's injected vs baked.

```dockerfile
# or yaml — the key artifact
```

## 3. Evidence
- **Dockerfile lint:** naive findings → clean pass on yours.
- **YAML parse + policy:** the asserted structure (compose graph / pipeline order / manifest properties).
- **Logic checks:** dependency boundaries / reachability / gate order / reproducibility.
- **Before/after:** the naive artifact's failures → your corrected clean pass.

## 4. Fix at the cause
What you changed and why it addresses the cause (pinned base, multi-stage split, health gate, network tier, deploy gate, injected secrets) — not a workaround.

## 5. AI-usage log
| Asked | AI suggested | Verified (lint/parse/policy) | Outcome |
|-------|-------------|------------------------------|---------|
| | | | accepted / corrected because… |

## 6. Reflection
What this taught you; where a reproducibility/security/operability bar caught something; what you'd design differently.

---
**Checklist:** [ ] immutable artifact / injected config · [ ] infrastructure as code · [ ] reproducible · [ ] least privilege / minimal surface · [ ] automated path to production · [ ] designed for failure · [ ] AI output verified · [ ] commits clean
