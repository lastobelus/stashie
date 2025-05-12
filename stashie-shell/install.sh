#!/usr/bin/env bash

echo '[install.sh] Checking dependencies...'
if ! command -v fzf >/dev/null 2>&1; then
  echo 'Error: fzf is not installed. Please install it before continuing.'
  exit 1
fi
echo '[install.sh] Would install stashie-func, stashie-cli, stashie-fzf-preview...'
# Sections for: bin install, preview setup, rc template, man page, etc.
