#!/usr/bin/env bash

source test/init slow

out=$(
  make --no-pr graalvm-test CMD='java --version; javac --version; native-image --version'
)

has "$out" "Oracle GraalVM" "java --version shows Oracle GraalVM"
has "$out" "javac" "javac --version works"
has "$out" "native-image" "native-image --version works"

done-testing
