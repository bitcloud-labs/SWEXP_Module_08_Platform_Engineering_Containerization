# Lesson 06 — Build the Container Network

> **Role:** Platform Engineer · **Competency:** Container Networking · **Track:** NET · **Est. time:** 3–4 hours

---

## 🎫 Engineering Ticket

```
TICKET:      NET-4001
TITLE:       The database is reachable from the public internet
PRIORITY:    P0 — security
TYPE:        Architecture / Security
DESCRIPTION: Every service currently publishes its port to the host, so the
             database and internal services are exposed far more widely than they
             should be. Design the container network: services discover each other
             by name on internal networks, only the edge (web/gateway) is exposed
             publicly, the database sits on an internal-only network, and traffic is
             segmented so a compromised service can't reach everything.

ACCEPTANCE CRITERIA:
  - Services communicate by name over defined networks (not host IPs)
  - Only intended edge services publish ports to the host; the database does not
  - The database is on an internal-only network, reachable solely by the API
  - Network segmentation limits blast radius (front/back tiers separated)
```

## 🏢 Business Context

A database exposed to the internet is a breach waiting to happen — and "publish every port" is how it happens by default. How containers network determines both whether services can find each other and who can reach what. Good network design gives services clean name-based discovery while keeping the attack surface tiny: only the edge is public, internal services talk on private networks, and segmentation means a compromised front-end service can't pivot straight to the database. This is least privilege applied to traffic.

## 🎯 Learning Objectives

- Connect services on defined networks and discover them by name
- Expose only intended edge services; keep internal services unpublished
- Place the database on an internal-only network reachable by just its consumer
- Segment networks (front/back tiers) to limit blast radius

## 📚 Technical Deep Dive

**Name-based service discovery.** On a container network, each service is reachable by its name — the API reaches the database at `db:5432`, the web app reaches the API at `api:8080`. No IP addresses, no hardcoded hosts; the network resolves names. (Same model as Compose in Lesson 3, now designed deliberately.)

**Published vs internal ports.** Publishing a port (`ports: ["8080:8080"]`) maps it to the host, making it reachable from outside. A service that only *other services* call needs **no** published port — it's reachable on the internal network but invisible to the host and the internet. The database should never be published.

**Segment the network into tiers.** Put services on separate networks so only the right ones can talk:

```yaml
services:
  web:
    networks: [ frontend ]            # edge: talks to api; published to host
    ports: [ "3000:3000" ]
  api:
    networks: [ frontend, backend ]   # bridges the tiers
  db:
    networks: [ backend ]             # internal only — NO ports published, NOT on frontend
networks:
  frontend:
  backend:
    internal: true                    # backend has no external connectivity
```
Here the web app can reach the API (shared `frontend` network) but **cannot** reach the database — only the API, which is on both networks, can. A compromised web container can't touch the database directly. That's segmentation limiting blast radius.

**Least privilege for traffic.** The default should be *deny*: a service can reach only what it must. Expose the minimum (just the edge), publish the minimum (only host-facing ports), and connect services to only the networks they need. An `internal: true` network has no route to the outside world at all.

**This is the same model in production.** Kubernetes does this with Services (name-based discovery), ClusterIP (internal-only) vs LoadBalancer (exposed), and NetworkPolicies (segmentation) — Lesson 8. The concepts you design here carry straight up.

### Common gotchas
- Publishing every service's port to the host (database on the internet).
- One flat network where every service can reach every other (no segmentation).
- Hardcoding IPs instead of using service names.
- Forgetting `internal: true` on the back tier, so it still has outbound/inbound routes.

## 🧪 Hands-on Labs

Work through **`labs/lab-06-networking.md`**. You'll design the Forge network topology in compose form (frontend/backend tiers) and a validator will parse it and assert the **security properties**: the database publishes **no** host ports and is **not** on the frontend network; the web app is on the frontend (and published) but **cannot** reach the db; the api bridges both tiers; and the backend network is `internal: true`. A flat "everything exposed" topology fails the checks; the segmented one passes.

## 🔍 Engineering Investigation

Start from the "everything published, one network" topology and list exactly who can reach the database (everyone). Redesign with tiers and record the new reachability: web → api (yes), web → db (no), api → db (yes), host → db (no). Confirm the validator reports the database unpublished, off the frontend, and the backend internal. Note the breach the old topology invited.

## 🤖 AI Engineering Exercise

Ask an AI to "set up networking for these services." **Verify** only the edge publishes ports, the database is internal-only and unreachable from the front tier, services use names, and tiers are segmented. **Log** where it published the database or used one flat network and your fix.

## 📝 Assignment

Submit the segmented network topology, the passing validation (db unpublished + off frontend, backend `internal`, edge-only exposure, name-based discovery), a reachability table (who can reach what, before vs after), and a note on the blast-radius reduction.

## 🚀 Stretch Goal

Express the same segmentation as Kubernetes NetworkPolicies (default-deny + explicit allows) and explain how it maps to the compose tiers you designed.

## ✅ Definition of Done

- [ ] Services discover each other by name over defined networks
- [ ] Only edge services publish ports; the database does not
- [ ] Database on an internal-only network, reachable only by the API
- [ ] Tiers segmented; backend `internal: true`; blast radius limited
- [ ] Validation passes; reachability table documented

## 🪞 Reflection

Who could reach the database before, and who can now? Why is "deny by default, expose the minimum" the right posture for container traffic?
