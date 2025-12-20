#!/usr/bin/env bash

source test/bpan-init slow

out=$(
  "$MAKEX" --no-pr jq-test CMD='which jq; jq --version'
)

has "$out" "$ROOT/local/bin/jq"

has "$out" "jq-1."

done-testing
