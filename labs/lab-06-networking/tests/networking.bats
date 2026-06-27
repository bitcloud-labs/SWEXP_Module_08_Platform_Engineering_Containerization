setup() {
  LAB_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export COMPOSE="$LAB_DIR/docker-compose.yml"
}

py() { python3 -c "$1"; }

@test "backend network is internal: true" {
  run py "
import yaml,os
c=yaml.safe_load(open(os.environ['COMPOSE']))
b=(c.get('networks') or {}).get('backend') or {}
assert b.get('internal') is True, 'backend network must be internal: true'
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "db publishes no host ports and is not on the frontend network" {
  run py "
import yaml,os
c=yaml.safe_load(open(os.environ['COMPOSE']))
db=c['services']['db']
assert not (db.get('ports') or []), 'db must publish NO ports'
assert 'frontend' not in (db.get('networks') or []), 'db must not be on frontend'
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "edge (web) is published on frontend only" {
  run py "
import yaml,os
c=yaml.safe_load(open(os.environ['COMPOSE']))
web=c['services']['web']
assert any('3000' in str(p) for p in (web.get('ports') or [])), 'web must publish 3000'
assert (web.get('networks') or [])==['frontend'] or set(web.get('networks') or [])=={'frontend'}, 'web must be on frontend only'
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "reachability: web->api yes, web->db no, api->db yes" {
  run py "
import yaml,os
c=yaml.safe_load(open(os.environ['COMPOSE']))
def nets(s): return set(c['services'][s].get('networks') or [])
reach=lambda a,b: bool(nets(a) & nets(b))
assert reach('web','api'),     'web must reach api (shared frontend)'
assert not reach('web','db'),  'web must NOT reach db'
assert reach('api','db'),      'api must reach db (shared backend)'
print('ok')
"
  [ "$status" -eq 0 ]
}
