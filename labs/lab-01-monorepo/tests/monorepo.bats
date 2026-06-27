setup() {
  LAB_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  SOL="$LAB_DIR/solution.sh"
  FIX="$LAB_DIR/fixtures"
}

@test "the correct graph reports no violations" {
  run bash "$SOL" "$FIX/good.deps"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "a package depending on an app is flagged as a boundary violation" {
  run bash "$SOL" "$FIX/bad-direction.deps"
  [ "$status" -eq 0 ]
  echo "$output" | grep -qi 'boundary'
}

@test "the bad-direction graph is not silently accepted" {
  run bash "$SOL" "$FIX/bad-direction.deps"
  [ -n "$output" ]
}

@test "a two-node cycle is detected" {
  run bash "$SOL" "$FIX/cycle.deps"
  [ "$status" -eq 0 ]
  echo "$output" | grep -qi 'cycle'
}

@test "the correct graph is not falsely flagged with a cycle" {
  run bash "$SOL" "$FIX/good.deps"
  ! echo "$output" | grep -qi 'cycle'
}
