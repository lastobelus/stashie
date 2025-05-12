#!/usr/bin/env bats

setup() {
  mkdir -p tmp
  echo "test content" >tmp/sample.txt
  echo "test content" >tmp/sample.zip
  echo "test content" >tmp/sample.tar
  echo "test content" >tmp/sample.tar.gz
}

teardown() {
  rm -rf tmp dest
}

@test "process_artifact detects and copies .txt" {
  run env STASHIE_TEST_MODE=true bash -c '
    source ./shell/lib/stashie-core.sh
    process_artifact tmp/sample.txt dest true false
  '
  [[ "$output" == *"[DBG] Would cp"* ]]
}

@test "process_artifact detects and unzips .zip" {
  run env STASHIE_TEST_MODE=true bash -c '
    source ./shell/lib/stashie-core.sh
    process_artifact tmp/sample.zip dest true false
  '
  [[ "$output" == *"[DBG] Would unzip"* ]]
}

@test "process_artifact detects and untars .tar" {
  run env STASHIE_TEST_MODE=true bash -c '
    source ./shell/lib/stashie-core.sh
    process_artifact tmp/sample.tar dest true false
  '
  [[ "$output" == *"[DBG] Would untar"* ]]
}

@test "process_artifact detects and untars .tar.gz" {
  run env STASHIE_TEST_MODE=true bash -c '
    source ./shell/lib/stashie-core.sh
    process_artifact tmp/sample.tar.gz dest true false
  '
  echo "output: $output"
  [[ "$output" == *"[DBG] Would targz"* ]]
}
