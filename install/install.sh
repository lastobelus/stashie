#!/usr/bin/env bash
# install.sh
# Installs stashie-shell to a default or user-specified directory and emits a shell init snippet.

# Prevent accidental sourcing (don't ask)
if [[ "${BASH_SOURCE[0]:-}" != "${0}" ]]; then
  echo "🚫 This script should not be sourced."
  echo "    Did you mean:"
  echo "        . install/install-dev.sh"
  return 1 2>/dev/null || exit 1
fi

# Safe to set strict mode now
set -euo pipefail

############################################################################
# check for dependencies
############################################################################
# Check for Bash 4.3+
if ((BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3))); then
  echo "Error: Bash 4.3+ is required. Current version: ${BASH_VERSION}" >&2
  exit 1
fi

# Check for GNU enhanced getopt
if ! getopt --test >/dev/null; then
  echo "Error: Enhanced getopt is required (GNU version)." >&2
  echo "On macOS, try: brew install gnu-getopt" >&2
  exit 1
fi

# Check for fzf
if ! command -v fzf >/dev/null; then
  echo "Error: fzf is required. Install it with: brew install fzf" >&2
  exit 1
fi

############################################################################
# install binscripts
############################################################################

INSTALL_PREFIX="${1:-$HOME/.local/share/stashie-shell}"
mkdir -p "${INSTALL_PREFIX}/bin"

# Copy bin scripts
script_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cp -r "${script_root}/stashie-shell/shell/bin/"* "${INSTALL_PREFIX}/bin/"

############################################################################
# emit shell init snippet
############################################################################

# Shell detection
shell_name="$(basename "${SHELL:-bash}")"
rc_file=""

case "$shell_name" in
bash) rc_file="~/.bashrc" ;;
zsh) rc_file="~/.zshrc" ;;
fish) rc_file="~/.config/fish/config.fish" ;;
*) rc_file="your shell config file" ;;
esac

cat <<EOF

✅ stashie-shell installed to: ${INSTALL_PREFIX}

To make it available in future sessions, add the following line to ${rc_file}:

    export PATH="${INSTALL_PREFIX}/bin:\$PATH"

EOF
