# 📚 Stashie Project Index (April 2025)

---

## 🧱 Project Setup

- Defined project roots:
  - `stashie-shell/` for shell-based utilities
  - `stashie-shell/shell/bin/`, `stashie-shell/shell/lib/`, `stashie-shell/test/`
- Chose Elixir + Shell + minimal external dependencies for layered functionality
- Established **stashie "onion layers"** document to guide future expansion
- Agreed to SC2250, SC2086, and clean shell practices for all new scripts

---

## 🛠 Initial Core Tools

- **get-artifact**: select and extract recent downloads with fzf preview
- **stashie-review**: fzf-driven review and accept/mark flow for added artifacts
- **stashie-context**: zip up project state for ChatGPT collaboration (`context-for-chat*.zip` convention)

---

## ⚙️ Configuration System

- Created `stashie.rc` spec
- Loaded global rc from `~/.config/stashie/`
- Walked upward `.stashie.rc` from `$PWD` to `$HOME` (only if inside HOME)
- Allowed configuration of:
  - `EDITOR`
  - `ARTIFACT_DEST_DIR`
  - `ARCHIVE_MODE`
  - `REVIEW_MODE`
  - `CONTEXT_DEST_DIR`
  - `CONTEXT_FILENAME`
  - `CONTEXT_FOCUS_APP`

---

## 🔥 Automation and Dev Workflow

- Setup Justfile for running tests and linting
- Confirmed ShellCheck clean with strict settings
- Configured Bats-core testing for bash/zsh shell tools
- Organized tests with clear banners inside `.bats` files
- Manual vs automated rc loading clarified (favor automated rc preloading for standalone scripts)

---

## 🧠 Process and Collaboration Improvements

- Adopted **Todo Dump** process to track unfinished microtasks
- Integrated consistent shell quoting, safety, and rc override behaviors
- Introduced use of `context-for-chat` uploads as project sync snapshots
- Established rules for critical zip packaging behaviors (no extra nesting; project-root structure)
- Scoped blog seed ideas for future (e.g., flow improvement via stashie ecosystem)

---

# 🏁 Status Summary

| Layer | Status | Notes |
|------|--------|-------|
| `get-artifact` | MVP working | needs safe cancel improvements |
| `stashie-review` | MVP working | pending enhancements (log, open markdown) |
| `stashie-context` | Working | SC2250/2086 compliant |
| Onion Layers Doc | Completed | acts as vision guide |