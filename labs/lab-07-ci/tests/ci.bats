setup() {
  LAB_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export WF="$LAB_DIR/ci.yml"
}

py() { python3 -c "$1"; }

@test "build job runs stages in order: npm ci -> lint -> test -> docker build -> trivy -> docker push" {
  run py "
import yaml,os
wf=yaml.safe_load(open(os.environ['WF']))
steps='\n'.join((s.get('run') or '') for s in wf['jobs']['build']['steps'])
order=['npm ci','lint','test','docker build','trivy','docker push']
last=-1
for stage in order:
    i=steps.find(stage)
    assert i>last, 'stage out of order or missing: '+stage
    last=i
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "install is deterministic (npm ci, not npm install)" {
  run py "
import yaml,os
wf=yaml.safe_load(open(os.environ['WF']))
steps='\n'.join((s.get('run') or '') for s in wf['jobs']['build']['steps'])
assert 'npm ci' in steps and 'npm install' not in steps, 'use npm ci, not npm install'
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "deploy is gated on build (needs: build)" {
  run py "
import yaml,os
wf=yaml.safe_load(open(os.environ['WF']))
needs=wf['jobs']['deploy'].get('needs')
ok = needs=='build' or (isinstance(needs,list) and 'build' in needs)
assert ok, 'deploy must declare needs: build'
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "deploy promotes the SHA-tagged built image and never uses :latest" {
  run py "
import yaml,os
wf=yaml.safe_load(open(os.environ['WF']))
dep='\n'.join((s.get('run') or '') for s in wf['jobs']['deploy']['steps'])
assert 'github.sha' in dep, 'deploy must promote the forge-api:\${{ github.sha }} image'
assert ':latest' not in dep, 'deploy must not use :latest'
print('ok')
"
  [ "$status" -eq 0 ]
}
