### Why add a *“CI lint (grep)”* step?

ShellCheck already catches hundreds of issues, but it **can’t express every house‑rule** you adopt in `CONTRIBUTING.md`—especially style conventions such as:

* *“If a function prints an error it must immediately `return 1`.”*  
* *“All temp‑dirs must be removed in a `trap … EXIT`.”*  

Rather than writing a custom ShellCheck rule (Haskell) you can bolt on a **tiny, fast grep‑based gate** that fails the build whenever a forbidden pattern appears or a required pattern is missing.

---

### Typical violations to catch

| Rule you document | Grep test example |
|-------------------|-------------------|
| Error message without non‑zero return | `grep -nE 'echo .*error' "$f" \| grep -vqE 'return +[1-9]|exit +[1-9]'` |
| Missing `set -uo pipefail` header | `! grep -q 'set \-uo pipefail' "$f"` |
| Unquoted variable in comparison (SC2250 policy) | `grep -nE '\[\[ .* = [A-Za-z0-9_]+\]' "$f"` |
| Leftover “TODO” comments in shipping code | `grep -n TODO "$f"` |

Keep each grep **focused and simple**; noisy rules will frustrate contributors.

---

### Implementation outline

1. **Add a script** `scripts/lint-style.sh`:

    ```bash
    #!/usr/bin/env bash
    set -euo pipefail

    err() { printf "STYLE‑VIOLATION:%s:%s\n" "$1" "$2"; }

    fail=0
    while IFS= read -r -d '' f; do
      # Require set -uo pipefail at top (first 5 lines)
      if ! head -5 "$f" | grep -q 'set \-uo pipefail'; then
        err "$f" "missing 'set -uo pipefail'"
        fail=1
      fi

      # Error echo must be followed by non‑zero return/exit
      while IFS= read -r line; do
        ln=$(grep -nF "$line" "$f" | cut -d: -f1)
        err "$f:$ln" "echo error without return/exit"
        fail=1
      done < <(grep -E 'echo +.*error' "$f" | grep -vE 'return +[1-9]|exit +[1-9]' || true)
    done < <(find shell -name '*.sh' -print0)

    exit $fail
    ```

2. **Wire it into CI** (same jobs that run ShellCheck):

    ```yaml
    - name: Lint shell style
      run: bash scripts/lint-style.sh
    ```

3. **Keep rule text close to code**  
   Add a table of *Rule → Regex* inside `CONTRIBUTING.md` so devs understand why CI failed and can run the same grep locally:

    ```md
    | Rule | Regex checked |
    |------|---------------|
    |   Functions that print an error must `return 1` | `echo .*error` not followed by `return|exit` |
    |   File header needs `set -uo pipefail`           | `set \-uo pipefail` within first 5 lines |
    ```

---

### Best‑practice tips

* **Fail fast, explain clearly** – echo a short human‑readable reason with the filename/line.  
* **Run after ShellCheck** – you’ll often remove 80 % of issues by standard ShellCheck first.  
* **Keep patterns version‑controlled** – treat `scripts/lint-style.sh` as codified policy; update when rules change.  
* **Developers can opt‑in locally** – add `make lint-style` or a pre‑commit hook that calls the same script.  
* **Avoid false positives** – scope greps to `shell/` and ignore vendor or test fixtures; fine‑tune with `grep -v`.  

With this lightweight gate in place **future PRs that accidentally drop a `return 1` or forget `pipefail` will be blocked automatically**, enforcing the error‑handling standard you’re about to publish.