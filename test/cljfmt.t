#!/usr/bin/env bash

source test/init slow

out=$(
  make --no-pr cljfmt-test CMD='which cljfmt; cljfmt --version'
)

has "$out" "$ROOT/local/cljfmt-" "Found cljfmt in local/cljfmt"

has "$out" "cljfmt 0.16.0" "Found cljfmt version"

out=$(
  printf '%s\n' '(defn greet[name](println "Hello,"name))' |
    "$ROOT/local/cljfmt-0.16.0/bin/cljfmt" --quiet fix -
)

is "$out" '(defn greet [name] (println "Hello," name))' \
  "cljfmt formats stdin to stdout"

done-testing
