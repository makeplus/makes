#!/usr/bin/env bash

source test/init slow

out=$(
  make --no-pr babashka-test CMD='which bb; bb --version'
)

has "$out" "$ROOT/local/babashka-" "Found bb in local/babashka"

has "$out" "v1." "Found babashka version"

done-testing
