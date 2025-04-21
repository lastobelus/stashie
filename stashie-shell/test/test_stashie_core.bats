#!/usr/bin/env bats

@test "stashie-core echoes args" {
  run bash shell/lib/stashie-core.sh test1 test2
  echo "output: $output"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[stashie-core] invoked"* ]]
  [[ "$output" == *"test1 test2"* ]]
}
