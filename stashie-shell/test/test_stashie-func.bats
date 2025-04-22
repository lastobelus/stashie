#!/usr/bin/env bats

@test "stashie-func.zsh runs and sources core" {
  run zsh shell/stashie-func.zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"[stashie-func.zsh] sourced core and ready"* ]]
}
