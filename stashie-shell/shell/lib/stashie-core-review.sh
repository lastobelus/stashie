#!/usr/bin/env bash

# stashie-core-review.sh
# Core review-related logic for stashie-review and related tools

set -uo pipefail

get_files_from_zip() {
  local zip_path="$1"
  local -n out_array="$2" # nameref to caller's variable

  if ! unzip_output=$(unzip -qql "${zip_path}" | awk '{$1=$2=$3=""; sub(/^ +/, ""); print}'); then
    echo "Error: Failed to list contents of ${zip_path}" >&2
    exit 1
  fi

  while IFS= read -r name; do
    # Skip lines that end in slash (directories)
    [[ "${name}" =~ ^.*\/$ ]] && continue
    echo "🔍 Found file:  '${name}'"
    [[ -n "${name}" ]] && out_array+=("${name}")
  done <<<"${unzip_output}"
  return 0
}
