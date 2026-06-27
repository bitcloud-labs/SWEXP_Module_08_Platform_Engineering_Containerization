# Lesson 02 — Containerize the Platform

> **Role:** Platform Engineer · **Competency:** Docker Fundamentals · **Track:** DOCK · **Est. time:** 4 hours

---

## 🎫 Engineering Ticket

```
TICKET:      DOCK-2001
TITLE:       The API only runs after a page of manual setup; containerize it
PRIORITY:    P1
TYPE:        Feature
DESCRIPTION: Running the Forge API requires installing the right Node version,
             system libraries, and environment by hand — different on every
             machine. Containerize it: write a Dockerfile that packages the API and
             its runtime into one immutable image that builds reproducibly and runs
             the same everywhere. Follow image hygiene: pinned base, good layer
             order, a build context that excludes junk, and a non-root runtime.

ACCEPTANCE CRITERIA:
  - A Dockerfile builds the API into a single runnable image
  - Base image is pinned (no :latest); instructions are ordered for layer caching
  - A .dockerignore excludes node_modules, secrets, and build junk from the context
  - The container runs as a non-root user; configuration comes from the environment
```

## 🏢 Business Context

A container turns "install these twelve things in this order" into "run this image." It's the unit of reproducibility: the same image runs on a laptop, in CI, and in production, so the environment stops being a variable. But a careless image is slow to build, huge, insecure, or leaks secrets — so containerization is a craft with real best practices. Getting the Dockerfile right is the foundation everything else in this module stands on.

## 🎯 Learning Objectives

- Write a Dockerfile that packages a service into a reproducible image
- Pin the base image and order instructions for layer caching
- Use a `.dockerignore` to keep the build context clean
- Run as a non-root user and take configuration from the environment

## 📚 Technical Deep Dive

**Images, layers, and the build cache.** A Dockerfile is a sequence of instructions; each creates a **layer**. Docker caches layers and only rebuilds from the first changed instruction onward — so *order matters*. Copy and install dependencies *before* copying source, so a code change doesn't bust the dependency-install cache:

```dockerfile
FROM node:22.13-bookworm-slim          # pinned base — reproducible, not :latest
WORKDIR /app
COPY package*.json ./                   # deps layer: changes rarely
RUN npm ci                              # cached unless package*.json changes
COPY . .                                # source layer: changes often
RUN npm run build
USER node                               # drop root for the runtime
CMD ["node", "dist/server.js"]
```
If `COPY . .` came before `npm ci`, every code edit would reinstall all dependencies — slow builds.

**Pin the base image.** `node:latest` is a moving target — today's build and tomorrow's differ. Pin a specific tag (`node:22.13-bookworm-slim`) so the build is reproducible. Prefer slim/minimal bases to shrink size and attack surface.

**`.dockerignore` keeps the context clean.** The build context is everything sent to the builder. Without a `.dockerignore`, you ship `node_modules`, `.git`, `.env` files, and logs into the build — slow, bloated, and a secret-leak risk:

```
node_modules
.git
.env
*.log
dist
```

**Run as non-root.** By default a container runs as root; a compromise then has root in the container. Create/҂use a non-root user (`USER node`) so the runtime has least privilege.

**Configuration from the environment.** Don't bake environment-specific config or secrets into the image (it's the *same image* everywhere). Read config from environment variables at runtime; pass secrets in at run time, never `COPY` them in. This is the 12-factor "config in the environment" rule, and it's what keeps one image promotable across environments.

### Common gotchas
- `FROM node:latest` (non-reproducible builds).
- `COPY . .` before installing dependencies (busts the cache on every code change).
- No `.dockerignore` (bloated context; leaked `.env`/`.git`).
- Running as root; baking secrets or env-specific config into the image.

## 🧪 Hands-on Labs

Work through **`labs/lab-02-dockerfile.md`**. You'll write a Dockerfile for the Forge API and run it through a **Dockerfile linter** that checks the best practices: a pinned (non-`latest`) base, dependency layers before source (cache-friendly order), a non-root `USER`, and a `.dockerignore` excluding `node_modules`/`.env`/`.git`. A deliberately-bad Dockerfile fails the lint with specific findings; your corrected one passes.

## 🔍 Engineering Investigation

Lint a "naive" Dockerfile (latest base, `COPY . .` first, root, no `.dockerignore`) and record every finding. Fix each and re-lint to a clean pass. In your notebook, explain for one finding what concretely goes wrong in production if it ships (e.g. a leaked `.env`, a non-reproducible build, a root compromise).

## 🤖 AI Engineering Exercise

Ask an AI to "containerize this API." **Verify** the Dockerfile pins its base, orders layers for caching, runs non-root, ships a `.dockerignore`, and takes config from the environment (no baked secrets). **Log** each best practice the AI missed and your fix — these are exactly the lint findings.

## 📝 Assignment

Submit the API Dockerfile + `.dockerignore`, the before/after lint results (naive → clean), and a note on what each fixed finding prevents in production.

## 🚀 Stretch Goal

Measure (or reason precisely about) the image-size and build-time difference between the naive and improved Dockerfile, and attribute the difference to specific instructions (base image choice, layer order, `.dockerignore`).

## ✅ Definition of Done

- [ ] A Dockerfile builds the API into one runnable image
- [ ] Base pinned; instructions ordered for layer caching
- [ ] `.dockerignore` excludes node_modules, secrets, build junk
- [ ] Runs non-root; config from the environment (no baked secrets)
- [ ] Lint passes clean (naive version's findings all addressed)

## 🪞 Reflection

Which best practice would you have skipped under time pressure, and what would it have cost later? Why is layer *order* a performance decision, not a cosmetic one?
