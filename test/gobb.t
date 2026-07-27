#!/usr/bin/env bash

source test/init slow

out=$(
  make --no-pr gobb-test CMD='which gobb; gobb --version'
)

has "$out" "$ROOT/local/gobb-" "Found gobb in local/gobb"

has "$out" "gobb v0.1." "Found gobb version"

done-testing
