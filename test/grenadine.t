#!/usr/bin/env bash

source test/init slow

out=$(
  make --no-pr grenadine-test CMD='which grenadine; grenadine --version'
)

has "$out" "$ROOT/local/grenadine-" "Found grenadine in local/grenadine"

has "$out" "grenadine v0.1." "Found grenadine version"

done-testing
