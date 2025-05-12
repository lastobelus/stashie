#!/usr/bin/env bash
# install-dev.sh
# Prepends stashie-shell's bin directory to the PATH for the current shell session.

# Check if script is being sourced
(return 0 2>/dev/null)
# shellcheck disable=SC2181
if [[ $? -ne 0 ]]; then
    echo "⚠️  Please run this script with: source install/install-dev.sh"
    echo "   (Otherwise, PATH changes will not persist in your shell.)"
    exit 1
fi

project_root=$(git rev-parse --show-toplevel 2>/dev/null || "$(pwd)")
bin_path="${project_root}/stashie-shell/shell/bin"

export PATH="${bin_path}:$PATH"
echo "✅ Dev install active. stashie-cli and related tools now available in this shell."
