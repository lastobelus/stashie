#!/usr/bin/env bats

setup() {
  export PATH="test/mocks:$PATH"
  export FZF_CMD="fzf"
  source shell/lib/stashie-core.sh
}


############################################################################
# tests for choose_file()
############################################################################

@test "choose_file uses mock fzf result" {
  export MOCK_FZF_RESULT="~/Downloads/testfile.zip"
  run choose_file
  [ "$status" -eq 0 ]
  [[ "$output" == *"testfile.zip"* ]]
}


############################################################################
# tests for choose_dir()
############################################################################

@test "choose_dir uses mock fzf result" {
  export MOCK_FZF_RESULT="./"
  run choose_dir
  [ "$status" -eq 0 ]
  [[ "$output" == *"./"* ]]
}


############################################################################
# tests for process_artifact()
############################################################################

@test "process_artifact copies and archives file in debug mode" {
  run process_artifact "example.txt" "/tmp" false true
  [ "$status" -eq 0 ]
  [[ "$output" == *"Would copy example.txt to /tmp"* ]]
}
