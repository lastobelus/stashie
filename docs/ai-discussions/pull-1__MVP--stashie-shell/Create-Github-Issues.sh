#!/usr/bin/env bash

# 0. Create milestone ----------------------------------------------------------
gh milestone create --title "v0.3.0‑portable" \
  --description "Hardening cycle: portability + CI + tests to prepare shell MVP for multi-language ports: JS, Swift, Rust"

# 1. Remove legacy Elixir scaffolding ------------------------------------------
gh issue create \
  --title "Prune remaining Elixir server scaffolding" \
  --body "
### Goal
Delete obsolete Phoenix/Elixir files and references.

### Tasks
- [ ] Inventory non‑shell files: \`git ls-files ':!:shell/*'\`
- [ ] Remove unused directories & docs
- [ ] Fix broken links in README / docs
- [ ] Confirm CI passes after deletions

### Acceptance
Repository contains only shell implementation + docs.
" \
  --label hardening-mvp \
  --milestone "v0.3.0‑portable"

# 2. Minimal CI: macOS & Linux, ShellCheck & existing Bats ----------------------
gh issue create \
  --title "Establish minimal CI matrix (macOS + Linux) with ShellCheck & current tests" \
  --body "
### Goal
Green CI gate on both platforms before further refactors.

### Tasks
- [ ] GitHub Actions workflow skeleton
- [ ] Jobs:
  * \`ubuntu-latest\`
  * \`macos-latest\`
- [ ] Steps:
  * Install deps (fzf, bats‑core, shellcheck)
  * \`shellcheck **/*.sh\`
  * \`bats test\`
  * \`./shell/bin/stashie-cli --help\`

### Acceptance
CI must pass on PRs targeting \`main\`.
" \
  --label hardening-mvp \
  --milestone "v0.3.0‑portable"

# 3. Unify error‑handling conventions + CONTRIBUTING doc -----------------------
gh issue create \
  --title "Standardise error handling & document shell coding standards" \
  --body "
### Goal
Consistent \`return/exit\`, traps, and logging across all scripts.

### Tasks
- [ ] Draft CONTRIBUTING section: error codes, trap pattern, logging levels
- [ ] CONTRIBUTING.md contains Rule -> Regex table
- [ ] Refactor functions that emit errors but return 0
- [ ] Add CI lint (grep) to catch future violations: scripts/lint-style.sh
- [ ] Add pre-commit hook to run scripts/lint-style.sh (skip WIP commits?)
- see docs/ai-discussions/pull-1__MVP—stashie-shell/CI-Lint-Guide.md for more details

### Acceptance
All scripts follow new standard; CI linter passes.
" \
  --label hardening-mvp \
  --milestone "v0.3.0‑portable"

# 4. Design & implement Darwin/Linux compat layer ------------------------------
gh issue create \
  --title "Add portable compat layer for Darwin & Linux" \
  --body "
### Goal
Abstract platform‑specific commands behind helpers.

### Must‑cover Commands
- \`open_file\` (macOS: \`open\`, Linux: \`xdg-open\`)
- \`realpath_portable\` (BSD \`readlink\` fallback)
- \`tar_extract\` (BSD/GNU flag differences)
- Color / term‑cap detection

### Tasks
- [ ] Compat helpers in \`shell/lib/compat.sh\`
- [ ] Unit tests for each helper (Bats)
- [ ] Update core scripts to use helpers
- [ ] Short RFC‑style doc describing API for future ports

### Acceptance
Scripts run on macOS & Ubuntu locally (manual smoke test) and in CI.
" \
  --label hardening-mvp \
  --milestone "v0.3.0‑portable"

# 5. Expand CI matrix + run tests under compat layer ---------------------------
gh issue create \
  --title "Expand CI matrix & run full test suite through compat layer" \
  --body "
### Goal
Verify compat layer across OSes in automated CI.

### Tasks
- [ ] Add job that sources compat layer before running tests
- [ ] Ensure color / TERM variations don't break previews (see docs/ai-discussions/pull-1__MVP—stashie-shell/Handling-TERM-Color-in-CI.md for more details)
- [ ] Store workflow artifacts (coverage, logs) for inspection

### Acceptance
CI green on all jobs; compat helpers used everywhere.
" \
  --label hardening-mvp \
  --milestone "v0.3.0‑portable"

# 6. Add edge‑case & robustness tests ------------------------------------------
gh issue create \
  --title "Add edge‑case tests: tricky filenames, corrupt zips, TERM variants" \
  --body "
### Goal
Prevent regressions on unusual inputs.

### Test Cases
- [ ] Filenames with newline, leading dash, and unicode
- [ ] Corrupt / password‑protected zip (expect graceful error)
- [ ] Large (>4 GB) archive simulated via mocked \`unzip -l\`
- [ ] Non‑color TERM to ensure preview fallback

### Acceptance
New Bats tests pass locally and in CI.
" \
  --label hardening-mvp \
  --milestone "v0.3.0‑portable"
