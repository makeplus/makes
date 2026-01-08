#!/usr/bin/env bash

source test/init slow

out=$(
  make --no-pr jq-test CMD='which jq; jq --version'
)

has "$out" "$ROOT/local/bin/jq"

has "$out" "jq-1."

done-testing
