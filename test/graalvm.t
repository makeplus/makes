#!/usr/bin/env bash

source test/init slow

# Skip on macOS Intel (GraalVM no longer supports it)
if [[ $OSTYPE == darwin* && $(uname -m) == x86_64 ]]; then
  pass "Skipping graalvm.t on macOS Intel (unsupported)"
  done-testing
  exit 0
fi

out=$(
  make --no-pr graalvm-test CMD='java --version; javac --version; native-image --version'
)

has "$out" "Oracle GraalVM" "java --version shows Oracle GraalVM"
has "$out" "javac" "javac --version works"
has "$out" "native-image" "native-image --version works"

done-testing
