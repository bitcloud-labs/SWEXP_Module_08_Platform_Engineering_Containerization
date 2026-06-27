# AI Workflow Guide — Draft → Verify → Log

Platform work gives you concrete verifiers: **lint the Dockerfile**, **parse the YAML** and assert policy, and **run the logic** (boundaries, reachability, gate order). Use them — don't take the AI's word, especially on security and reproducibility.

## The loop
1. **Draft.** Ask the AI for a Dockerfile, compose file, pipeline, manifest, or monorepo layout.
2. **Verify.**
   - **Lint** Dockerfiles (pinned base, multi-stage, non-root, healthcheck, layer order, `.dockerignore`).
   - **Parse** compose/CI/k8s YAML and assert the structure/policy you intended.
   - **Run** the policy logic (dependency boundaries, reachability, ordered gates, reproducibility).
3. **Log.** Record what you asked, what each check said, what you kept, what you overruled.

## Where AI most often goes wrong here
- `:latest` / unpinned base images; single-stage production images.
- **Root** containers; **baked secrets**; config baked into the image.
- A **published database**; one flat network (no segmentation).
- Pipelines whose stages **don't gate**, or **rebuild** for deploy instead of promoting the tested image.
- **Single replica**, missing **probes** or **resource limits**; recreate (downtime) instead of rolling update.
- `npm install` instead of `npm ci`; uncommitted lockfile; unpinned toolchain.

## The golden rule
A Dockerfile you didn't lint isn't trusted; a manifest you didn't parse may not declare what you think; a pipeline you didn't policy-check may have a gate that doesn't gate. The linters, parsers, and policy checks are the arbiters — not confidence. **Build once, run anywhere** only holds if the artifact and its config are actually what you verified.
