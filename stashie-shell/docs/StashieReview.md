# 🧾 stashie-review\.md

## Overview

`stashie-review` is one of the core utilities in `stashie-shell`. It provides a lightweight, interactive review layer for handling recent artifacts — particularly markdown or code files — generated through ChatGPT or related tools.

The review process is driven by `fzf`, and is intended to reduce context-switching while supporting workflows like acceptance, labeling, cleanup, and potential markdown augmentation.

---

## ✅ MVP Behavior (Implemented)

- Launches `fzf` to browse candidate files (e.g. recent markdown files in the staging area)
- Previews file content inline using `fzf` preview
- Accepts user selection
- Performs a final action, e.g., moving or renaming the file for downstream use

---

## 📌 Planned Enhancements

### 📝 Logging

- Record accepted items to a `review.log` or similar
- Track file origin, selection time, and optional labels

### 🧠 Smart Actions

- Add support for contextual follow-up (e.g. open file in editor after selection)
- Possibility of marking files for deletion, archiving, or deferred review

### 🔍 Markdown-Aware Extensions

- Optional: scan accepted files for `# NEXT:` or TODO-like blocks
- Prompt user on exit to revisit incomplete files

---

## 🔧 Configuration (Planned)

Integrated with `.stashie.rc`:

- `REVIEW_MODE` — toggle interactive vs. passive review
- `EDITOR` — default editor for post-review actions

---

## 🧠 Design Notes

- Meant to be fast and frictionless — do not overbuild
- Inspired by `tig` and git interactive workflows, but optimized for AI-generated file flow
- Should integrate cleanly with `get-artifact` and `stashie-context` as a next step in the pipeline

---

## 📎 Related Ideas

- Hook reviewed files into `stashie-context` if marked important
- Stash-reviewed markdown could optionally receive an auto-generated summary or frontmatter
- Could support tagging (e.g., `ventr`, `PSA`, `blog`) for later filtering


## ✅ TODO

- [ ] non-interactive mode: stashie-review should accept a --no-interactive flag that skips the fzf part and just emits the markdown file
- [ ] open markdown file: stashie should automatically open the list of changes in VSCode
- [ ] respect $EDITOR:
- [ ] test coverage
- [ ] log reviewed files: optional audit log of which files were marked reviewed, when, and with what mode
- [ ] configurable markdown path: allow stashie-review to write markdown somewhere other than project root

