setup() {
  LAB_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export MANIFEST="$LAB_DIR/deployment.yml"
}

py() { python3 -c "$1"; }

# Shared loader: find the Deployment and Service docs.
LOADER="
import yaml,os
docs=[d for d in yaml.safe_load_all(open(os.environ['MANIFEST'])) if isinstance(d,dict)]
dep=next((d for d in docs if d.get('kind')=='Deployment'), None)
svc=next((d for d in docs if d.get('kind')=='Service'), None)
"

@test "file contains a Deployment and a Service document" {
  run py "$LOADER
assert dep is not None, 'no Deployment document'
assert svc is not None, 'no Service document'
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "replicas >= 2" {
  run py "$LOADER
assert (dep['spec'].get('replicas') or 0) >= 2, 'replicas must be >= 2'
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "zero-downtime rolling update (maxUnavailable: 0)" {
  run py "$LOADER
st=dep['spec'].get('strategy') or {}
assert st.get('type')=='RollingUpdate', 'strategy.type must be RollingUpdate'
assert (st.get('rollingUpdate') or {}).get('maxUnavailable')==0, 'maxUnavailable must be 0'
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "container has resource requests and limits (cpu + memory)" {
  run py "$LOADER
c=dep['spec']['template']['spec']['containers'][0]
r=c.get('resources') or {}
assert r.get('requests'), 'missing resource requests'
lim=r.get('limits') or {}
assert lim.get('cpu') and lim.get('memory'), 'missing cpu/memory limits'
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "container has both readiness and liveness probes" {
  run py "$LOADER
c=dep['spec']['template']['spec']['containers'][0]
assert c.get('readinessProbe'), 'missing readinessProbe'
assert c.get('livenessProbe'), 'missing livenessProbe'
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "image is pinned (not :latest, not untagged)" {
  run py "$LOADER
c=dep['spec']['template']['spec']['containers'][0]
img=c.get('image','')
assert ':' in img and not img.endswith(':latest'), 'image must be pinned, not :latest/untagged: %r'%img
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "secrets injected by reference (secretRef / secretKeyRef), not inline" {
  run py "$LOADER
import json
c=dep['spec']['template']['spec']['containers'][0]
blob=json.dumps(c)
assert 'secretRef' in blob or 'secretKeyRef' in blob, 'inject secrets via secretRef/secretKeyRef'
print('ok')
"
  [ "$status" -eq 0 ]
}
