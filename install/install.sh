#!/usr/bin/env bash
# install.sh
# Installs stashie-shell to a default or user-specified directory and emits a shell init snippet.

set -euo pipefail

INSTALL_PREFIX="${1:-$HOME/.local/share/stashie-shell}"
mkdir -p "${INSTALL_PREFIX}/bin"

# Copy bin scripts
script_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cp -r "${script_root}/stashie-shell/shell/bin/"* "${INSTALL_PREFIX}/bin/"

# Shell detection
shell_name="$(basename "${SHELL:-bash}")"
rc_file=""

case "$shell_name" in
  bash) rc_file="~/.bashrc" ;;
  zsh)  rc_file="~/.zshrc" ;;
  fish) rc_file="~/.config/fish/config.fish" ;;
  *)    rc_file="your shell config file" ;;
esac

cat <<EOF

✅ stashie-shell installed to: ${INSTALL_PREFIX}

To make it available in future sessions, add the following line to ${rc_file}:

    export PATH="${INSTALL_PREFIX}/bin:\$PATH"

EOF
