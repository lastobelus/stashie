#!/usr/bin/env bats

@test "stashie-func.zsh runs and echoes ready" {
  run zsh shell/stashie-func.zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"sourced core and ready"* ]]
}