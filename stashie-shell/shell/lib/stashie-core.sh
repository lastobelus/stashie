#!/usr/bin/env bash
set -uo pipefail

# -----------------------------------------------------------------------------
# 🧾 stashie configuration loader
#
# Loads user and project-specific configuration for stashie.
#
# 1. Global Config:
#    - Loads from: $HOME/.config/stashie/stashie.rc
#    - Used for persistent, system-wide preferences (e.g., preview style, colors)
#
# 2. Project-Scoped Overrides:
#    - Walks upward from $PWD toward $HOME
#    - Sources any `.stashie.rc` found along the way
#    - Allows context-specific overrides per project or subproject
#
# Notes:
# - ShellCheck SC1090 is disabled intentionally for sourced config files
# - Config variables include STASHIE_ARTIFACTS_SOURCE_DIR, STASHIE_SORT_MODE, etc.
# -----------------------------------------------------------------------------

# 1. Load global config first
global_rc="${HOME}/.config/stashie/stashie.rc"
# shellcheck disable=SC1090
[[ -f "${global_rc}" ]] && source "${global_rc}"

# 2. Walk upward from PWD to HOME and load any .stashie.rc along the way
if [[ "${PWD}" == "${HOME}"* ]]; then
  current="${PWD}"
  while [[ "${current}" != "${HOME}" && "${current}" != "/" ]]; do
    rc_file="${current}/.stashie.rc"
    if [[ -f "${rc_file}" ]]; then
      # shellcheck disable=SC1090
      source "${rc_file}"
    fi
    current="$(dirname "${current}")"
  done
fi

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

# stashie_version_string
# ----------------------
# Emits a styled version string based on detected install location.
# Uses git tags in dev mode, or reads a VERSION file in permanent installs.
#
# Args:
#   $1 = name of script (string)
#
stashie_version_string() {
  local script_name="$1"

  local here
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local version=""
  local lang="shell"
  local dev_marker=""
  local color="250"

  # Known permanent install path detection script
  local version_file="${here}/../../VERSION"

  if git -C "${here}" rev-parse &>/dev/null; then
    # in a git repo, check for recent tag
    version="$(git -C "${here}" describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")"
    dev_marker="-dev"
  elif [[ -f "${version_file}" ]]; then
    read -r version <"${version_file}"
  else
    version="0.0.0"
    dev_marker="-dev"
  fi

  case "${lang}" in
  shell) color="178" ;;
  js) color="34" ;;
  swift) color="208" ;;
  rust) color="160" ;;
  *) color="250" ;;
  esac

  echo -e "\\033[4m${script_name}   \\033[1m${version}${dev_marker}\\033[0m\\033[4m   \\033[38;5;${color}m${lang}\\033[0m"
}

# fzf_pick_file
# -------------
# Interactive file picker using fzf with fast, recent-first directory drilldown.
#
# Reads from:
#   - STASHIE_ARTIFACTS_SOURCE_DIR     → root directory to browse (default: $HOME/Downloads)
#   - STASHIE_PICK_FILE_LIST_COMMAND   → listing command per directory (default: "ls -1t")
#   - STASHIE_PICK_FILE_RECURSIVE      → if set to "1", allows recursive drilldown (default: "1")
#
# Behavior:
#   - Presents a sorted list of files and folders in the current directory
#   - Allows descending into subdirectories (unless recursion disabled)
#   - Includes a ".." entry for going back up
#   - Uses stashie-fzf-preview for live preview of each entry
#   - Cleanly handles Ctrl-C and empty selection
#
# Returns:
#   - Echoes the selected file path to stdout
#   - Exits with:
#       0 → file selected
#       1 → no selection
#     130 → user pressed Ctrl-C

fzf_pick_file() {
  local source_dir="${STASHIE_ARTIFACTS_SOURCE_DIR:-${HOME}/Downloads}"
  local list_cmd="${STASHIE_PICK_FILE_LIST_COMMAND:-ls -1t}"
  local recursive="${STASHIE_PICK_FILE_RECURSIVE:-1}"
  local here
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local preview_script="${here}/../bin/stashie-fzf-preview"

  source_dir=$(resolve_path "${source_dir}")
  [[ -d "${source_dir}" ]] || {
    echo "Error: Source directory '${source_dir}' not found." >&2
    return 1
  }

  local current_dir="${source_dir}"
  local selected

  while true; do
    local list_output
    if ! list_output=$(eval "${list_cmd} \"${current_dir}\"" 2>/dev/null); then
      echo "Error: Failed to list files in ${current_dir}" >&2
      return 1
    fi

    local entries=()

    # Add synthetic ".." entry if not at root
    if [[ "${current_dir}" != "${source_dir}" ]]; then
      entries+=("..")
    fi

    # Populate entries array safely
    while IFS= read -r entry; do
      entries+=("${entry}")
    done <<<"${list_output}"

    # Run fzf
    selected=$(printf "%s\n" "${entries[@]}" |
      fzf --ansi --preview="${preview_script} ${current_dir}/{}" \
        --prompt="Pick file in: ${current_dir} → ")

    if [[ $? -eq 130 ]]; then
      return 130
    elif [[ -z "${selected}" ]]; then
      return 1
    fi

    local full_path="${current_dir}/${selected}"

    if [[ "${selected}" == ".." ]]; then
      current_dir=$(dirname "${current_dir}")
    elif [[ -d "${full_path}" ]]; then
      if [[ "${recursive}" = "1" ]]; then
        current_dir="${full_path}"
      else
        echo "${full_path}"
        return
      fi
    else
      echo "${full_path}"
      return
    fi
  done
}

# fzf_pick_dir
# ------------
# Interactive directory picker using fzf, with preview and artifact-aware help.
#
# Reads from:
#   - STASHIE_PICK_DIR_COMMAND         → directory listing command (default: "find . -type d")
#   - STASHIE_PICK_DIR_OPTS            → fzf layout and UI options (default: reverse walker + path scheme)
#   - STASHIE_FZF_DEFAULTS             → overrides all fzf options if set
#   - STASHIE_PICK_DIR_PREVIEW_CMD     → preview command (default: "tree -C {}")
#
# Behavior:
#   - Displays artifact filename in header
#   - Binds <Ctrl-P> to preview the selected artifact (via stashie-fzf-preview)
#   - Includes prompt to cancel with Ctrl-C
#   - Exits with:
#       0 → directory selected
#       1 → no selection
#     130 → user pressed Ctrl-C
#
# Returns:
#   - Echoes selected directory to stdout
fzf_pick_dir() {
  local artifact_file="$1"
  local default_command="${STASHIE_PICK_DIR_COMMAND:-find . -type d}"
  local preview_cmd="${STASHIE_PICK_DIR_PREVIEW_CMD:-tree -C {}}"
  local base_opts="--reverse --walker=dir,follow,hidden --scheme=path +m"
  local pick_dir_opts="${STASHIE_PICK_DIR_OPTS:-${base_opts}}"
  local fzf_opts="${STASHIE_FZF_DEFAULTS:-} ${pick_dir_opts}"

  local fzf_cmd="fzf"

  local selected_dir
  selected_dir=$(
    FZF_DEFAULT_COMMAND="${default_command}" \
      FZF_DEFAULT_OPTS="${fzf_opts}" \
      FZF_DEFAULT_OPTS_FILE='' \
      ${fzf_cmd} \
      --prompt="Select destination → " \
      --preview="${preview_cmd}" \
      --header="📄 Selected file: $(basename "${artifact_file}")"$'\n'"Press Ctrl-P to preview it | Ctrl-C to cancel" \
      --bind "ctrl-p:execute((stashie-fzf-preview '${artifact_file}'; echo; echo '[press q to return]') | less -R)+refresh-preview" \
      </dev/tty
  )

  if [[ $? -eq 130 ]]; then
    return 130
  elif [[ -z "${selected_dir}" ]]; then
    return 1
  else
    echo "${selected_dir}"
  fi
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
# Previews a file or directory in a color-friendly, terminal-safe way.
#
# Behavior:
#   - For directories:
#       - Uses `eza --tree -L 1` if available
#       - Falls back to `tree -L 1 -C`, or plain `ls -1`
#   - For readable files:
#       - Uses `bat --style=plain --color=always` if available
#       - Falls back to `cat`
#   - For archives:
#       - .zip     → uses `unzip -l`
#       - .tar*    → uses `tar -tf`
#   - For non-readable files:
#       - Displays a clear "Cannot preview file" message
#
# Notes:
#   - Intended for use with `fzf --preview`, but safe in standalone CLI
#   - Will not attempt image previews or special formatting beyond ANSI color

stashie_preview_file() {
  local file="$1"

  if [[ -d "${file}" ]]; then
    if command -v eza &>/dev/null; then
      eza --color=always --tree -L 1 "${file}"
    elif command -v tree &>/dev/null; then
      tree -L 1 -C "${file}"
    else
      echo "📁 Directory: ${file}"
      ls -1 "${file}"
    fi
    return
  fi

  if [[ ! -r "${file}" ]]; then
    echo "Cannot preview file: '${file}'"
    return 1
  fi

  case "${file}" in
  *.zip)
    unzip -l "${file}"
    ;;
  *.tar | *.tar.gz | *.tgz)
    tar -tf "${file}"
    ;;
  *.jpg | *.jpeg | *.png | *.gif | *.bmp | *.webp)
    if [[ -t 1 ]] && command -v imgcat &>/dev/null; then
      imgcat "${file}"
    else
      echo "🖼️ Image preview (imgcat) not available for '${file}'"
    fi
    ;;
  *)
    if command -v bat &>/dev/null; then
      bat --style=plain --color=always "${file}"
    else
      cat "${file}"
    fi
    ;;
  esac
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
