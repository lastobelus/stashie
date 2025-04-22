#!/usr/bin/env bats

@test "stashie-fzf-preview responds to file input" {
  run shell/bin/stashie-fzf-preview testfile.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"[stashie-fzf-preview] previewing: testfile.txt"* ]]
}
