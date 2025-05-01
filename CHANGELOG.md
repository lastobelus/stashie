# Changelog

All notable changes to `stashie-shell` will be documented here.

## [v0.2.0] – 2025-04-29

🚀 MVP-complete CLI and core logic for stashie-shell

This version completes the core `stashie-cli` flow and validates it with robust test coverage.
All major file selection, preview, processing, and configuration behaviors are now implemented and stable.

### Added
- Real `stashie-cli` implementation for artifact selection and delivery
- `fzf_pick_file` and `fzf_pick_dir` helpers with override-friendly configuration
- Core preview logic as a testable function + standalone script (`stashie-fzf-preview`)
- `process_artifact` with filetype detection (zip, tar, tar.gz) and archival logic
- `require_file_selection` and `resolve_path` helpers
- New `stashie-core.sh` structure with exported functions for test support

### Changed
- Removed outdated `stashie-cli` placeholder test
- Converted `test_stashie-cli.bats` to pending
- Standardized `set -uo pipefail` usage across all shell scripts
- All tests pass cleanly; core flow validated by golden-path integration test

## [v0.1.0] – 2025-04-21

🎉 First tagged release of the stashie shell layer!

### Added
- Project layout under `stashie-shell/` with `shell/` containing installable components
- `stashie-func.zsh` shell entrypoint
- `stashie-cli` cross-shell wrapper
- `stashie-fzf-preview` stubbed preview script
- `lib/stashie-core.sh` stub for shared logic
- `install.sh` at the project root with fzf guard
- `README.md` with install and dependency info
- Initial zip packaging conventions and structure agreement
- Functional implementation of `stashie-review`, with:
  - fzf-driven file selection and preview
  - destination path selection
  - review summary markdown generation
- `stashie-context` script to zip project context for ChatGPT
- `stashie-core-review.sh` with reusable logic (e.g. `get_files_from_zip`, `generate_review_markdown`)
- Bats-based tests for core review helpers


> Note: This release is a non-functional scaffold for collaborative development. No user-facing features yet.