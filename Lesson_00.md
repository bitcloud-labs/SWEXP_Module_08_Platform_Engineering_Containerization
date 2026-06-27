# Lesson 00 — Welcome to the Platform Engineering Team

> **Role:** Platform Engineer · **Competency:** Platform Engineering Orientation · **Track:** PLAT · **Est. time:** 2–3 hours

---

## 🎫 Engineering Ticket

```
TICKET:      PLAT-1000
TITLE:       Onboard to the Project Forge platform
PRIORITY:    P1 — blocks all platform work
TYPE:        Onboarding
ASSIGNEE:    You (Platform Engineer)
DESCRIPTION: Forge is three apps built across earlier modules — a web frontend
             (M05), an API (M06), and a data layer (M07) — that currently run only
             on the original authors' laptops, set up by hand. Your job is to turn
             Forge into a reproducible platform: one repo, containerized services, a
             one-command dev environment, automated builds, and production-ready
             infrastructure. Set up the toolchain and understand the lifecycle of a
             build artifact from source to production.

ACCEPTANCE CRITERIA:
  - The platform toolchain runs; you can validate a config file and a Dockerfile
  - You can explain "build once, run anywhere" and why it matters
  - You can describe an artifact's path: source → image → environments
  - Your engineering notebook has a dated first entry
```

## 🏢 Business Context

A product that only runs where it was written isn't a product — it's a demo. Every new hire who spends two days getting Forge running, every "works on my machine" bug, every manual deploy that goes wrong at 2am is the same root problem: the way software is built and run isn't *reproducible*. Platform engineering fixes that. You make one artifact that runs identically on a laptop, in CI, and in production, shipped by automation instead of by hand. That reproducibility is what lets a team move fast without breaking things.

## 🎯 Learning Objectives

- Set up the platform toolchain and validate a config file and a Dockerfile
- Explain "build once, run anywhere" and the cost of non-reproducibility
- Trace a build artifact's lifecycle: source → image → environments
- Map the module's arc (monorepo → containers → compose → reproducibility → images → networking → CI/CD → production)

## 📚 Technical Deep Dive

**Build once, run anywhere.** The core idea of containerization: package an application and everything it needs (runtime, libraries, config defaults) into one immutable **image**, then run that same image everywhere. The image you tested is the image that runs in production — bit for bit. No "but it worked in staging."

**The artifact lifecycle.**
```
source code  →  build  →  image (immutable, tagged)  →  registry  →  run in any environment
                                                                    (laptop / CI / staging / prod)
```
The image is built once and promoted through environments unchanged; only *configuration* (env vars, secrets) differs per environment.

**Infrastructure as code.** Platform work is *declarative and versioned*: Dockerfiles, compose files, CI pipelines, and Kubernetes manifests are text files in the repo, reviewed in pull requests, applied by automation. Nothing is hand-clicked in a console where it can't be reviewed or reproduced.

**Configuration is reviewable text.** Most of what you'll write this module is config — YAML and Dockerfiles. So the first skill is *validating* it: does it parse, and does it declare what you intended? You'll lint Dockerfiles and parse/validate compose and Kubernetes YAML, the same way you'd type-check code.

```dockerfile
# a Dockerfile is a recipe for an image — declarative, versioned, reviewable
FROM node:22.13-bookworm-slim
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
CMD ["node", "server.js"]
```

**The module arc.** Reorganize into a monorepo → containerize a service → wire a one-command dev environment with compose → make it reproducible (pinned versions, dev containers) → engineer lean production images → build the container network → automate builds with CI/CD → run a production container platform → ship it.

### Common gotchas
- Treating infrastructure as something you click together once, not code you version.
- Confusing the image (the immutable artifact) with configuration (what varies per environment).
- "It runs on my machine" — the exact problem this module eliminates.

## 🧪 Hands-on Labs

Work through **`labs/lab-00-setup.md`**: set up the toolchain, validate a YAML config file (it parses and has the keys you intended) and a Dockerfile (it passes a basic best-practice lint), and trace one artifact's path from source to a running environment.

## 🔍 Engineering Investigation

Take Forge's three apps and, in your notebook, sketch the artifact lifecycle for one of them: what gets built, what the image contains, what's configuration vs baked-in, and which environments the same image will run in. Note one thing that's currently "works on my machine" and how an immutable image fixes it.

## 🤖 AI Engineering Exercise

Ask an AI to "write a Dockerfile for a Node app." **Draft** it, then **verify**: does it parse/lint cleanly, pin its base image, and avoid baking in configuration? **Log** what you kept and corrected. The loop all module: **draft → verify (parse/lint the config, run the build logic, check the policy) → log.**

## 📝 Assignment

1. Set up the toolchain; paste `node --version` and a validated config + Dockerfile lint result.
2. Complete the lab; include the artifact-lifecycle sketch for one Forge app.
3. Write a 5–8 sentence explainer: "what does 'build once, run anywhere' buy a team, and what breaks without it?"
4. Commit your notebook.

## 🚀 Stretch Goal

Find a real "works on my machine" story (yours or a well-known postmortem) and write a paragraph on which reproducibility practice from this module's arc would have prevented it.

## ✅ Definition of Done

- [ ] Toolchain runs; a config file validates and a Dockerfile lints
- [ ] Artifact lifecycle sketched for one Forge app
- [ ] "Build once, run anywhere" explainer written
- [ ] Notebook committed

## 🪞 Reflection

Where has "works on my machine" cost you time before? What does making the build artifact immutable change about how a team ships software?
