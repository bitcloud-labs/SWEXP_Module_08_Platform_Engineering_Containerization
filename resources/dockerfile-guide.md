# Dockerfile Guide

## A Dockerfile is a recipe for an immutable image
```dockerfile
FROM node:22.13-bookworm-slim     # pinned base, not :latest
WORKDIR /app
COPY package*.json ./             # deps layer (changes rarely)
RUN npm ci                        # cached unless package*.json changes
COPY . .                          # source layer (changes often)
RUN npm run build
USER node                         # non-root runtime
HEALTHCHECK CMD node healthcheck.js
CMD ["node", "dist/server.js"]
```

## Layers and the build cache
Each instruction is a cached layer; a change rebuilds from that instruction onward. Put rarely-changing things (dependency install) **before** often-changing things (source) so a code edit doesn't reinstall everything.

## Pin the base
`:latest` is a moving target — non-reproducible. Pin a specific tag (ideally a digest). Prefer slim/minimal bases for size and attack surface.

## .dockerignore
Keep junk and secrets out of the build context:
```
node_modules
.git
.env
*.log
dist
```

## Run as non-root
Default is root; a compromise then has root in the container. Create/use a non-root `USER`.

## Config from the environment
The same image runs everywhere — don't bake env-specific config or secrets in. Read config from env vars at runtime; pass secrets at run time (12-factor).

## Gotchas
- `FROM ...:latest`; `COPY . .` before `npm ci`; no `.dockerignore`.
- Running as root; baking secrets/config into the image.
