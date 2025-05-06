# TODOs for merging Stashie pull/1

## Overview of Priorities
### CI
- shellcheck
- green tests

### Platform Dependencies
- mdls
- what is equivalent of `open` on linux?
- `zip -q`
- tar --strip-components
- readlink -f

#### Compat layer
    - provide system detection and alternatives for darwin & linux that are automatically used, via ENV vars that can be overridden by rc
    - encapsulate this in helper functions, hiding from stashie-core etc.
- remove stashie-func for now, it was never properly implemented?
- detect $TERM color support and use appropriate commands if not available

### Error Handling
- be rigorous about errors & exit/return values
- add overridable limits for zip sizes, based on available context sizes of AI models
- always return 1 (or exit 1) after emitting an error
- create a document describing best practices for handling errors & return values and ensure all functions abide by it

### Tests
- test embedded newlines
- test error handling & return values
- linux environment testing

## Iteration Plan
1. Cleanup no longer relevant Elixir server scaffolding
2. CI to support & automate working through the other issues; and to support the multi-language iterations afterwards
3. Darwin environment run via Docker (GitHub Action matrix).
4. Unify error-handling & return/exit values, with supporting tests, using CI to verify 
5. Discuss & scaffold `compat layer` 
6. Linux environment run via Docker (GitHub Action matrix).
7. Tests ensuring compliance with `compat layer`, running in CI