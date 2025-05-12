# Justfile for stashie

set shell := ["bash", "-cu"]

check-deps:
  #!/usr/bin/env sh
  if ! command -v fzf >/dev/null; then
    echo "Missing dependency: fzf" >&2
    exit 1
  fi
  if ! command -v bats >/dev/null; then
    echo "Missing dependency: bats" >&2
    exit 1
  fi
  if ! command -v shellcheck >/dev/null; then
    echo "Missing dependency: shellcheck" >&2
    exit 1
  fi


# Run bats tests
tests:
  cd stashie-shell && bats test

test-verbose:
  cd stashie-shell && bats --verbose-run test

# Watch tests (requires entr)
watch-test:
  ./stashie-shell/test/watch.sh

# Lint shell scripts
lint:
  cd stashie-shell && shellcheck shell/bin/* shell/**/*.sh

# Format shell scripts
format:
  cd stashie-shell && shfmt -w shell/bin/* shell/**/*.sh

