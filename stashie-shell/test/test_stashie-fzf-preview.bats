#!/usr/bin/env bats

setup() {
  mkdir -p tmp
  echo "test content" >tmp/test.txt
}

teardown() {
  rm -rf tmp dest
}

@test "stashie-fzf-preview responds to file input" {
  echo "hello" >tmp/test.txt
  run shell/bin/stashie-fzf-preview test.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"hello"* ]]
}
