setup() {
  LAB_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  DF="$LAB_DIR/Dockerfile"
  DI="$LAB_DIR/.dockerignore"
  GREET="$LAB_DIR/greeting"
}

# ---- Dockerfile static lint ----

@test "base image is pinned (not :latest, not untagged)" {
  run grep -Eiq '^[[:space:]]*FROM[[:space:]]+\S+:\S+' "$DF"
  [ "$status" -eq 0 ]
  run grep -Eiq '^[[:space:]]*FROM[[:space:]]+\S+:latest' "$DF"
  [ "$status" -ne 0 ]
}

@test "deps are installed deterministically with npm ci (not npm install)" {
  run grep -Eiq 'npm[[:space:]]+ci' "$DF"
  [ "$status" -eq 0 ]
  run grep -Eiq 'npm[[:space:]]+install' "$DF"
  [ "$status" -ne 0 ]
}

@test "layers are cache-ordered: package*.json copied before the full source COPY" {
  # line number of `COPY package*.json` must be < line number of `COPY . .`
  pkgln="$(grep -nEi '^[[:space:]]*COPY[[:space:]]+package\*?\.json' "$DF" | head -1 | cut -d: -f1)"
  srcln="$(grep -nEi '^[[:space:]]*COPY[[:space:]]+\.[[:space:]]+\.' "$DF" | head -1 | cut -d: -f1)"
  [ -n "$pkgln" ]
  [ -n "$srcln" ]
  [ "$pkgln" -lt "$srcln" ]
}

@test "runs as a non-root USER" {
  run bash -c "grep -Eiq '^[[:space:]]*USER[[:space:]]+\S+' '$DF' && ! grep -Eiq '^[[:space:]]*USER[[:space:]]+root([[:space:]]|\$)' '$DF'"
  [ "$status" -eq 0 ]
}

@test "declares a HEALTHCHECK" {
  run grep -Eiq '^[[:space:]]*HEALTHCHECK[[:space:]]' "$DF"
  [ "$status" -eq 0 ]
}

@test "no secrets baked in via ENV/ARG" {
  run grep -Eiq '^[[:space:]]*(ENV|ARG)[[:space:]].*(PASSWORD|SECRET|TOKEN|API_?KEY)' "$DF"
  [ "$status" -ne 0 ]
}

# ---- .dockerignore static lint ----

@test ".dockerignore excludes node_modules, .git, .env and logs" {
  run grep -Eq '(^|/)node_modules/?[[:space:]]*$' "$DI"; [ "$status" -eq 0 ]
  run grep -Eq '(^|/)\.git/?[[:space:]]*$' "$DI";        [ "$status" -eq 0 ]
  run grep -Eq '(^|/)\.env[[:space:]]*$' "$DI";          [ "$status" -eq 0 ]
  run grep -Eq '\*\.log[[:space:]]*$' "$DI";             [ "$status" -eq 0 ]
}

# ---- ONE real build: the tiny greeting image must build and print forge-up ----

@test "greeting image builds and prints forge-up" {
  command -v docker >/dev/null 2>&1 || { echo "docker not available"; return 1; }
  tag="forge-lab02-$$-$RANDOM"
  run docker build -q -t "$tag" "$GREET"
  if [ "$status" -ne 0 ]; then echo "build failed: $output"; return 1; fi
  run docker run --rm "$tag"
  docker rmi -f "$tag" >/dev/null 2>&1 || true
  [ "$status" -eq 0 ]
  echo "$output" | grep -qx 'forge-up'
}
