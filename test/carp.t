#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init slow

# Expanded by the Makes shell, not this test shell.
# shellcheck disable=SC2016
out=$(
  make --no-pr carp-test \
    CMD='carp --no-profile </dev/null; printf "%s\n" "$$CARP_DIR"'
)

has "$out" "Welcome to Carp" "carp starts"
has "$out" "local/carp-0.6.0" "CARP_DIR is set to local directory"

done-testing
