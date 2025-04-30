#!/usr/bin/env bats

############################################################################
# Tests for get_files_from_zip function
############################################################################

setup() {
  echo "setup $(pwd)"
  mkdir -p tmp/testzip/subdir
  echo "hello" >tmp/testzip/file1.md
  echo "world" >tmp/testzip/file2.txt
  echo "nested" >tmp/testzip/subdir/nested.md
  mkdir tmp/testzip/emptydir
  (cd tmp/testzip && zip -qr ../test.zip .)
}

teardown() {
  rm -rf tmp
}

@test "get_files_from_zip includes files but excludes empty directories" {
  zip_path="$(pwd)/tmp/test.zip"
  echo "$(ls -la tmp)"
  load ../shell/lib/stashie-core-review.sh
  export -f get_files_from_zip

  run env ZIP_PATH="$zip_path" bash -c '
    source ./shell/lib/stashie-core-review.sh
    declare -a files
    get_files_from_zip "$ZIP_PATH" files
    for file in "${files[@]}"; do
      echo "$file"
    done
  '

  echo "output: $output"

  [ "$status" -eq 0 ]
  [[ "${output}" == *file1.md* ]]
  [[ "${output}" == *file2.txt* ]]
  [[ "${output}" == *subdir/nested.md* ]]
  [[ "${output}" != *emptydir/* ]]
}
