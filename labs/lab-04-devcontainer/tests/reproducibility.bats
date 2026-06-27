setup() {
  LAB_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export PKG="$LAB_DIR/package.json"
  export DC="$LAB_DIR/.devcontainer/devcontainer.json"
  export LOCK="$LAB_DIR/package-lock.json"
}

py() { python3 -c "$1"; }

@test "engines.node is pinned to an exact version" {
  run py "
import json,os,re
p=json.load(open(os.environ['PKG']))
n=(p.get('engines') or {}).get('node','')
n=re.sub(r'^[~^]','',n)
assert re.match(r'^\d',n), 'engines.node must be pinned to an exact version, got %r'%n
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "packageManager is pinned" {
  run py "
import json,os
p=json.load(open(os.environ['PKG']))
assert p.get('packageManager'), 'packageManager must be pinned (e.g. pnpm@9.7.0)'
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "no floating (^ or ~) dependencies" {
  run py "
import json,os
p=json.load(open(os.environ['PKG']))
bad=[k for k,v in (p.get('dependencies') or {}).items() if str(v)[:1] in '^~']
assert not bad, 'floating dependencies: '+', '.join(bad)
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "a committed lockfile exists and is valid JSON" {
  [ -f "$LOCK" ]
  run py "import json,os;json.load(open(os.environ['LOCK']));print('ok')"
  [ "$status" -eq 0 ]
}

@test "dev container image is pinned to a tag" {
  run py "
import json,os
d=json.load(open(os.environ['DC']))
img=d.get('image','')
assert ':' in img and not img.endswith(':'), 'dev container image must be pinned to a tag, got %r'%img
print('ok')
"
  [ "$status" -eq 0 ]
}

@test "dev container install is deterministic (npm ci / frozen lockfile, not npm install)" {
  run py "
import json,os,re
d=json.load(open(os.environ['DC']))
cmd=d.get('postCreateCommand','') or ''
assert re.search(r'npm ci|--frozen-lockfile',cmd), 'use npm ci (or --frozen-lockfile)'
assert not re.search(r'npm install',cmd), 'do not use npm install in the dev container'
print('ok')
"
  [ "$status" -eq 0 ]
}
