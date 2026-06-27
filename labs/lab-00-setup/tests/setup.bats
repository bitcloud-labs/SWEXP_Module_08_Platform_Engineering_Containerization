setup() {
  LAB_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  CFG="$LAB_DIR/config.yml"
  DOCKERFILE="$LAB_DIR/Dockerfile"
}

# ---- config.yml ----

@test "config.yml parses as YAML and declares service: forge-api" {
  run python3 -c "
import yaml,sys
c=yaml.safe_load(open('$CFG'))
assert isinstance(c,dict), 'config is not a mapping'
assert c.get('service')=='forge-api', 'service must be forge-api, got %r'%c.get('service')
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "config.yml port is a positive integer" {
  run python3 -c "
import yaml
c=yaml.safe_load(open('$CFG'))
p=c.get('port')
assert isinstance(p,int) and p>0, 'port must be a positive integer, got %r'%p
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "config.yml replicas is an integer >= 1" {
  run python3 -c "
import yaml
c=yaml.safe_load(open('$CFG'))
r=c.get('replicas')
assert isinstance(r,int) and r>=1, 'replicas must be an integer >= 1, got %r'%r
print('ok')
"
  [ "$status" -eq 0 ]
}

# ---- Dockerfile lint ----

@test "Dockerfile has a FROM with a pinned (non-:latest, non-untagged) base" {
  run grep -Eiq '^[[:space:]]*FROM[[:space:]]+[^[:space:]]+:[^[:space:]]+' "$DOCKERFILE"
  [ "$status" -eq 0 ]
  run grep -Eiq '^[[:space:]]*FROM[[:space:]]+\S+:latest' "$DOCKERFILE"
  [ "$status" -ne 0 ]
}

@test "Dockerfile runs as a non-root USER" {
  # must declare a USER, and that USER must not be root
  run bash -c "grep -Eiq '^[[:space:]]*USER[[:space:]]+\S+' '$DOCKERFILE' && ! grep -Eiq '^[[:space:]]*USER[[:space:]]+root([[:space:]]|\$)' '$DOCKERFILE'"
  [ "$status" -eq 0 ]
}

@test "Dockerfile declares a HEALTHCHECK" {
  run grep -Eiq '^[[:space:]]*HEALTHCHECK[[:space:]]' "$DOCKERFILE"
  [ "$status" -eq 0 ]
}
