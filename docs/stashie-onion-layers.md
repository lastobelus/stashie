# 🧅 Stashie Onion – Iterative Layers of Functionality

Each layer of the onion builds on the previous, solving pain points, adding capabilities, or removing dependencies. The core is simple and effective; each outer layer increases power, flexibility, or platform reach.

---

## 🥇 Core Layer: `get-artifact` (✅ Done)

- **Name:** `get-artifact`
- **Project Path:** `shell/`
- **What:** `zsh` function to retrieve recent files from `~/Downloads`, preview them using `fzf`, unzip or copy them to a selected directory, and optionally archive or delete the original file after use
- **Tools:** `zsh`, `fzf`, `bat`, `tree`, `osascript`
- **Personal Value:** Fastest, most fluid bridge from ChatGPT to filesystem without breaking focus
- **Other User Value:** Portable dotfile utility; intuitive for CLI users; easy to customize
- **Pain Solved:** Manual file sorting and repetitive copy/paste flows
- **Remaining Gaps:** Requires manual invocation; no remote integration; desktop-only
- **TODO:**
  - Add logging support (optional: include destination + archive/delete mode)
  - allow dynamic renaming before save (fzf hook?)
  - Optionally support .tar.gz and other archive formats
  - option [-m] to look in `~Library/Mobile Documents/com~apple~CloudDocs/ChatGPT-Downloads\`
  - use shell vars for the download dirs so they can be overridden in environment, or look for a `.stashie.rc`

---

## 🥈 Layer 2: Local HTTP Endpoint

- **Name:** `stashie-server`
- **Project Path:** `server`
- **What:** Elixir Plug + Cowboy server to accept `GET`/`POST` requests to save files
- **Tools:** Elixir, Plug, Cowboy, `localtunnel` (optional)
- **Personal Value:** Zero-click snippet saving from ChatGPT/browser
- **Other User Value:** Dev-friendly API for self-hosted snippet ingestion
- **Pain Solved:** Enables remote handoff
- **Remaining Gaps:** Requires server uptime; tunnel is brittle; no result feedback

---

## 🥉 Layer 3: Downloads Folder Watcher

- **Name:** `stashie-watcher`
- **Project Path:** `watcher`
- **What:** Watches for `.chat.zip` bundles in `~/Downloads`, interprets metadata to execute tasks (unzip, save, run commands)
- **Tools:** Elixir, `fswatch`, `entr`, macOS FSEvents; `osascript`
- **Personal Value:** Zero-effort automation for payloads from ChatGPT
- **Other User Value:** Works well for dev scaffolds, batch snippets, AI-powered project starters
- **Pain Solved:** Removes need for active trigger or persistent endpoint. Works for mobile devices if they download to an iCloud folder that is watched on the device running stashie
- **Remaining Gaps:** Requires zip prep (chatgpt must package even single files into an archive, with instructions); no standard format yet

---

## 🎖️ Layer 4: Custom URL Handler (`stashie://`) via Hammerspoon or Native App

- **Name:** `stashie-spoon`
- **Project Path:** `spoon`
- **What:** Handles custom URLs (e.g. `stashie://save?p=path&c=content`) using Hammerspoon or Swift
- **Tools:** Hammerspoon or Swift/Cocoa App, `osascript`, `hs.notify`, `URLComponents`
- **Personal Value:** Native OS integration, zero-tunnel flow, notifications
- **Other User Value:** Shareable, discoverable, self-contained Mac utility
- **Pain Solved:** Eliminates dependency on HTTP tunnels or CLI
- **Remaining Gaps:** Mac-only; requires install/config. Cannot be triggered remotely unless paired with a synced folder or a tool like Shortcuts, Hammerspoon remote, or browser bookmarklet on another device.

---

## 🥷 Layer 5: iOS / macOS App (URL Scheme)

- **Name:** `stashie-app`
- **Project Path:** `app/`
- **What:** A native Swift-based application (or two: one for macOS, one for iOS) that registers a custom URL scheme like `stashie://save?p=...&c=...`. It runs silently in the background and handles file saving, launching logic, or forwarding commands to other stashie layers.
- **Tools:** Swift (macOS/iOS), AppKit/UIKit, URLComponents, FileManager, NSUserNotificationCenter or `UserNotifications`
- **Personal Value:** Native and seamless on both desktop and mobile; removes dependence on Hammerspoon or HTTP endpoints; tightest integration with OS-level security and sandboxing
- **Other User Value:** Easily installable app with clear purpose, runs without CLI or manual setup; ideal for users who want stashie from ChatGPT on iPhone or iPad
- **Pain Solved:** First-class support for mobile; replaces brittle tunnels with reliable system-level URL routing
- **Remaining Gaps:** Requires App Store provisioning or manual installation; mobile restrictions may limit shell-like features without extra integrations** Requires installation and learning curve

---

Each layer should be self-contained, graceful under failure, and removable without breaking the core.

Future enhancements can be inspired by user feedback, friction logs, or joyful workflows discovered in the field.