#!/usr/bin/env bash

source test/init slow

out=$(
  make --no-pr go-test CMD='go version; go env GOROOT'
)

has "$out" "go version go" "go version works"
has "$out" "local/go-" "GOROOT is set to local"

done-testing
