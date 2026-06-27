setup() {
  LAB_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  COMPOSE="$LAB_DIR/docker-compose.yml"
  export COMPOSE
}

py() { python3 -c "$1"; }

@test "defines all three services: web, api, db" {
  run py "
import yaml,os
c=yaml.safe_load(open(os.environ['COMPOSE'])) or {}
s=c.get('services') or {}
for name in ('web','api','db'):
    assert name in s, 'missing service: '+name
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "api connects to db by name (@db:) and web connects to api by name (api:)" {
  run py "
import yaml,os
c=yaml.safe_load(open(os.environ['COMPOSE']))
def env(svc):
    e=c['services'][svc].get('environment') or {}
    if isinstance(e,list):
        e=dict(x.split('=',1) for x in e if '=' in x)
    return e
api=env('api'); web=env('web')
assert '@db:' in (api.get('DATABASE_URL') or ''), 'api DATABASE_URL must reference @db:'
assert 'api:' in (web.get('API_URL') or ''), 'web API_URL must reference api:'
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "db has a healthcheck" {
  run py "
import yaml,os
c=yaml.safe_load(open(os.environ['COMPOSE']))
assert c['services']['db'].get('healthcheck'), 'db needs a healthcheck'
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "api waits for a healthy db (depends_on condition service_healthy)" {
  run py "
import yaml,os
c=yaml.safe_load(open(os.environ['COMPOSE']))
dep=c['services']['api'].get('depends_on')
assert isinstance(dep,dict), 'api depends_on must use the long form with a condition'
assert dep.get('db',{}).get('condition')=='service_healthy', 'api must wait for db service_healthy'
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "db persists data on a named volume declared at the top level" {
  run py "
import yaml,os
c=yaml.safe_load(open(os.environ['COMPOSE']))
vols=c['services']['db'].get('volumes') or []
names=[(v.split(':')[0] if isinstance(v,str) else v.get('source')) for v in vols]
named=[n for n in names if n and not n.startswith('.') and not n.startswith('/')]
assert named, 'db needs a named volume (not a bind mount)'
top=c.get('volumes') or {}
assert any(n in top for n in named), 'the named volume must be declared under top-level volumes:'
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "web publishes 3000 and api publishes 8080" {
  run py "
import yaml,os
c=yaml.safe_load(open(os.environ['COMPOSE']))
def ports(s): return [str(p) for p in (c['services'][s].get('ports') or [])]
assert any('3000' in p for p in ports('web')), 'web must publish 3000'
assert any('8080' in p for p in ports('api')), 'api must publish 8080'
print('ok')
"
  [ "$status" -eq 0 ]
}
