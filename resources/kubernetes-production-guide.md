# Kubernetes Production Guide

## Declare desired state; the orchestrator maintains it
```yaml
apiVersion: apps/v1
kind: Deployment
metadata: { name: forge-api }
spec:
  replicas: 3
  strategy: { type: RollingUpdate, rollingUpdate: { maxUnavailable: 0, maxSurge: 1 } }
  template:
    spec:
      containers:
        - name: api
          image: forge-api:1.4.2                 # pinned, tested artifact
          resources:
            requests: { cpu: "100m", memory: "128Mi" }
            limits:   { cpu: "500m", memory: "256Mi" }
          readinessProbe: { httpGet: { path: /readyz, port: 8080 } }
          livenessProbe:  { httpGet: { path: /healthz, port: 8080 } }
          envFrom: [ { secretRef: { name: forge-api-secrets } } ]
```

## Replicas + Service
Multiple replicas = redundancy + capacity; a Service gives a stable, load-balanced endpoint over the healthy replicas. A pod dying doesn't drop the service.

## Probes drive decisions
- **Liveness** → alive? fail → **restart**. Keep it trivial.
- **Readiness** → can serve? fail → **pulled from the load-balancer** (no traffic), not restarted. Make it dependency-aware (Module 06).

## Requests and limits
Requests = scheduler guarantee (and placement); limits = hard caps so one service can't starve the node.

## Config/secrets injected
Same image everywhere; per-environment config via ConfigMaps/Secrets at runtime. Never bake secrets into the image or commit them in the manifest.

## Zero-downtime rolling update
`maxUnavailable: 0` keeps full capacity; `maxSurge: 1` adds new pods gradually, routing traffic only to ready ones, keeping old ones until new are healthy. A bad rollout rolls back.

## Gotchas
- One replica; no limits; `:latest`; missing probes; recreate strategy (downtime).
- Liveness checking dependencies (restart loops); secrets in the manifest.
