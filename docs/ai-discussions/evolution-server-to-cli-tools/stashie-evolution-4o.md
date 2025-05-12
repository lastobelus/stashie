# 📜 The Evolution of Stashie  
### *(As traced by the concept archivist)*

---

## 🧩 **Early Concept: Server-backed link constructor (pre-stashie)**

**Initial goal**: Streamline the process of working with ChatGPT by programmatically constructing links with GET parameters — likely as a way to auto-embed context or prefill prompts.

**Key characteristics:**
- Server-based
- Focused on _automated_ handoff to ChatGPT
- Emphasis on encoding state into shareable URLs

**Problems**:
- High fragility: brittle parameters, error-prone ChatGPT context parsing
- Little room for human judgment or override
- Strong coupling to ChatGPT’s interface internals

> ✱ **Implicit tension**: Over-automation led to brittle UX, and complexity outweighed payoff.

---

## 🖥️ **Middle Phase: Filewatcher-based automation**

**Shift**: Replace server logic with local **file system watcher**, hoping for tighter local integration and lower latency.

**Goal at this stage**: Automatically detect changes to project files (e.g., updated prompt input, JSON context), and react by performing automated actions.

**New assumptions**:
- Local shell tools would be sufficient
- Artifacts would be markdown, zip files, or ChatGPT-generated content
- Automation could “just notice” the right state

**Trade-offs**:
- Required consistent file structure
- Introduced statefulness that was hard to reason about
- Still too automated — hard to pause, intervene, or inspect midstream

> ✱ This stage _almost_ reached usefulness, but feedback loops still felt too opaque and brittle.

---

## 🔁 **Inflection Point: Interactive tooling over automation**

**Key realization**: Full automation was the wrong metaphor. What was needed was a **human-guided flow** that respected:
- In-flight editing
- Judgment-based branching
- Lightweight checkpoints

This shifted the design from:
```
"Automatically detect and act" ➝ "Let me pick what to stash, rename, review"
```

### Stashie is born:
- A CLI-focused **interactive toolkit**
- Backed by Bash (at first) for fast iteration
- Inspired by the _ergonomics of version control_, not IDEs or daemons

---

## 🧪 **MVP Architecture: stashie-shell**

**Design approach**:
- Minimal CLI entrypoint (`stashie-cli`)
- Helpers broken into reusable Bash functions (in `stashie-core`)
- `fzf` used for interactivity, not automation
- Each tool (e.g., `get-artifact`, `stashie-context`) encapsulated in a focused task
- `.rc` file introduced to allow per-user override of behavior

**Simplification victories**:
- No daemons, watchers, servers, or persistent state
- Each script reads the filesystem once, acts, exits
- Testing built around stubbing and small composable behaviors

**Stabilized assumptions**:
- Artifacts are files (zip / tar.* / md / code); directories treated via zip or tar.
- Users want fast, visual file picking and predictable actions
- Configuration should be simple shell variables, not nested formats
- Perceived UI latency matters more than implementation purity

---

## 🛠️ **Refinement: Toward future portability**

- Recognized Bash's limits (testability, refactorability)
- Exported all core functions for Bats testing
- Layered configuration from `.rc`, fzf defaults, and fallbacks
- Realized that future re-implementation in other languages was desirable
  - Led to design constraints: shell tools must be **portable, replaceable, predictable**

---

## 🧭 **Where We Are Now**

- A usable MVP with clear architecture
- One-click flow: select → preview → stash
- Helpers are small, exportable, and composed
- Interactive behavior is now _human-first, automation-assisted_
- Ready for reimplementation in:
  - **JavaScript (Bun)** for fast prototyping
  - **Swift CLI** for ergonomic, macOS-native UX
  - **Rust** for long-term performance and safety

---

## 📌 **Summary of the Shift**

| Early Phase        | Now                       |
|--------------------|---------------------------|
| Full automation    | Human-guided interactivity|
| Server or watcher  | Single CLI command        |
| Encoded links      | Files and zip artifacts   |
| Automation-centric | Judgment-centric          |
| ChatGPT-dictated   | User-dictated             |
