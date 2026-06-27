# Lab 08 — Build the Production Container Platform

**Goal:** production Kubernetes manifests (a **Deployment** + a **Service**) with replicas,
both probes, resource limits, a pinned image, injected secrets, and a zero-downtime rollout —
proven by parsing and policy-checking the YAML.

## What you do

Complete [`deployment.yml`](deployment.yml). Put **both** documents in the one file, separated
by `---`:

### The Deployment must have
1. **`replicas >= 2`** (redundancy + headroom).
2. **A zero-downtime rolling update:** `strategy.type: RollingUpdate` with
   `rollingUpdate.maxUnavailable: 0`.
3. **Resource `requests` and `limits`** (both cpu and memory under `limits`).
4. **Both probes:** a `readinessProbe` and a `livenessProbe` on the container.
5. **A pinned image** (`forge-api:1.4.2`, **not** `:latest`, not untagged).
6. **Secrets by reference** — inject config via `envFrom: [{ secretRef: { name: ... } }]`
   (or `valueFrom.secretKeyRef`), **not** inline plaintext.

### The Service must
- be a second document (`kind: Service`) selecting the Deployment's pods.

```bash
npx bats labs/lab-08-production/tests
```

## How it's graded

`python3` loads **all** documents from the file, finds the `Deployment` and the `Service`,
and applies the policy above. No cluster is contacted.

## Definition of done

- Tests green.
- A trace of a zero-downtime rollout + rollback and a note on what each property prevents in
  an incident.
