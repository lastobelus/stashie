#!/usr/bin/env bats

@test "stashie-fzf-preview echoes input" {
  run shell/bin/stashie-fzf-preview testfile.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"previewing: testfile.txt"* ]]
}