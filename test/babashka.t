#!/usr/bin/env bash

source test/init slow

out=$(
  make --no-pr babashka-test CMD='which bb; bb --version'
)

has "$out" "$ROOT/local/bin/bb" "Found bb in local/bin"

has "$out" "v1." "Found babashka version"

done-testing
