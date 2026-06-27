# Lesson 01 — Reorganize Project Forge

> **Role:** Platform Engineer · **Competency:** Monorepo Architecture · **Track:** REPO · **Est. time:** 3–4 hours

---

## 🎫 Engineering Ticket

```
TICKET:      REPO-1010
TITLE:       Forge's apps live in three drifting repos that share copy-pasted code
PRIORITY:    P1
TYPE:        Architecture
DESCRIPTION: The web app (M05), the API (M06), and shared types/utilities live in
             separate repositories. Shared code is copy-pasted and drifts; a change
             to a shared type means three PRs; there's no single place to build and
             version the platform. Reorganize Forge into a monorepo with clear
             package boundaries, workspace tooling, and shared packages consumed by
             the apps — without creating a tangled big ball of mud.

ACCEPTANCE CRITERIA:
  - One repository with a clear, documented layout (apps vs shared packages)
  - Workspace tooling manages dependencies across packages
  - Shared code lives in a package the apps depend on (no copy-paste)
  - Dependency boundaries are explicit (apps may depend on packages, not vice versa)
```

## 🏢 Business Context

How you organize the repository is an architecture decision, not bookkeeping. When the web app, the API, and their shared types live in separate repos, a single change to a shared contract becomes a multi-repo, multi-PR coordination problem, and copy-pasted code silently drifts until the frontend and backend disagree about what an `Order` is. A monorepo puts the whole platform in one versioned place with shared packages as the single source of truth — so a contract change is one atomic commit, and the boundaries between pieces are explicit and enforceable.

## 🎯 Learning Objectives

- Structure a monorepo with clear apps-vs-packages boundaries
- Use workspace tooling to manage cross-package dependencies
- Extract shared code into a package consumed by the apps (no copy-paste)
- Make dependency direction explicit (apps → packages, never the reverse)

## 📚 Technical Deep Dive

**A monorepo is one repo, many packages.** Not one giant tangle — a structured set of independently-defined packages with explicit dependencies:

```
forge/
├── package.json            # workspace root
├── apps/
│   ├── web/                # M05 frontend  (depends on @forge/types, @forge/ui)
│   └── api/                # M06 backend   (depends on @forge/types)
├── packages/
│   ├── types/              # shared domain types (the Order contract)
│   └── ui/                 # shared UI components
└── ...
```

**Workspaces manage cross-package dependencies.** The workspace root declares where packages live; the tool (npm/pnpm/yarn workspaces, or a build system like Turborepo/Nx) links them so `apps/web` can `import { Order } from '@forge/types'` and get the local package, not a copy.

```json
{ "name": "forge", "private": true, "workspaces": ["apps/*", "packages/*"] }
```

**Shared code is a package, not a copy.** The `Order` type from Module 04 lives once in `@forge/types`; the web and api both depend on it. Change it once, and both apps see the change (and the type-checker flags every mismatch) — the drift problem is gone structurally.

**Dependency direction is a rule.** Apps depend on packages; packages don't depend on apps; shared packages don't depend on each other circularly. This is the same "dependencies point inward" discipline from Module 06's layering, now at the repository scale. A dependency-boundary check (a lint rule or a CI step) can enforce it so the architecture can't silently rot.

**Why not just separate repos?** Separate repos give independent versioning but make cross-cutting changes painful and let shared code drift. A monorepo trades that for atomic cross-package changes and one source of truth — the right call when the apps ship together as one platform.

### Common gotchas
- A "monorepo" that's just everything dumped in one folder with no boundaries (a big ball of mud).
- Copy-pasting shared code instead of extracting a package (drift returns).
- Circular dependencies between packages, or a package depending on an app.
- No workspace tooling, so packages can't reference each other cleanly.

## 🧪 Hands-on Labs

Work through **`labs/lab-01-monorepo.md`**. You'll define the Forge monorepo layout (a workspace root + `apps/*` and `packages/*`), declare the workspace config, and extract a shared `@forge/types` package the apps depend on. A validator parses the workspace config and the package manifests and checks the **dependency boundaries** — apps may depend on packages, packages must not depend on apps, and there are no cycles — failing a deliberately-wrong layout and passing the correct one.

## 🔍 Engineering Investigation

Map Forge's current code to a monorepo layout: what's an app, what's a shared package, what was copy-pasted that should be extracted. After reorganizing, run the dependency-boundary check and record that the apps depend on `@forge/types` (not a copy) and that no package depends on an app. Note one bug the old copy-paste drift could have caused.

## 🤖 AI Engineering Exercise

Ask an AI to "set up a monorepo for these apps." **Verify** it creates real package boundaries (not one folder), wires workspaces so apps can import shared packages, and keeps dependency direction sane (no package → app, no cycles). **Log** where it produced a tangle or left copy-pasted code and how you fixed it.

## 📝 Assignment

Submit the monorepo layout: the workspace config, the `apps/*` and `packages/*` structure, the extracted shared package, and the passing dependency-boundary check (apps → packages, no app dependency, no cycles) — plus a note on the drift the old structure caused.

## 🚀 Stretch Goal

Add a build-graph tool (Turborepo/Nx) or a task pipeline that builds packages before the apps that depend on them, and explain how the dependency graph drives correct, cacheable build order.

## ✅ Definition of Done

- [ ] One repo with a clear apps-vs-packages layout
- [ ] Workspace tooling manages cross-package dependencies
- [ ] Shared code extracted into a package (no copy-paste)
- [ ] Dependency boundaries explicit and checked (apps → packages, no cycles)

## 🪞 Reflection

What did copy-pasting shared code cost (or risk) before? Why is dependency *direction* a rule worth enforcing in CI rather than trusting to discipline?
