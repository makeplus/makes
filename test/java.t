#!/usr/bin/env bash

source test/init slow

out=$(
  make --no-pr java-test CMD='which java; java --version'
)

has "$out" "$ROOT/local/jdk-" "Found java in local/jdk"

has "$out" "jdk" "java --version shows jdk"

done-testing
