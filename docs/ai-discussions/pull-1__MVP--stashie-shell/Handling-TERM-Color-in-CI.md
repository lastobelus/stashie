### Goal  
Be sure that **fzf previews (and any `ls`, `tree`, `bat`, etc. output you pipe into them) render acceptably** when the job’s pseudo‑terminal either:

1. Supports ANSI colour (usual default: `TERM=xterm‑256color`), or  
2. Does **not** (e.g. `TERM=dumb`, or colour explicitly disabled).

If your scripts silently assume colour, raw escape sequences will leak into the UI or tests.

---

### Approach in CI

| Step | What to do | Notes |
|------|------------|-------|
| **1. Parameterise colour usage** | Make preview helpers respect `NO_COLOR`, `CLICOLOR`, or a project‑specific `STASHIE_COLOR=0/1` env var.<br>Wrap colour codes behind a `color()` function that’s a no‑op when disabled. | Enables simple on/off toggling in tests without editing code. |
| **2. Add two matrix axes** | In the existing job matrix (`macos-latest`, `ubuntu-latest`) add a **strategy.include** section that varies: <br>`env: { TERM: xterm-256color, STASHIE_COLOR: 1 }` <br>`env: { TERM: dumb, STASHIE_COLOR: 0 }` | Keeps total jobs small while exercising both modes. |
| **3. Drive a smoke preview** | In each job run a non‑interactive preview command and **diff its output** against a fixture stripped of colour. Example: ```bash OUTPUT=$(TERM=$TERM STASHIE_COLOR=$STASHIE_COLOR \   shell/bin/stashie-preview file.zip 2>/dev/null) printf '%s\n' "$OUTPUT" | sed -E 's/\x1B\[[0-9;]*[mK]//g' >out.txt diff -u test/fixtures/preview_expected.txt out.txt ``` | `sed` removes ANSI escapes so both colour and colour‑less runs compare against the same fixture. |
| **4. Fail on leaked escapes** | Add an assertion when `STASHIE_COLOR=0`: ```grep -q $'\e[' out.txt && { echo "ANSI escapes leaked"; exit 1; }``` | Catches cases where colour strings are emitted despite colour=off. |
| **5. Keep tests lightweight** | Only process a tiny fixture archive; the goal is validation, not full UI coverage. | Avoids slowing CI. |

---

### Example GitHub Actions snippet

```yaml
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            term: xterm-256color
            color: "1"
          - os: ubuntu-latest
            term: dumb
            color: "0"
          - os: macos-latest
            term: xterm-256color
            color: "1"
    steps:
      - uses: actions/checkout@v4
      - name: Install deps
        run: brew install fzf bats-core || sudo apt-get install -y fzf bats
      - name: Smoke preview colour test
        env:
          TERM: ${{ matrix.term }}
          STASHIE_COLOR: ${{ matrix.color }}
        run: |
          ./scripts/ci-smoke-preview.sh
```

`ci-smoke-preview.sh` holds the sed/diff/grep logic from **Step 3–4** so it can be reused locally.

---

### Key Take‑aways

* **Expose a colour toggle** in code first.  
* **Matrix over TERM & toggle** to hit both scenarios without exploding job count.  
* **Strip escapes in assertion** so you only maintain one expected output fixture.  
* Keep the fixture and script tiny; the goal is regression safety, not exhaustive UI testing.