#!/usr/bin/env bash

# stashie-core-review.sh
# Core review-related logic for stashie-review and related tools

set -uo pipefail

# Extracts file names from a ZIP archive
#
# Args:
#   $1: Path to the ZIP file
#   $2: Nameref to an output array to store file names
#
# Returns:
#   0 on success, 1 on failure
#
# Skips directories
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
    [[ -n "${name}" ]] && out_array+=("${name}")
  done <<<"${unzip_output}"
  return 0
}

# Creates a markdown report of files that need review
# Args:
#   $1: Array of all files to potentially review
#   $2: Array of files that have been reviewed/selected
#   $3: Output markdown file path (optional)
function create_review_report() {
  local -n all_files=$1
  local -n reviewed_files=$2
  local md_file="${3:-}"

  # If no output file specified, create one in project root
  if [[ -z "${md_file}" ]]; then
    local project_root
    project_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    md_file="${project_root}/stashie-review.md"
  fi

  printf "### Files Needing Review\n\n" >"${md_file}"

  for file in "${all_files[@]}"; do
    [[ -z "${file}" ]] && continue
    skip=false
    for sel in "${reviewed_files[@]}"; do
      [[ -z "${sel}" ]] && continue
      if [[ "${file}" == "${sel}" ]]; then
        skip=true
        break
      fi
    done
    if [[ "${skip}" == false ]]; then
      printf -- "- [ ] [%s](%s)\n" "${file}" "${file}" >>"${md_file}"
    fi
  done

  echo "📝 Created ${md_file}"
  return 0
}
