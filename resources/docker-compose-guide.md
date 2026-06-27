# Docker Compose Guide

## One file describes the whole stack
```yaml
services:
  db:
    image: postgres:16.2
    volumes: [ "forge-data:/var/lib/postgresql/data" ]   # persist data
    healthcheck: { test: ["CMD","pg_isready","-U","postgres"], interval: 5s }
  api:
    build: ./apps/api
    environment: { DATABASE_URL: "postgres://postgres:devpass@db:5432/forge" }
    depends_on: { db: { condition: service_healthy } }    # wait for ready db
    ports: [ "8080:8080" ]
  web:
    build: ./apps/web
    environment: { API_URL: "http://api:8080" }
    depends_on: { api: { condition: service_started } }
    ports: [ "3000:3000" ]
volumes: { forge-data: }
```

## Service discovery by name
Services reach each other by **service name** on the shared network — `db:5432`, `api:8080`. No IPs, no hardcoded hosts. Same model as production orchestration.

## Health-gated startup
`depends_on` alone orders *start*, not *readiness*. `condition: service_healthy` (backed by a `healthcheck`) makes a service wait until its dependency actually accepts connections — no crash-loop racing the database.

## Volumes persist data
Containers are ephemeral; a named volume keeps the database's data across `compose down && up`.

## Published vs internal ports
`ports: ["8080:8080"]` exposes to the host. Internal-only services need no published port. Don't publish the database (Lesson 6).

## One command
`docker compose up` builds/pulls, creates network + volumes, and starts in dependency order; `down` tears it down. Reproducible for every developer.

## Gotchas
- `depends_on` with no health condition; no volume (data lost); hardcoded IPs; publishing everything.
