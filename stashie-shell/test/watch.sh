#!/usr/bin/env bash

# Watch for changes in shell scripts and run bats tests
find ./shell -name '*.sh' | entr -c bats test/
