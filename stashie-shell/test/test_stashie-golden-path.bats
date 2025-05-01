#!/usr/bin/env bats

setup() {
  source ./shell/lib/stashie-core.sh

  mkdir -p tmp src dest
  echo "hello world" >src/hello.txt

  fzf_pick_file() {
    echo "$(pwd)/src/hello.txt"
    return 0
  }

  fzf_pick_dir() {
    echo "$(pwd)/dest"
    return 0
  }

  export -f fzf_pick_file
  export -f fzf_pick_dir
}

teardown() {
  rm -rf tmp src dest
}

@test "stashie-cli copies selected file to selected destination" {
  file=$(fzf_pick_file)
  require_file_selection file true
  dest=$(fzf_pick_dir)
  require_file_selection dest true

  run process_artifact "$file" "$dest" true false

  [ "$status" -eq 0 ]
  [[ "$output" == *"Would cp"* ]]
}
