#!/usr/bin/env bash

source test/init slow

# Free Pascal 3.2.2 does not publish the zip-based Win64 package that fpc.mk
# installs on Unix-like platforms.
if [[ $OSTYPE == msys* || $OSTYPE == cygwin* ]]; then
  pass "Skipping fpc.t on Windows"
  done-testing
  exit 0
fi

out=$(
  make --no-pr fpc-test CMD='fpc -iV; which fpc'
)

has "$out" "3.2.2" "fpc version works"
has "$out" "local/fpc-" "fpc found in local directory"

done-testing
