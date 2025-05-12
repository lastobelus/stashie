# Evolution of Stashie

A chronological overview of the Stashie project, tracing its journey from early brainstorming to the polished CLI tool in Bash.

## 1. Origins: Conceptual Prototyping
- **Chat-driven Ideation**: Stashie began as a mental model for capturing and reusing conversational context within ChatGPT sessions. Early iterations were purely conceptual, relying on ad-hoc prompts and manual copy-paste.
- **Goal Shift**: The initial aim was to reduce cognitive load by surfacing relevant past interactions. Over time, this broadened into a more general-purpose "context archivist" tool.

## 2. First Prototype: stashie-context Script
- **Local Script**: To automate context bundling, a Bash script—**stashie-context**—was created. It scanned user-specified directories, packaged files into a zip, and reopened the ChatGPT interface.
- **Design Tradeoff**: Chose Bash for maximal portability and zero dependencies, accepting the complexity of shell scripting.
- **Solidified Assumption**: Local-first operation respects user privacy and simplifies deployment.

## 3. Iteration One: stashie-shell v0.1.0
- **Expanded CLI**: The project matured into **stashie-shell**, a monolithic Bash CLI with subcommands (e.g., `get-artifact`, `context`, `clean`).
- **Key Features**:
  - **`set -uo pipefail`** for robust error handling.
  - **Function Exporting** (`export -f`) to facilitate `bats` testing.
  - **ShellCheck Compliance**: Addressed SC2086 and SC2250, ensuring proper quoting (`zip -r "${dest}" "${files}"`) and safe string comparisons.
  - **Interrupt Safety**: Handled `Ctrl-C` cleanly in interactive prompts.
- **Architecture Simplification**: Consolidated disparate scripts into a single CLI entrypoint, reducing file proliferation.

## 4. Refinement: Usage Patterns & Caching
- **Zip Naming**: Introduced timestamped zip filenames (e.g., `context-for-chat_<HHMM>.zip`) to avoid browser caching issues.
- **Project Root Unzipping**: Ensured archives preserve project-relative paths for consistent context restoration.
- **User Workflow**: Streamlined commands as idiomatic CLI (e.g., `stashie context`, `stashie get-artifact`).

## 5. Tradeoffs and Evolving Assumptions
- **Bash vs. Structured Language**: While Bash enabled rapid prototyping without external dependencies, maintainability concerns emerged. This prompted exploration of JavaScript (Bun), Swift CLI, and Rust for potential rewrites.
- **Offline-first vs. Server-based**: Early server concepts were abandoned in favor of local tooling, prioritizing simplicity and user control.
- **Testing Strategy**: Emphasis on `bats` for shell testing; future rewrites might leverage richer testing frameworks in other languages.

## 6. Path Forward: Multi-Language Parallel Implementations
- **3-Way Reimplementation Plan**:
  1. **JavaScript (Bun)** for fast iteration and prototyping.
  2. **Swift CLI** to leverage native performance and macOS integration.
  3. **Rust** for strong type safety and long-term maintainability.
- **Staying Lightweight**: Each implementation will retain the core CLI interface and file-based zip workflow, ensuring consistency across languages.

---

*This document captures the distilled history of Stashie’s evolution and the reasoning behind key architectural decisions.*  
