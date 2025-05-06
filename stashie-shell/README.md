# stashie-shell

This is the MVP implementation of Stashie — a shell-based toolkit for flow-friendly interaction with AI-generated files.

Its goal is to validate the UX and component boundaries before reimplementing in:
- 🟢 JavaScript (Bun)
- 🟠 Swift CLI
- 🔴 Rust

Eventually, one implementation may become canonical, but the shell MVP is stable and useful today.

---

## 🧱 Requirements

### To Use
- Bash 4.3+ (for associative arrays and `local -n`)
- `fzf` — interactive file picker
- gnu `getopts` (or `util-linux` ) — for parsing command-line arguments
- Recommended on macOS:
  ```sh
  brew install bash gnu-getopt fzf
  ```

### To Develop
- `just` — task runner
- `bats-core` — testing framework
- `shellcheck` — linting
- `shfmt` — formatting
- Recommended on macOS:
  ```sh
  brew install bash fzf just bats-core shellcheck shfmt
  ```

---

## 🧠 What is a "stash"?

A stash is a zip file containing one or more project files you want to send to ChatGPT for review or modification.

The stash includes enough context for the assistant to understand file layout, relationships, and intent. It's often used to:
- Share implementation code with accompanying helper modules
- Group a main script with its test suite
- Capture the state of a partial refactor for validation

The stash typically mirrors your local project layout and is created interactively.

## 💡 What is a "context zip"?

A context zip is a curated archive of relevant files meant to rehydrate context for ChatGPT. Unlike a normal stash, it's more complete and less targeted — for example, it might include:
- A README
- A config file
- A primary script and its support libraries
- Possibly a previously received artifact for comparison

It's typically produced with `stashie-context`, and zipped for upload back to ChatGPT.

## 🧾 What does it mean to "review a stash"?

This step helps avoid unintended side effects before uploading a stash zip. It allows you to:
- Inspect what files were included
- Confirm paths and root structure look correct
- Flag surprises like refactors that removed functionality
- Sanity-check for files you didn’t mean to overwrite

You can run this via `stashie-review`.

---

## 🚀 Usage Overview

```sh
# Pick and stash a file
stashie-cli

# Generate a context zip for ChatGPT
stashie-context

# Review stash for structure or surprises
stashie-review
```

See `.stashie.rc.example` for config options. Each tool supports `--help`.
