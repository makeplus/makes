#!/usr/bin/env bash

source test/init slow

out=$(
  make --no-pr golangci-lint-test \
    CMD='which golangci-lint; golangci-lint version'
)

has "$out" "$ROOT/local/bin/golangci-lint" "Found golangci-lint in local/bin"

has "$out" "golangci-lint has version" "Found golangci-lint version"

done-testing
