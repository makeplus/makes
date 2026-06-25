#!/usr/bin/env bash

source test/init slow

# Free Pascal 3.2.2 publishes macOS as a DMG and Windows as an EXE, while
# fpc.mk currently installs only the Unix tar layout.
if [[ $OSTYPE == darwin* || $OSTYPE == msys* || $OSTYPE == cygwin* ]]; then
  pass "Skipping fpc.t on this platform"
  done-testing
  exit 0
fi

out=$(
  make --no-pr fpc-test CMD='fpc -iV; which fpc'
)

has "$out" "3.2.2" "fpc version works"
has "$out" "local/fpc-" "fpc found in local directory"

done-testing
