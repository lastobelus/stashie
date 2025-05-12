# 📜 The Evolution of Stashie  

---
## 📌 Problem Statement: The Pain of Copy-Pasting from ChatGPT

During the early phases of developing with ChatGPT Plus, one of the persistent pain points was the workflow of transferring ChatGPT-generated code or other artifacts into a real project. The default mode — **manually copy-pasting suggestions** from ChatGPT's response pane into the local filesystem — quickly became tedious, error-prone, and mentally taxing. It was too easy to:
- Lose track of which files had been updated
- Accidentally overwrite working code
- Miss subtle changes in large blocks of text

An alternative was explored: **diff-based patch generation**. The idea was to have ChatGPT generate unified diffs that could be applied with `git apply` or `patch`. Unfortunately, this proved to be a dead end. While ChatGPT could often produce well-formatted diffs, it struggled to reliably generate correct **hunk headers** — the `@@` lines that encode line number ranges. Even when syntactically valid, these diffs would frequently fail to apply cleanly due to mismatches in context lines or file positions.

This led to a realization: **neither raw copy-paste nor AI-generated diffs could serve as a robust interface** for iterative development. What was needed instead was a layer of interactive tooling — one that allowed human judgment to remain in the loop, while still leveraging AI-generated artifacts.


## 🧩 Early Phase: Link Constructor

The project that would become Stashie began as an attempt to have ChatGPT generate "artifact" links with the content of a file and the path in a project where that file should live. This involved constructing URLs with GET parameters: a path to an existing or new file in the project, and new content to be written to that file. A server listening either on localhost or a remote endpoint would then handle the request and create/replace the file with the provided content.

- **Assumption**: ChatGPT links could encode enough structure to prefill meaningful sessions.
- **Trade-off**: Tight coupling to the UI mechanics of ChatGPT.
- **Problems**:
  - High fragility: brittle parameters, error-prone ChatGPT context parsing
  - Little room for human judgment or override
  - constructed links were difficult to inspect (url-encoded params)
  - GET request size limitations

> ✱ **Implicit tension**: Over-automation led to brittle UX, and complexity outweighed payoff.

---

## 🖥️ Intermediate Phase: File Watcher Automation

This evolved into a local file-watcher script. When a new artifact appeared in a watched folder (I.E. when the user clicked on a "Downloadable" link in ChatGPT), the script would automatically download the artifact and apply it to the project.

- **Goal**: Automate round-tripping between the editor and ChatGPT.
- **Assumptions**: 
  - Artifacts would be markdown, zip files, or ChatGPT-generated content
  - Automation could “just notice” the right state
  - Local shell tools would be sufficient
- **Trade-offs**:
  - Required consistent file structure, with all artifacts rooted in the project root
  - Introduced statefulness that was hard to reason about
  - Still too automated — hard to pause, intervene, or inspect midstream
  - Difficult to handle multiple artifacts at once

---

## 🔁 Inflection Point: The Interactivity Pivot

Recognizing the brittleness of automation and the need for more human checkpoints, the project pivoted to **interactive CLI tooling**. What was needed was a **human-guided flow** that respected:
- In-flight editing
- Judgment-based branching
- Lightweight checkpoints

- **Core Insight**: Partial automation plus deliberate checkpoints beats full automation.
- **Design Move**: Build one-shot CLI tools with interactive selection (using fzf) and feedback.
- **Assumption Shift**: Manual steps are fine if they're fast and ergonomic.
- **Advantages**:
  - Tools used well-practiced shell practices, ex. fuzzy selection of artifacts, destinations, with on-the-fly previews
  - Easier to pause, resume, and inspect
  - Easier to handle multiple artifacts (just put them all in a zip, with their respective paths).
  - Easy to specify a different root directory for a particular artifact.
  - Later features requiring more context could be handled by adding manifests to zips emitted by ChatGPT.

### Stashie is born:
- A CLI-focused **interactive toolkit**
- Backed by Bash (at first) for fast iteration
- Inspired by the _ergonomics of version control_, not IDEs or daemons


---

## 🛠️ MVP Implementation: stashie-shell (Bash)

Built atop bash scripts and `fzf`, `stashie-shell` emerged as a modular CLI tool:

- **Tools**: `stashie-cli`, `stashie-context`, `get-artifact`, `stashie-review`, etc.
- **Design Trade-offs**:
  - Bash: fast to iterate, hard to refactor.
  - Exports everything for testing.
  - No persistent state; all scripts act and exit.
- **Simplifications**:
  - No daemons, watchers, servers, or persistent state
  - `.stashie.rc` handles configuration overrides.
  - Previews standardized through `stashie-fzf-preview`.
  - Artifacts are always files (e.g., zip, tar, md).
- **Assumptions Locked In**:
  - CLI-first UX is preferable to daemons.
  - Artifacts are files (zip / tar.* / md / code); directories treated via zip or tar.
  - Users want fast, visual file picking and predictable actions
  - File-level granularity is sufficient, at least for now.
  - fzf is fast enough and portable enough to build around and is a good fit as a UI paradigm. Most user decisions can be made with a keystroke or two.

---

## 🧭 Current Focus: Portability and Reimplementation

The Bash prototype is now complete enough to serve as a **specification** for reimplementations in language/tooling more suitable for long-term maintenance and portability. The following languages were considered for reimplementations:

- **Bun (JS)**: for fast feedback and iteration
- **Swift CLI**: for a native-feeling UX on macOS
- **Rust**: for long-term stability, performance, and safety

We decided to iterate in parallel on all three, with the goal of:
-fast feature iteration in JS,
-then porting the iteration to Swift to refine and better understand the design space.
-finally, porting the iteration to Rust for performance and safety (and because the author wanted to learn Rust).

---

## 📌 Summary Table

| Phase               | Goal                              | Assumption              | Tradeoff               |
|---------------------|-----------------------------------|--------------------------|------------------------|
| Link Constructor    | Prefill ChatGPT context           | Links can encode flows   | Fragility              |
| File Watcher        | Automate context prep             | Automation reduces work  | Opaqueness, misfires   |
| Interactive CLI     | Make actions intentional & fast   | Users want checkpoints   | Slightly more manual   |
| Bash MVP            | One-shot, testable shell tools    | Bash is fastest to MVP   | Portability, structure |
| Polyglot Next       | Reimplement from clean spec       | Behavior now stable      | Time to port           |

---
## 🧪 Why So Much Ceremony?

Stashie is a relatively small project — by lines of code, complexity, and scope. Yet we're deliberately applying levels of ceremony, process, and reflective analysis that would typically be reserved for much larger systems.

Why?

Because this project isn’t just about the code — it’s about **learning how to work effectively with AI as a development partner**. By treating Stashie as a testbed for AI-assisted workflows, we’re exploring:

- How to structure iteration cycles with a language model in the loop
- What makes LLM handoff (to humans or to tools) durable and clear
- How to layer judgment, automation, and tooling effectively
- How far we can scale deliberate software process into solo workflows

Working at this level of reflection in a small codebase lets us reason about AI-integrated development **without the cognitive overload of a massive system**. Stashie serves as a microcosm — a way to hammer out reusable ideas in a manageable space before scaling them up elsewhere.
