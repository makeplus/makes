#!/usr/bin/env bash

source test/init slow

out=$(
  make --no-pr in-1-test CMD='which in-1; in-1 --version'
)

has "$out" "$ROOT/local/cache/in-1-main" "Found in-1 main in local/cache"

has "$out" "in-1 " "Found in-1 version"

is "$(git -C "$ROOT/local/cache/in-1-main" branch --show-current)" \
  main "The in-1 clone tracks main"

done-testing
