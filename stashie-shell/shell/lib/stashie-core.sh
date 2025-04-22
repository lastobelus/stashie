#!/usr/bin/env bash

choose_file() {
  ${FZF_CMD:-fzf} --preview="stashie-fzf-preview {}" --query="${1:-}" --prompt="Select artifact: "
}
export -f choose_file

choose_dir() {
  ${FZF_CMD:-fzf} --preview="tree -C {}" --query="${1:-}" --prompt="Select destination directory: "
}
export -f choose_dir

process_artifact() {
  local file="$1"
  local dest="$2"
  local delete_after="$3"
  local debug="$4"
  local archive_dir=~/Downloads/old-artifacts

  mkdir -p "${dest}"
  if [[ "${debug}" == true ]]; then
    echo "[DEBUG] Would copy ${file} to ${dest}"
  else
    cp "${file}" "${dest}/"
    echo "Copied ${file} to ${dest}/"
    if [[ "${delete_after}" == true ]]; then
      rm -f "${file}"
      echo "Deleted ${file}"
    else
      mkdir -p "${archive_dir}"
      mv "${file}" "${archive_dir}/"
      echo "Moved ${file} to ${archive_dir}/"
    fi
  fi
}
export -f process_artifact

hello_world() {
  local pong="$1"
  echo "stashie-core hello world ${pong}"
}
export -f hello_world
