#!/usr/bin/env bats

@test "stashie-cli executes and invokes core" {
  run shell/bin/stashie-cli arg1 arg2
  [ "$status" -eq 0 ]
  echo "output: $output"
  [[ "$output" == *"core hello_world: stashie-core hello world pong"* ]]
  [[ "$output" == *"cli executed"* ]]
}
