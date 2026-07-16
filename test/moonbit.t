#!/usr/bin/env bash

source test/init slow

out=$(
  make --no-pr moonbit-test CMD='which moon; moon version'
)

has "$out" "$ROOT/local/moonbit-" "Found moon in local/moonbit"
has "$out" "moon" "moon version produced output"

done-testing
