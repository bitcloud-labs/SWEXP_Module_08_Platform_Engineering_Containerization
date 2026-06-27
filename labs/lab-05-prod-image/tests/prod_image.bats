setup() {
  LAB_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  DF="$LAB_DIR/Dockerfile"
}

@test "is multi-stage: a named build stage and a second FROM" {
  # a build stage: FROM ... AS build
  run grep -Eiq '^[[:space:]]*FROM[[:space:]]+\S+[[:space:]]+AS[[:space:]]+\S+' "$DF"
  [ "$status" -eq 0 ]
  # at least two FROM instructions
  n="$(grep -Eci '^[[:space:]]*FROM[[:space:]]' "$DF")"
  [ "$n" -ge 2 ]
}

@test "uses a pinned, non-:latest base" {
  run grep -Eiq '^[[:space:]]*FROM[[:space:]]+\S+:\S+' "$DF"
  [ "$status" -eq 0 ]
  run grep -Eiq '^[[:space:]]*FROM[[:space:]]+\S+:latest' "$DF"
  [ "$status" -ne 0 ]
}

@test "installs production-only deps (--omit=dev or NODE_ENV=production)" {
  run grep -Eiq '(npm[[:space:]]+ci[[:space:]].*--omit=dev|--production|NODE_ENV[[:space:]]*=?[[:space:]]*production)' "$DF"
  [ "$status" -eq 0 ]
}

@test "copies only the built artifact from the build stage (COPY --from=build)" {
  run grep -Eiq '^[[:space:]]*COPY[[:space:]]+--from=build' "$DF"
  [ "$status" -eq 0 ]
}

@test "runs as a non-root USER" {
  run bash -c "grep -Eiq '^[[:space:]]*USER[[:space:]]+\S+' '$DF' && ! grep -Eiq '^[[:space:]]*USER[[:space:]]+root([[:space:]]|\$)' '$DF'"
  [ "$status" -eq 0 ]
}

@test "declares a HEALTHCHECK" {
  run grep -Eiq '^[[:space:]]*HEALTHCHECK[[:space:]]' "$DF"
  [ "$status" -eq 0 ]
}

@test "bakes no secrets via ENV/ARG" {
  run grep -Eiq '^[[:space:]]*(ENV|ARG)[[:space:]].*(PASSWORD|SECRET|TOKEN|API_?KEY)' "$DF"
  [ "$status" -ne 0 ]
}
