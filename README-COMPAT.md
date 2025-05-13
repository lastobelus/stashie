# Compatibility Work Track

The `feat/compat-layer` branch is dedicated to improving Stashie's portability and cross-platform support. Work tracked here focuses on ensuring Darwin and Linux environments both support:

- Shell-based CLI tools
- GitHub Actions CI runs
- Interactive features (e.g. fzf behavior)

## Milestone: [`darwin-linux-portable`](https://github.com/lastobelus/stashie/milestone/1)

This milestone tracks user-facing improvements to ensure consistent operation across macOS and Linux.

## Development Rules

- All non-WIP commits must be rebased on `main` before merging.
- CI scripts in `.github/workflows/` may diverge from `main` while testing platform fixes.
- PRs to this branch should be labeled `compatibility`.

## Usage

To contribute or test portability work:

```bash
git fetch origin
git switch feature_compat-layer
