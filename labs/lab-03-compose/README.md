# Lab 03 — One-Command Development Environment

**Goal:** a `docker-compose.yml` that brings up **web + api + db**, wired by name,
health-gated, with a persistent volume — proven by parsing the compose graph.

## What you do

Complete [`docker-compose.yml`](docker-compose.yml). It must:

1. **Define all three services:** `web`, `api`, `db`.
2. **Wire by name (service names, not IPs):**
   - `api`'s `DATABASE_URL` connects to the `db` host — it must contain `@db:`
     (e.g. `postgres://postgres:devpass@db:5432/forge`).
   - `web`'s `API_URL` connects to the `api` host — it must contain `api:`
     (e.g. `http://api:8080`).
3. **Health-gate startup:** the `db` declares a `healthcheck`, and `api` declares
   `depends_on: { db: { condition: service_healthy } }`.
4. **Persist data:** a **named volume** on `db` (e.g. `forge-data:/var/lib/postgresql/data`)
   and a top-level `volumes:` entry for it.
5. **Publish only what developers need:** `web` publishes `3000`, `api` publishes `8080`.

```bash
npx bats labs/lab-03-compose/tests
```

## How it's graded

The grader parses your YAML with `python3` and asserts the wiring above. It does **not**
run `docker compose up`.

## Definition of done

- Tests green.
- A note on the before/after of developer setup (manual steps → one command).
