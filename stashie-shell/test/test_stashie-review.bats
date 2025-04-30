#!/usr/bin/env bats

@test "prints usage when no files to review" {
  run shell/bin/stashie-review

  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: stashie-review [OPTIONS] [FILES...]"* ]]
}
