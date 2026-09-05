#!/usr/bin/env bash

source test/init slow

out=$(
  make --no-pr in-1-test CMD='which in-1; in-1 --version'
)

has "$out" "$ROOT/local/cache/in-1-" "Found in-1 in local/cache"

has "$out" "in-1 " "Found in-1 version"

done-testing
