#!/usr/bin/env bash

source test/init slow

# Skip on Windows (no Windows binary support yet)
if [[ $OSTYPE == msys* || $OSTYPE == cygwin* ]]; then
  pass "Skipping jq.t on Windows"
  done-testing
  exit 0
fi

out=$(
  make --no-pr jq-test CMD='which jq; jq --version'
)

has "$out" "$ROOT/local/bin/jq" "Found jq in local/bin"

has "$out" "jq-1." "jq --version shows version"

done-testing
