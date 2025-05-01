#!/usr/bin/env bash
set -uo pipefail

# resolve_path
# ------------
# Tries to resolve a given path to an absolute path.
# Uses `realpath` if available, otherwise returns the input unmodified.
#
# Args:
#   $1 = path to resolve
#
# Returns:
#   Absolute path (if resolvable), or original input if `realpath` is not found
resolve_path() {
  if command -v realpath &>/dev/null; then
    realpath "$1"
  else
    # fallback: manually normalize if needed, or just return as-is
    echo "$1"
  fi
}

# fzf_pick_file
# -------------
# Lets user select a file using fzf from a specified directory.
# Uses stashie's preview shim for consistent display behavior.

fzf_pick_file() {
  local source_dir="${STASHIE_ARTIFACTS_SOURCE_DIR:-${HOME}/Downloads}"
  source_dir=$(resolve_path "${source_dir}")
  local here
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local preview_script="${here}/../bin/stashie-fzf-preview"

  [[ -d "${source_dir}" ]] || {
    echo "Error: Stashie artifact directory '${source_dir}' not found" >&2
    return 1
  }

local file_list

  if find . -maxdepth 0 -printf '' &>/dev/null; then
    # GNU find
    file_list=$(find "${source_dir}" -type f -printf '%T@ %p\\0' 2>/dev/null |
      sort -zrn | cut -z -d' ' -f2-)
  else
    # BSD/macOS fallback
    file_list=$(find "${source_dir}" -type f -print0 2>/dev/null |
      xargs -0 stat -f '%m %N' 2>/dev/null |
      sort -rn | cut -d' ' -f2- | tr '\n' '\0')
  fi

  printf "%s" "${file_list}" | \
    fzf --read0 \
    --preview="${preview_script} {}" \
    --prompt="Select artifact to retrieve: "


}

# fzf_pick_dir
# ------------
# Launches fzf for fuzzy directory selection with layered config support.
#
# Reads from:
#   - STASHIE_PICK_DIR_COMMAND   → overrides what to list (default: "find . -type d")
#   - STASHIE_PICK_DIR_OPTS      → overrides all fzf UI options
#   - FZF_ALT_C_COMMAND           → standard fzf shell fallback
#   - FZF_ALT_C_OPTS              → standard fzf shell fallback options
#   - STASHIE_FZF_DEFAULTS       → appended to fzf options (or falls back to __fzf_defaults if defined)
#   - STASHIE_FZF_CMD            → alternate runner for fzf (e.g. fzf-tmux)
#
# Behavior:
#   - Uses `__fzf_defaults` and `__fzfcmd` if available
#   - Defaults to single-selection, path scheme, and reverse layout
#   - Uses FZF_DEFAULT_OPTS and FZF_DEFAULT_COMMAND
#
# Returns:
#   - Prints selected directory to stdout
#   - Returns 1 on user cancel or directory not found
fzf_pick_dir() {
  local fzf_cmd
  local fzf_opts
  local default_command

  # 1. Baseline command and options
  default_command="${STASHIE_PICK_DIR_COMMAND:-${FZF_ALT_C_COMMAND:-find . -type d}}"
  base_opts="--reverse --walker=dir,follow,hidden --scheme=path +m"

  # 2. Let FZF_ALT_C_OPTS extend stashie's base
  combined_opts="${base_opts} ${FZF_ALT_C_OPTS:-}"

  # 3. Final stashie-specific override wins
  pick_dir_opts="${STASHIE_PICK_DIR_OPTS:-${combined_opts}}"

  # 4. FZF_DEFAULT_OPTS: stashie wins, then fallback to __fzf_defaults if present
  if [[ -n "${STASHIE_FZF_DEFAULTS:-}" ]]; then
    fzf_opts="${STASHIE_FZF_DEFAULTS} ${pick_dir_opts}"
  elif declare -F __fzf_defaults &>/dev/null; then
    fzf_opts="$(__fzf_defaults ${pick_dir_opts})"
  else
    fzf_opts="${pick_dir_opts}"
  fi

  # 5. Use fzf-tmux if present, else plain fzf
  if [[ -n "${STASHIE_FZF_CMD:-}" ]]; then
    fzf_cmd="${STASHIE_FZF_CMD}"
  elif declare -F __fzfcmd &>/dev/null; then
    fzf_cmd="$(__fzfcmd)"
  else
    fzf_cmd="fzf"
  fi

  FZF_DEFAULT_COMMAND="${default_command}" \
    FZF_DEFAULT_OPTS="${fzf_opts}" \
    FZF_DEFAULT_OPTS_FILE='' \
    ${fzf_cmd} </dev/tty
}

# require_file_selection
# ----------------------
# Ensures a file was successfully selected.
# Exits with an error message if the variable is unset, empty, or selection failed.
#
# Args:
#   $1 = name of variable (string)
#   $2 = optional debug flag ("true" to emit a debug message)

require_file_selection() {
  local var_name="${1}"
  local debug="${2:-false}"
  local value="${!var_name}"

  if [[ -z "${value}" ]]; then
    [[ "${debug}" == true ]] && echo "[DBG] No file selected: ${var_name} is empty" >&2
    exit 1
  fi
}

# stashie_preview_file
# --------------------
# Previews a file in fzf based on readability and bat availability.
# This is the underlying logic for stashie-fzf-preview.

stashie_preview_file() {
  local file="$1"

  if [[ -r "${file}" ]]; then
    if command -v bat &>/dev/null; then
      bat --style=plain --color=always "${file}"
    else
      cat "${file}"
    fi
  else
    echo "Cannot preview file: '${file}'"
    return 1
  fi
}

# process_artifact
# ---------------
# Copies or extracts a file into a destination directory, based on file extension.
# Supports: zip, tar, tar.gz, and plain file copy.
#
# Args:
#   $1 = path to the file to be processed
#   $2 = destination directory (created if necessary)
#   $3 = debug mode: true/false (if true, echo actions instead of executing)
#   $4 = delete_after: true/false (if true, deletes original; otherwise archives it)
#
# Notes:
# - Archive destination is ~/Downloads/old-artifacts
# - Errors are surfaced to stderr, and all actions are echoed for user feedback

process_artifact() {
  local file="${1}"
  local dest="${2}"
  local dbg="${3}"
  local delete_after="${4}"
  local archive_dir="${HOME}/Downloads/old-artifacts"

  mkdir -p "${dest}"

  local extension cmd
  cmd="cp" # fallback

  # Detect the correct command based on extension
  case "${file,,}" in
  *.tar.gz | *.tgz) cmd="targz" ;;
  *.tar) cmd="untar" ;;
  *.zip) cmd="unzip" ;;
  *) cmd="cp" ;;
  esac

  # Debug path
  if [[ "${dbg}" == true ]]; then
    echo "[DBG] Would ${cmd} ${file} → ${dest}"
    if [[ "${delete_after}" == true ]]; then
      echo "[DBG] Would delete $(basename "${file}") from ~/Downloads/"
    else
      echo "[DBG] Would move $(basename "${file}") from ~/Downloads to ${archive_dir}/"
    fi
    return 0
  fi

  # Execute the operation
  case "${cmd}" in
  unzip)
    unzip -q "${file}" -d "${dest}" && echo "Unzipped $(basename "${file}") to ${dest}"
    ;;
  untar)
    tar -xf "${file}" -C "${dest}" && echo "Extracted TAR $(basename "${file}") to ${dest}"
    ;;
  targz)
    tar -xzf "${file}" -C "${dest}" && echo "Extracted TAR.GZ $(basename "${file}") to ${dest}"
    ;;
  cp | *)
    cp "${file}" "${dest}/" && echo "Copied $(basename "${file}") to ${dest}/"
    ;;
  esac

  # Final disposition: delete or archive
  if [[ "${delete_after}" == true ]]; then
    rm -f "${file}" && echo "Deleted original $(basename "${file}")"
  else
    mkdir -p "${archive_dir}"
    mv "${file}" "${archive_dir}/" && echo "Moved original $(basename "${file}") to ${archive_dir}/"
  fi
}

if [[ "${STASHIE_TEST_MODE:-false}" == true ]]; then
  export -f fzf_pick_file
  export -f fzf_pick_dir
  export -f require_file_selection
  export -f stashie_preview_file
  export -f process_artifact
fi
