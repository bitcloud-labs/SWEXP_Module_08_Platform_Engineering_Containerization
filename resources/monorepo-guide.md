# Monorepo Guide

## One repo, many packages
A monorepo is a structured set of packages with explicit dependencies — not one big folder.
```
forge/
├── package.json          # { "private": true, "workspaces": ["apps/*","packages/*"] }
├── apps/{web,api}/       # applications
└── packages/{types,ui}/  # shared packages
```

## Workspaces
The root declares where packages live; the tool (npm/pnpm/yarn workspaces, or Turborepo/Nx) links them so an app can `import { Order } from '@forge/types'` and get the local package, not a copy.

## Shared code is a package, not a copy
The `Order` contract lives once in `@forge/types`; the web and api depend on it. Change it once; both see it and the type-checker flags mismatches. No drift.

## Dependency direction is a rule
- Apps may depend on packages.
- **Packages must not depend on apps.**
- **No cycles.**
Enforce it with a boundary check in CI ("dependencies point inward", Module 06, at repo scale) so the architecture can't silently rot.

## Monorepo vs many repos
Many repos give independent versioning but make cross-cutting changes painful and let shared code drift. A monorepo gives atomic cross-package changes and one source of truth — right when the apps ship together as one platform.

## Gotchas
- A "monorepo" with no boundaries (a big ball of mud).
- Copy-pasting shared code; circular package deps; a package depending on an app.
- No workspace tooling, so packages can't reference each other cleanly.
