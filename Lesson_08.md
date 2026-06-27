# Lesson 08 — Build the Production Container Platform

> **Role:** Platform Engineer · **Competency:** Production Containers · **Track:** PROD · **Est. time:** 4–5 hours

---

## 🎫 Engineering Ticket

```
TICKET:      PROD-5001
TITLE:       A single container on one host is the whole production "platform"
PRIORITY:    P1
TYPE:        Architecture / Operations
DESCRIPTION: Production runs one container on one machine: no redundancy, no health
             recovery, no resource limits, and a deploy means downtime. Stand up a
             production container platform with an orchestrator: multiple replicas
             behind a service, health/readiness probes, resource requests and
             limits, configuration via env/secret references, and zero-downtime
             rolling updates.

ACCEPTANCE CRITERIA:
  - The service runs multiple replicas behind a stable service endpoint
  - Liveness and readiness probes drive restart and traffic decisions
  - Resource requests and limits are set; config/secrets injected (not baked in)
  - Deploys are zero-downtime rolling updates with a rollback path
```

## 🏢 Business Context

One container on one host is a demo, not a platform: a crash is an outage, a deploy is downtime, and a traffic spike has no headroom. A production container platform — an orchestrator like Kubernetes — runs multiple replicas, restarts unhealthy ones, routes traffic only to ready ones, enforces resource limits so one service can't starve others, injects configuration per environment, and rolls out new versions without downtime. This is where everything in the module comes together into something you can actually operate. It's "design for failure and operability" (Modules 03, 06) at the platform level.

## 🎯 Learning Objectives

- Run a service as multiple replicas behind a stable endpoint
- Configure liveness and readiness probes to drive restart/traffic decisions
- Set resource requests and limits; inject config/secrets (not baked in)
- Perform zero-downtime rolling updates with a rollback path

## 📚 Technical Deep Dive

**The orchestrator runs the desired state.** You declare what you want (N replicas of this image, with these resources and probes); the orchestrator makes reality match and keeps it there — restarting crashed containers, replacing unhealthy ones, rescheduling on node failure. Declarative, versioned manifests:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata: { name: forge-api }
spec:
  replicas: 3                                   # redundancy + headroom
  strategy:
    type: RollingUpdate
    rollingUpdate: { maxUnavailable: 0, maxSurge: 1 }   # zero-downtime
  template:
    spec:
      containers:
        - name: api
          image: forge-api:1.4.2                 # the pinned, tested artifact (Lesson 7)
          resources:
            requests: { cpu: "100m", memory: "128Mi" }   # scheduler guarantees
            limits:   { cpu: "500m", memory: "256Mi" }   # caps — can't starve neighbors
          readinessProbe: { httpGet: { path: /readyz, port: 8080 }, initialDelaySeconds: 5 }
          livenessProbe:  { httpGet: { path: /healthz, port: 8080 }, periodSeconds: 10 }
          envFrom:
            - secretRef:  { name: forge-api-secrets }     # config/secrets injected
```

**Replicas + a stable service.** Multiple replicas give redundancy and capacity; a **Service** gives a stable name/endpoint that load-balances across the healthy replicas (name-based discovery from Lesson 6, in production). A pod dying doesn't take the service down.

**Probes drive decisions** (the Module 06 health endpoints, now consumed):
- **Liveness** → *is it alive?* Fails → the orchestrator **restarts** it.
- **Readiness** → *can it serve?* Fails → it's pulled from the **load-balancer** (no traffic) but not restarted.
Keep liveness trivial and readiness dependency-aware (Module 06), or you get restart loops.

**Resource requests and limits.** *Requests* are what the scheduler guarantees (and uses to place pods); *limits* are hard caps so a runaway service can't starve its neighbors. Without limits, one memory leak takes down the node.

**Config and secrets are injected, not baked.** The image is the same everywhere (Lesson 2); per-environment config comes from ConfigMaps/Secrets mounted as env vars at runtime. Secrets never live in the image or the manifest in plaintext.

**Zero-downtime rolling updates.** A rolling update replaces replicas gradually (`maxUnavailable: 0` keeps full capacity, `maxSurge: 1` adds one new pod at a time), routing traffic only to ready new pods and keeping old ones until the new are healthy — so a deploy causes no downtime, and a bad rollout can be rolled back to the previous version.

### Common gotchas
- One replica (no redundancy; a crash or deploy is an outage).
- No resource limits (one service starves the node).
- Liveness that checks dependencies (restart loops) or no readiness (traffic to not-ready pods).
- `image: ...:latest` instead of the pinned tested tag (you don't know what's running).
- Secrets baked into the image or committed in the manifest.
- A recreate strategy (kill-all-then-start) instead of a rolling update → downtime.

## 🧪 Hands-on Labs

Work through **`labs/lab-08-production.md`**. You'll write the Forge production manifests (a Deployment + Service) and a validator will parse the YAML and assert the **production properties**: `replicas >= 2`, a `RollingUpdate` strategy with `maxUnavailable: 0`, resource **requests and limits** set, **both** liveness and readiness probes, a **pinned** image (not `latest`), and config/secrets via references (not inline plaintext). A naive manifest (1 replica, no limits, `latest`, no probes) fails with specific findings; the production one passes.

## 🔍 Engineering Investigation

Lint the naive manifest (single replica, `latest`, no probes, no limits, recreate) and record every finding. Author the production manifest and re-validate to a clean pass. Trace a rolling update: what happens to traffic and old pods as new ones become ready, and how a failed rollout is rolled back. Note what each missing property would cost in a real incident (outage on crash, node starvation, traffic to a not-ready pod).

## 🤖 AI Engineering Exercise

Ask an AI to "write Kubernetes manifests for this service." **Verify** multiple replicas, requests+limits, both probes (liveness trivial / readiness dependency-aware), a pinned image, injected secrets, and a rolling-update strategy. **Log** where it shipped one replica, `latest`, no limits, or no probes and your fix.

## 📝 Assignment

Submit the production Deployment + Service manifests, the passing validation (replicas ≥ 2, rolling update with `maxUnavailable: 0`, requests+limits, liveness+readiness, pinned image, referenced secrets), a trace of a zero-downtime rollout + rollback, and a note on what each property prevents in an incident.

## 🚀 Stretch Goal

Add a HorizontalPodAutoscaler (scale on CPU/memory) or a PodDisruptionBudget, and explain how it keeps the service available under load or during node maintenance.

## ✅ Definition of Done

- [ ] Multiple replicas behind a stable service
- [ ] Liveness + readiness probes drive restart/traffic decisions
- [ ] Resource requests and limits set; config/secrets injected (not baked)
- [ ] Zero-downtime rolling update with a rollback path
- [ ] Pinned image (not `latest`); validation passes

## 🪞 Reflection

Which missing property (replicas, limits, probes, rolling update) would have caused the worst incident, and why? How do the Module 06 health endpoints become the orchestrator's restart-and-traffic decisions here?
