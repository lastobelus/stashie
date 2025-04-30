# stashie-shell

Shell utilities for interactive file selection, stashing, and archiving — with a focus on flow, clarity, and ChatGPT-assisted development.

## 🧩 Components

- **`stashie-func`** — a zsh function sourcing `stashie-core.sh` for in-shell interactivity
- **`stashie-cli`** — standalone shell script version that works in all POSIX shells
- **`stashie-core.sh`** — core functions (can be split out further if needed)
- **`stashie-context`** — utility to bundle context for ChatGPT into a zip
- **`.stashie.rc`** — user config file for behavior tuning (see below)
- **`stashie-review`** — interactive review of "stashed" artifacts using `fzf`, with preview and selection

## 🛠️ Installation

### Option A: Use as a ZSH Function

Add to your `.zshrc`:

```sh
source /path/to/stashie-shell/stashie-func
alias stashie=stashie
```

This lets you use all functions inline in your shell session with persistent variables.

### Option B: Use as a CLI Tool

Copy `stashie-cli` somewhere in your `$PATH`, e.g.:

```sh
cp stashie-shell/stashie-cli /usr/local/bin/stashie
chmod +x /usr/local/bin/stashie
```

This version runs as a standalone command, suitable for cron jobs, scripts, or general portability.

---

## 🧠 Function vs Script (Sidebar)

### Use the **zsh function (`stashie-func`)** if you want:
- Instant feedback and variable sharing (no subshell)
- Easier composition with other in-shell tools
- Interactive workflows where state matters

### Use the **CLI (`stashie-cli`)** if you:
- Prefer traditional scripts
- Want portability across shells
- Need something cronable or automation-friendly

Alias whichever you prefer as `stashie`.

---

## 🔧 Config: `.stashie.rc`

You can customize behavior by creating a `.stashie.rc` file in your home directory.

### Common Fields:
- `CONTEXT_FILENAME` — output path for `stashie-context` zips
- `CHATAPP` — which app to focus after switching back to ChatGPT (e.g., `Firefox`)

See `.stashie.rc.example` for structure and examples.

---

## 🔍 fzf Required

The stashie-shell tools require [fzf](https://github.com/junegunn/fzf) for interactive file selection.

Install it via:
```sh
brew install fzf
```

---

## 🚀 Quickstart

```sh
# Pick and stash a file
stashie

# Generate a context zip for ChatGPT
stashie-context
```

---

## ✅ Status

This project is actively evolving. The shell layer (`stashie-shell`) is stable enough for daily use and open to contributions.

More info and architectural philosophy:
👉 `docs/stashie-onion-layers.md`
