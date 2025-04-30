#!/usr/bin/env bats

setup() {
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
  load ../shell/lib/stashie-core-review.sh
  # Export the function
  export -f get_files_from_zip

  # Run the function in a subshell and capture output
  run bash -c '
    declare -a files
    get_files_from_zip "tmp/test.zip" files
    for file in "${files[@]}"; do
      echo "$file"
    done
  '

  [ "$status" -eq 0 ]
  [[ "${output}" == *file1.md* ]]
  [[ "${output}" == *file2.txt* ]]
  [[ "${output}" == *subdir/nested.md* ]]
  [[ "${output}" != *emptydir/* ]]
}
