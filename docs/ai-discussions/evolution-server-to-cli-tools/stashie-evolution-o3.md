# 📜 The Evolution of Stashie  
### *(As traced by the concept archivist — o3 model)*

---

## 🧩 Early Phase: Link Constructor

The project that would become Stashie began as an attempt to generate ChatGPT links pre-filled with context. This involved constructing URLs with GET parameters pointing to context files, possibly hosted or embedded.

- **Assumption**: ChatGPT links could encode enough structure to prefill meaningful sessions.
- **Trade-off**: Tight coupling to the UI mechanics of ChatGPT.
- **Problem**: Fragile links, unclear flows, low user confidence.

---

## 🖥️ Intermediate Phase: File Watcher Automation

This evolved into a local file-watcher script. When a new context file or prompt artifact appeared in a watched folder, a script would zip it and construct a corresponding ChatGPT call.

- **Goal**: Automate round-tripping between the editor and ChatGPT.
- **Assumption**: That automation would reduce friction.
- **Outcome**: Introduced more friction via indirect logic and unpredictable automation triggers.

---

## 🔁 Inflection Point: The Interactivity Pivot

Recognizing the brittleness of automation and the need for more human checkpoints, the project pivoted to **interactive CLI tooling** — letting the user select, preview, and confirm actions like zipping, reviewing, and dispatching files.

- **Core Insight**: Partial automation plus deliberate checkpoints beats full automation.
- **Design Move**: Build one-shot CLI tools with interactive selection and feedback (fzf).
- **Assumption Shift**: Manual steps are fine if they're fast and ergonomic.

---

## 🛠️ MVP Implementation: stashie-shell (Bash)

Built atop bash scripts and `fzf`, `stashie-shell` emerged as a modular CLI tool:

- **Tools**: `stashie-cli`, `stashie-context`, `get-artifact`, `stashie-review`, etc.
- **Design Trade-offs**:
  - Bash: fast to iterate, hard to refactor.
  - Exports everything for testing.
  - No persistent state; all scripts act and exit.
- **Simplifications**:
  - `.stashie.rc` handles configuration overrides.
  - Previews standardized through `stashie-fzf-preview`.
  - Artifacts are always files (e.g., zip, tar, md).
- **Assumptions Locked In**:
  - CLI-first UX is preferable to daemons.
  - File-level granularity is sufficient.
  - fzf is fast enough and portable enough to build around.

---

## 🧭 Current Focus: Portability and Reimplementation

The Bash prototype is now complete enough to serve as a **specification** for reimplementations in:

- **Bun (JS)**: for fast feedback and iteration
- **Swift CLI**: for a native-feeling UX on macOS
- **Rust**: for long-term stability, performance, and safety

Each port will follow the same user flow: pick → preview → process, but may explore different architecture patterns.

---

## 📌 Summary Table

| Phase               | Goal                              | Assumption              | Tradeoff               |
|---------------------|-----------------------------------|--------------------------|------------------------|
| Link Constructor    | Prefill ChatGPT context           | Links can encode flows   | Fragility              |
| File Watcher        | Automate context prep             | Automation reduces work  | Opaqueness, misfires   |
| Interactive CLI     | Make actions intentional & fast   | Users want checkpoints   | Slightly more manual   |
| Bash MVP            | One-shot, testable shell tools    | Bash is fastest to MVP   | Portability, structure |
| Polyglot Next       | Reimplement from clean spec       | Behavior now stable      | Time to port           |
