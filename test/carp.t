#!/usr/bin/env bash

source test/init slow

out=$(
  make --no-pr carp-test CMD='carp --no-profile </dev/null; printf "%s\n" "$CARP_DIR"'
)

has "$out" "Welcome to Carp" "carp starts"
has "$out" "local/carp-0.6.0" "CARP_DIR is set to local directory"

done-testing
