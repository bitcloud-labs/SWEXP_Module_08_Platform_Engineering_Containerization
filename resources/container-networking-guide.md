# Container Networking Guide

## Name-based discovery
On a container network each service is reachable by name — api → `db:5432`, web → `api:8080`. No IPs.

## Published vs internal
Publishing a port maps it to the host (reachable from outside). A service only other services call needs **no** published port. **Never publish the database.**

## Segment into tiers
```yaml
services:
  web: { networks: [frontend], ports: ["3000:3000"] }   # edge, published
  api: { networks: [frontend, backend] }                 # bridges tiers
  db:  { networks: [backend] }                           # internal only, no ports
networks:
  frontend: {}
  backend: { internal: true }
```
`web` can reach `api` (shared frontend) but **not** `db` — only `api` (on both) can. A compromised web container can't touch the database. That's blast-radius limiting.

## Least privilege for traffic
Default deny: a service reaches only what it must. Expose the minimum (edge), publish the minimum (host-facing only), connect to only needed networks. `internal: true` = no route to the outside.

## Same model in production
Kubernetes: Services (name discovery), ClusterIP (internal) vs LoadBalancer (exposed), NetworkPolicies (segmentation). Lesson 8.

## Gotchas
- Publishing every port (database on the internet); one flat network.
- Hardcoded IPs; forgetting `internal: true` on the back tier.
