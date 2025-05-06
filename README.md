# Stashie

Stashie is a small project exploring how to streamline the handoff of code and other files to ChatGPT.

## Current Implementation: stashie-shell

`stashie-shell/` contains an MVP implementation of patterns we've found helpful for working alongside a ChatGPT Plus account in a local development environment (e.g. VSCode with Copilot or Cody).

This MVP is implemented in Bash to validate the basic workflows and interactions.

As a next step, we plan to reimplement these patterns in:
- 🟢 JavaScript (Bun)
- 🟠 Swift CLI
- 🔴 Rust

This will serve both as a learning project and a way to compare ergonomics and maintainability. Eventually, one implementation may become the primary.

## What's in this repo?

- `stashie-shell/`: the current Bash MVP
- `.github/workflows/`: GitHub Actions for CI on Bash scripts
- `docs/`: Planning and process notes
