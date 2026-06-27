# Lab 06 — Build the Container Network

**Goal:** a segmented topology where the **edge is exposed, the database is internal-only,
and the web app cannot reach the db** — proven by parsing the topology and computing
reachability.

## What you do

Complete [`docker-compose.yml`](docker-compose.yml). It must define two networks and three
services:

1. **Two tiers:** networks `frontend` and `backend`; `backend` is `internal: true`.
2. **Segment the services:**
   - `web` → `frontend` only, and **publishes** `3000:3000` (the edge).
   - `api` → **both** `frontend` and `backend` (the only bridge between tiers).
   - `db`  → `backend` only, and **publishes nothing**.
3. The resulting reachability must be: web→api **yes** (shared `frontend`), web→db **no**
   (no shared network), api→db **yes**, host→db **no** (db publishes no ports).

```bash
npx bats labs/lab-06-networking/tests
```

## How it's graded

`python3` parses the topology and computes reachability as "do these two services share a
network?" — then asserts the security properties. No containers are started.

## Definition of done

- Tests green.
- A reachability table (web→api yes, web→db no, api→db yes, host→db no) and a note on the
  blast-radius reduction.
