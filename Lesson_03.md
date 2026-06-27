# Lesson 03 — Build a One-Command Development Environment

> **Role:** Platform Engineer · **Competency:** Docker Compose · **Track:** COMPOSE · **Est. time:** 3–4 hours

---

## 🎫 Engineering Ticket

```
TICKET:      COMPOSE-2010
TITLE:       New engineers spend a day wiring web + api + database by hand
PRIORITY:    P1 — developer experience
TYPE:        Feature
DESCRIPTION: Running Forge locally means starting the database, then the API, then
             the web app, in the right order, with the right connection settings —
             by hand, differently on every machine. Define the whole stack in Docker
             Compose so `one command` brings up web + api + database, correctly
             wired, with health-gated startup order, persistent data, and the ports
             a developer needs.

ACCEPTANCE CRITERIA:
  - A single compose file defines web, api, and database services
  - Services are wired by name; startup waits for dependencies to be healthy
  - Data persists across restarts (a volume); needed ports are published
  - `one command` brings the whole stack up (and down) reproducibly
```

## 🏢 Business Context

Developer experience is a feature. Every hour a new engineer spends fighting local setup is an hour not building Forge, and every subtly-different local environment is a "works on my machine" bug waiting to happen. A one-command dev environment — `docker compose up` and the whole platform is running, wired, and seeded — is one of the highest-leverage things a platform team ships. It also makes the local stack *match* the way services talk in production: by name, over a network, with health-gated dependencies.

## 🎯 Learning Objectives

- Define a multi-service stack in a single Docker Compose file
- Wire services by name and gate startup on dependency health
- Persist data with volumes and publish the ports developers need
- Bring the whole platform up and down with one command

## 📚 Technical Deep Dive

**Compose declares the whole stack.** One YAML file describes every service, how they connect, and what they need:

```yaml
services:
  db:
    image: postgres:16.2
    environment: { POSTGRES_PASSWORD: devpass }
    volumes: [ "forge-data:/var/lib/postgresql/data" ]   # data persists across restarts
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "postgres"]
      interval: 5s
  api:
    build: ./apps/api
    environment: { DATABASE_URL: "postgres://postgres:devpass@db:5432/forge" }  # 'db' = service name
    depends_on:
      db: { condition: service_healthy }                 # wait for db to be ready
    ports: [ "8080:8080" ]
  web:
    build: ./apps/web
    environment: { API_URL: "http://api:8080" }          # 'api' = service name
    depends_on:
      api: { condition: service_started }
    ports: [ "3000:3000" ]
volumes:
  forge-data:
```

**Service discovery by name.** Compose puts services on a shared network where each is reachable by its service name (`db`, `api`). The API connects to `db:5432`, the web app to `api:8080` — no IP addresses, no hardcoded hosts. This is exactly how services find each other in production orchestration (Lesson 6).

**Health-gated startup.** `depends_on` alone only orders *start*, not *readiness* — the API can start before the database accepts connections and crash. `condition: service_healthy` (backed by the db's `healthcheck`) makes the API wait until the database is actually ready. (This is the readiness idea from Module 06, now at the orchestration layer.)

**Volumes persist data.** Containers are ephemeral — their filesystem vanishes on removal. A named **volume** keeps the database's data across restarts so `compose down && compose up` doesn't wipe your local data.

**Ports: published vs internal.** `ports: ["8080:8080"]` publishes a port to the host (so you can hit it from your browser). Services that only other services need can stay unpublished — reachable on the internal network but not exposed. (Foreshadows network isolation in Lesson 6.)

**One command.** `docker compose up` builds/pulls, creates the network and volumes, and starts everything in dependency order; `docker compose down` tears it all down. Reproducible, for every developer.

### Common gotchas
- `depends_on` without a health condition (the API races the database and crashes).
- No volume for the database (data lost on every `down`).
- Hardcoding IPs/hosts instead of using service names.
- Publishing every port to the host (including internal-only services).

## 🧪 Hands-on Labs

Work through **`labs/lab-03-compose.md`**. You'll write the Forge `docker-compose.yml` (web + api + db) and a validator will parse it and assert the **wiring**: the api and web reference dependencies by service name, `api` waits for `db` with `condition: service_healthy`, the db has a named volume, and only the intended ports are published. A broken compose file (racey `depends_on`, no volume) fails the checks; the correct one passes.

## 🔍 Engineering Investigation

Bring the stack up conceptually and trace startup order: which service must be healthy before which starts, and what happens without the health gate (the API crash loop). Confirm the validator reports service-name wiring, the health-gated dependency, the persistent volume, and the published ports. Record the one command that replaces the old manual sequence.

## 🤖 AI Engineering Exercise

Ask an AI to "write a compose file for web, api, and a database." **Verify** services are wired by name, `depends_on` uses a health condition (not bare ordering), the database has a volume, and only necessary ports are published. **Log** where it raced startup or dropped the volume and your fix.

## 📝 Assignment

Submit the `docker-compose.yml`, the passing validation (service-name wiring, health-gated `depends_on`, persistent volume, published ports), and a before/after of the developer setup (manual steps → one command).

## 🚀 Stretch Goal

Add a seed/migration step (run the database migrations once on startup) or a compose `profiles` setup so a developer can bring up just the API + db without the web app, and explain the DX win.

## ✅ Definition of Done

- [ ] One compose file defines web, api, and database
- [ ] Services wired by name; startup health-gated (`service_healthy`)
- [ ] Database data persists via a named volume; needed ports published
- [ ] One command brings the stack up and down
- [ ] Validation passes (wiring, health gate, volume, ports)

## 🪞 Reflection

How many manual steps did one command replace? Why does gating startup on *health* (not just order) matter, and where have you seen a service race its database before?
