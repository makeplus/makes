#!/usr/bin/env bash

source test/init slow

out=$(
  make --no-pr clj-kondo-test CMD='which clj-kondo; clj-kondo --version'
)

has "$out" "$ROOT/local/bin/clj-kondo" "Found clj-kondo in local/bin"

has "$out" "v" "Found clj-kondo version"

done-testing
