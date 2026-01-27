#!/usr/bin/env bash

source test/init slow

out=$(
  make --no-pr fpc-test CMD='fpc -h; which fpc'
)

has "$out" "Free Pascal Compiler" "fpc version works"
has "$out" "local/fpc-" "fpc found in local directory"

done-testing
