#!/usr/bin/env bats

@test "stashie-cli executes and invokes core" {
  run shell/bin/stashie-cli arg1 arg2
  [ "$status" -eq 0 ]
  [[ "$output" == *"wrapper executed"* ]]
  [[ "$output" == *"stashie-core"*"arg1 arg2"* ]]
}