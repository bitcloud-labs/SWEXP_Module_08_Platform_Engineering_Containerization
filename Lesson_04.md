# Lesson 04 — Eliminate "Works on My Machine"

> **Role:** Platform Engineer · **Competency:** Development Containers · **Track:** DEVENV · **Est. time:** 3–4 hours

---

## 🎫 Engineering Ticket

```
TICKET:      DEVENV-3001
TITLE:       A bug reproduces for one engineer and not another — environments differ
PRIORITY:    P1
TYPE:        Reliability / Developer Experience
DESCRIPTION: Even with Compose, engineers have different host toolchains — Node
             versions, global packages, OS libraries — so builds and bugs differ by
             machine. Make the development environment itself reproducible: pin
             versions and lockfiles, define a development container so everyone codes
             in an identical environment, and ensure a clean checkout builds the same
             way for everyone and in CI.

ACCEPTANCE CRITERIA:
  - Toolchain versions are pinned (language, package manager) and lockfiles committed
  - A development container defines an identical environment for every engineer
  - A clean checkout builds deterministically (same inputs → same result)
  - The dev environment matches what CI uses (no host-specific drift)
```

## 🏢 Business Context

"Works on my machine" is a reproducibility failure, and it's expensive: bugs that appear for one person and not another, builds that pass locally and fail in CI, hours lost to environment archaeology. The fix is to stop treating the developer's host as the environment. Pin everything, commit lockfiles, and define the environment as code — a development container — so every engineer (and CI) runs in a byte-identical setup. When the environment is reproducible, a bug reproduces everywhere, and "it builds" means it builds for everyone.

## 🎯 Learning Objectives

- Pin toolchain versions and commit lockfiles for deterministic installs
- Define a development container so every engineer's environment is identical
- Ensure a clean checkout builds deterministically
- Align the dev environment with CI (eliminate host drift)

## 📚 Technical Deep Dive

**Determinism = same inputs → same outputs.** A reproducible build depends only on committed inputs (source, pinned versions, lockfiles), never on whatever happens to be installed on the host.

**Pin versions; commit lockfiles.** A loose dependency (`"express": "^4"`) resolves to different versions over time and across machines. A **lockfile** (`package-lock.json`, `pnpm-lock.yaml`) records the exact resolved versions; committing it and installing with `npm ci` (not `npm install`) gives every machine the same dependency tree. Pin the toolchain too — the Node version (`.nvmrc`/`engines`), the package manager version — so the *tools* don't drift either.

```jsonc
// package.json
{ "engines": { "node": "22.13.x" }, "packageManager": "pnpm@9.7.0" }
```

**The development container defines the environment as code.** A dev container (e.g. a `.devcontainer/devcontainer.json` plus an image) specifies the exact OS, language runtime, tools, and extensions everyone codes in. Open the repo and you're in the same environment as every teammate — and as CI — regardless of your host OS.

```jsonc
// .devcontainer/devcontainer.json
{
  "image": "mcr.microsoft.com/devcontainers/javascript-node:22",
  "features": { "ghcr.io/devcontainers/features/docker-in-docker:2": {} },
  "postCreateCommand": "pnpm install --frozen-lockfile"
}
```

**Pin the base for the dev image too.** Same rule as Lesson 2: a pinned base (`...node:22`, ideally a digest) keeps the dev environment from drifting under everyone's feet.

**Dev matches CI.** The whole point: the environment you develop in is the environment that builds in CI (Lesson 7) and the base your production image builds from (Lesson 5). One reproducible toolchain, everywhere — so "passes locally" predicts "passes in CI."

**Reproducibility is layered.** Lockfiles pin *dependencies*; the dev container pins the *environment*; the image (Lesson 2) pins the *runtime*. Together they close the "works on my machine" gap at every level.

### Common gotchas
- `npm install` (re-resolves) instead of `npm ci` (installs the lockfile exactly).
- Lockfile not committed, or `.gitignore`-d — determinism lost.
- Unpinned toolchain (Node/PM version) so tools drift even if deps are pinned.
- A dev container that drifts from what CI/production actually use.

## 🧪 Hands-on Labs

Work through **`labs/lab-04-devcontainer.md`**. You'll pin the toolchain (`engines`, `packageManager`), ensure a committed lockfile + `npm ci`-style install, and define a dev container config. A reproducibility validator parses the manifests and checks: dependencies are pinned via a lockfile (no floating ranges relied on at install), the toolchain version is pinned, the dev container specifies a pinned image, and the install command is the deterministic one — failing a "drifty" setup and passing the pinned one.

## 🔍 Engineering Investigation

Take a "drifty" setup (floating deps, no committed lockfile, `npm install`, unpinned Node) and identify each source of non-determinism. Fix each (lockfile committed, `npm ci`, pinned `engines`, pinned dev-container image) and re-run the validator to a clean pass. In your notebook, describe a bug that host drift could cause and how the dev container eliminates it.

## 🤖 AI Engineering Exercise

Ask an AI to "set up a reproducible dev environment." **Verify** it commits/uses a lockfile with `npm ci`, pins the toolchain, and defines a pinned dev-container image that matches CI. **Log** where it left floating versions or used `npm install` and your fix.

## 📝 Assignment

Submit: the pinned toolchain + committed lockfile + deterministic install, the dev-container config, the passing reproducibility validation, and a note on one host-drift bug the dev container eliminates.

## 🚀 Stretch Goal

Pin a base image by **digest** (`@sha256:...`) instead of a tag and explain the additional guarantee it gives, plus the maintenance trade-off (you must bump it deliberately).

## ✅ Definition of Done

- [ ] Toolchain versions pinned; lockfile committed; deterministic install (`npm ci`)
- [ ] Dev container defines an identical environment (pinned image)
- [ ] A clean checkout builds deterministically
- [ ] Dev environment matches CI
- [ ] Reproducibility validation passes

## 🪞 Reflection

Which source of non-determinism would have been hardest to track down as a bug? Why is `npm ci` + a committed lockfile a correctness practice, not just a convenience?
