setup() {
  CAP_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  SOL="$CAP_DIR/solution.sh"
  P="$CAP_DIR/platform"
  export DF="$P/Dockerfile"
  export COMPOSE="$P/docker-compose.yml"
  export WF="$P/.github/workflows/ci.yml"
  export MANIFEST="$P/k8s/deployment.yml"
  export DEPS="$P/forge.deps"
}

py() { python3 -c "$1"; }

# ---- Bar 1: monorepo boundaries (via solution.sh) ----

@test "monorepo: the platform's dependency graph has no boundary/cycle violations" {
  run bash "$SOL"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "monorepo: solution.sh still flags a bad graph (package -> app)" {
  bad="$(mktemp)"; printf 'packages/types -> apps/web\napps/web ->\n' > "$bad"
  run bash "$SOL" "$bad"; rm -f "$bad"
  [ "$status" -eq 0 ]
  echo "$output" | grep -qi 'boundary'
}

# ---- Bar 2: production image ----

@test "image: multi-stage, pinned, non-root, healthchecked, no secrets" {
  run bash -c "grep -Eiq '^[[:space:]]*FROM[[:space:]]+\S+[[:space:]]+AS[[:space:]]+\S+' '$DF'"; [ "$status" -eq 0 ]
  [ "$(grep -Eci '^[[:space:]]*FROM[[:space:]]' "$DF")" -ge 2 ]
  run grep -Eiq '^[[:space:]]*FROM[[:space:]]+\S+:latest' "$DF"; [ "$status" -ne 0 ]
  run grep -Eiq '^[[:space:]]*COPY[[:space:]]+--from=build' "$DF"; [ "$status" -eq 0 ]
  run bash -c "grep -Eiq '^[[:space:]]*USER[[:space:]]+\S+' '$DF' && ! grep -Eiq '^[[:space:]]*USER[[:space:]]+root([[:space:]]|\$)' '$DF'"; [ "$status" -eq 0 ]
  run grep -Eiq '^[[:space:]]*HEALTHCHECK[[:space:]]' "$DF"; [ "$status" -eq 0 ]
  run grep -Eiq '^[[:space:]]*(ENV|ARG)[[:space:]].*(PASSWORD|SECRET|TOKEN|API_?KEY)' "$DF"; [ "$status" -ne 0 ]
}

# ---- Bar 3: segmented network ----

@test "network: db is internal-only and unreachable from the edge" {
  run py "
import yaml,os
c=yaml.safe_load(open(os.environ['COMPOSE']))
nets=lambda s:set(c['services'][s].get('networks') or [])
assert (c.get('networks') or {}).get('backend',{}).get('internal') is True, 'backend must be internal'
assert not (c['services']['db'].get('ports') or []), 'db must publish nothing'
assert not (nets('web') & nets('db')), 'web must not reach db'
assert nets('api') & nets('db'), 'api must reach db'
assert any('3000' in str(p) for p in (c['services']['web'].get('ports') or [])), 'web (edge) must publish 3000'
print('ok')
"
  [ "$status" -eq 0 ]
}

# ---- Bar 4: CI/CD ----

@test "ci: ordered gates, deploy needs build, promotes SHA image (no :latest)" {
  run py "
import yaml,os
wf=yaml.safe_load(open(os.environ['WF']))
steps='\n'.join((s.get('run') or '') for s in wf['jobs']['build']['steps'])
last=-1
for stage in ['npm ci','lint','test','docker build','trivy','docker push']:
    i=steps.find(stage); assert i>last,'stage order/missing: '+stage; last=i
assert 'npm install' not in steps, 'use npm ci'
needs=wf['jobs']['deploy'].get('needs')
assert needs=='build' or (isinstance(needs,list) and 'build' in needs), 'deploy needs build'
dep='\n'.join((s.get('run') or '') for s in wf['jobs']['deploy']['steps'])
assert 'github.sha' in dep and ':latest' not in dep, 'deploy must promote SHA image, not :latest'
print('ok')
"
  [ "$status" -eq 0 ]
}

# ---- Bar 5: production orchestration ----

@test "k8s: replicas>=2, zero-downtime, limits, both probes, pinned image, secretRef" {
  run py "
import yaml,os,json
docs=[d for d in yaml.safe_load_all(open(os.environ['MANIFEST'])) if isinstance(d,dict)]
dep=next((d for d in docs if d.get('kind')=='Deployment'),None)
svc=next((d for d in docs if d.get('kind')=='Service'),None)
assert dep and svc, 'need a Deployment and a Service'
assert (dep['spec'].get('replicas') or 0)>=2, 'replicas >= 2'
st=dep['spec'].get('strategy') or {}
assert st.get('type')=='RollingUpdate' and (st.get('rollingUpdate') or {}).get('maxUnavailable')==0, 'zero-downtime rollout'
c=dep['spec']['template']['spec']['containers'][0]
lim=(c.get('resources') or {}).get('limits') or {}
assert (c.get('resources') or {}).get('requests') and lim.get('cpu') and lim.get('memory'), 'requests+limits'
assert c.get('readinessProbe') and c.get('livenessProbe'), 'both probes'
img=c.get('image','')
assert ':' in img and not img.endswith(':latest'), 'pinned image'
assert 'secretRef' in json.dumps(c) or 'secretKeyRef' in json.dumps(c), 'secrets by reference'
print('ok')
"
  [ "$status" -eq 0 ]
}
