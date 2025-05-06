#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

@test "raise_with_help outputs title on first line" {
  run env STASHIE_TEST_MODE=true bash -c '
    source ./shell/lib/stashie-core.sh
    raise_with_help "Oops" "Something went wrong."
  '

  [ "$status" -eq 1 ]
  assert_line --index 0 "❌ Oops"
}

@test "raise_with_help includes the message" {
  run env STASHIE_TEST_MODE=true bash -c '
    source ./shell/lib/stashie-core.sh
    raise_with_help "Oops" "This is the detail message."
  '
  assert_output --partial "This is the detail message."
}

@test "raise_with_help exits with custom code" {
  run env STASHIE_TEST_MODE=true bash -c '
    source ./shell/lib/stashie-core.sh
    raise_with_help "Canceled" "User aborted." 130
  '
  [ "$status" -eq 130 ]
}
