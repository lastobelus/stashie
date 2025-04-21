#!/usr/bin/env bats

@test "stashie-cli runs and echoes wrapper message" {
  run shell/bin/stashie-cli
  [ "$status" -eq 0 ]
  [[ "$output" == *"[stashie-cli] wrapper executed"* ]]
}

@test "stashie-func.zsh runs and sources core" {
  run zsh shell/stashie-func.zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"[stashie-func.zsh] sourced core and ready"* ]]
}

@test "stashie-core.sh echoes invocation message" {
  run bash shell/lib/stashie-core.sh test-arg
  [ "$status" -eq 0 ]
  [[ "$output" == *"[stashie-core] invoked with args: test-arg"* ]]
}

@test "stashie-fzf-preview responds to file input" {
  run shell/bin/stashie-fzf-preview testfile.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"[stashie-fzf-preview] previewing: testfile.txt"* ]]
}
