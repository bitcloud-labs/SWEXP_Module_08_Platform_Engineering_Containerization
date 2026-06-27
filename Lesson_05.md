# Lesson 05 — Engineer Production Images

> **Role:** Platform Engineer · **Competency:** Image Engineering · **Track:** IMG · **Est. time:** 4 hours

---

## 🎫 Engineering Ticket

```
TICKET:      IMG-3010
TITLE:       The API image is 1.2 GB, runs as root, and ships the whole toolchain
PRIORITY:    P1 — security & cost
TYPE:        Optimization / Security
DESCRIPTION: The current image bundles the full build toolchain, dev dependencies,
             and source into a fat, root-running image — slow to ship, expensive to
             store, and a large attack surface. Engineer a production image: a
             multi-stage build that compiles in one stage and ships only the runtime
             artifact in a minimal, non-root final image with a healthcheck and no
             secrets or build tooling.

ACCEPTANCE CRITERIA:
  - Multi-stage build: build tooling stays in the build stage, not the final image
  - Final image is minimal (slim/distroless), non-root, with only the runtime artifact
  - A HEALTHCHECK is defined; no secrets or dev dependencies in the final image
  - The image is meaningfully smaller and has a smaller attack surface than the naive one
```

## 🏢 Business Context

A production image is shipped thousands of times — pulled to every node, on every deploy, every scale-up. A fat image is slow to deploy, expensive to store and transfer, and dangerous: every compiler, dev dependency, and shell it carries is attack surface. Engineering a lean, minimal, non-root image is where containerization pays off in production — faster rollouts, lower cost, smaller blast radius. This is "least privilege / minimal surface" applied to the artifact itself.

## 🎯 Learning Objectives

- Use a multi-stage build to keep build tooling out of the final image
- Ship a minimal (slim/distroless), non-root final image with only the runtime artifact
- Add a healthcheck; exclude secrets and dev dependencies
- Reason about image size and attack surface as production concerns

## 📚 Technical Deep Dive

**Multi-stage builds separate building from running.** Build in a stage that has the toolchain; copy *only the artifact* into a clean, minimal final stage. The compilers and dev dependencies never reach production:

```dockerfile
# --- build stage: has the full toolchain ---
FROM node:22.13-bookworm-slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci                              # all deps, incl. dev
COPY . .
RUN npm run build                       # produce dist/

# --- runtime stage: minimal, only what runs ---
FROM node:22.13-bookworm-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production
COPY package*.json ./
RUN npm ci --omit=dev                    # production deps only
COPY --from=build /app/dist ./dist       # copy ONLY the build artifact
USER node                                # non-root runtime
HEALTHCHECK --interval=30s CMD node healthcheck.js
CMD ["node", "dist/server.js"]
```

**Minimal base = smaller and safer.** A `-slim` base drops hundreds of MB of OS packages; a **distroless** base goes further — no shell, no package manager, just the runtime — shrinking both size and attack surface (no shell for an attacker to use). The trade-off: harder to `exec` in and debug, so choose per service.

**Only the artifact ships.** The final image contains the runtime, production dependencies, and the built output — not the source, not dev dependencies, not the build cache. Smaller image, fewer things that can have a CVE.

**Non-root, healthcheck, no secrets.** Same disciplines as Lesson 2, now non-negotiable for production: a non-root `USER`, a `HEALTHCHECK` so the orchestrator (Lesson 8) knows the container's health, and absolutely no secrets baked in (they belong in the environment / a secret store at runtime).

**Size and surface are measurable.** Image size (pull time, storage, deploy speed) and the count of packages/CVEs are real production metrics. Multi-stage + minimal base typically turns a >1 GB image into tens-to-low-hundreds of MB — a measurable win you should be able to attribute to specific choices.

### Common gotchas
- Single-stage build that ships the compiler and dev dependencies to production.
- A fat base (`node` instead of `-slim`/distroless) with hundreds of unused packages.
- Copying the whole tree (`COPY . .`) into the final image instead of just the artifact.
- Running as root in production; baking secrets in; no healthcheck.

## 🧪 Hands-on Labs

Work through **`labs/lab-05-prod-image.md`**. You'll engineer a multi-stage production Dockerfile for the Forge API and run it through the production-image linter: it must be **multi-stage** (≥2 `FROM`s), use a **minimal** base, run **non-root**, define a **HEALTHCHECK**, install **production-only** deps in the runtime stage, copy **only the artifact** (no `COPY . .` in the final stage), and bake **no secrets**. The naive single-stage/root image fails with specific findings; your engineered one passes.

## 🔍 Engineering Investigation

Lint the naive image (single-stage, fat base, root, dev deps) and record every finding. Engineer the multi-stage version and re-lint to a clean pass. Reason about (or measure) the size reduction and attribute it: how much from multi-stage (no toolchain), how much from the minimal base, how much from `--omit=dev`. Note the attack-surface reduction from dropping the shell (distroless).

## 🤖 AI Engineering Exercise

Ask an AI to "optimize this Dockerfile for production." **Verify** it goes multi-stage (build tooling out of the final image), uses a minimal non-root base, copies only the artifact, adds a healthcheck, and keeps secrets out. **Log** where it left a single stage, a fat base, or root and your fix.

## 📝 Assignment

Submit the multi-stage production Dockerfile, the before/after lint (naive → clean), an analysis of the size/attack-surface reduction attributed to specific choices, and confirmation of non-root + healthcheck + no secrets.

## 🚀 Stretch Goal

Convert the final stage to a **distroless** base, get the image building without a shell, and explain both the security gain and what you lose for debugging (and how you'd debug it anyway).

## ✅ Definition of Done

- [ ] Multi-stage build; build tooling stays out of the final image
- [ ] Minimal, non-root final image with only the runtime artifact
- [ ] HEALTHCHECK defined; production-only dependencies
- [ ] No secrets or dev dependencies in the final image
- [ ] Production-image lint passes; size/surface reduction attributed

## 🪞 Reflection

Which single change shrank the image most, and why? Why is a smaller image a *security* win and not only a speed/cost one?
