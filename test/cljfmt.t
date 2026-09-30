#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init slow

read -r _ _ cljfmt_version < "$ROOT/cljfmt.mk"
case $OSTYPE in
  msys*|cygwin*) exe=.exe ;;
  *) exe= ;;
esac

out=$(
  make --no-pr cljfmt-test CMD='which cljfmt; cljfmt --version'
)

has "$out" "$ROOT/local/cljfmt-" "Found cljfmt in local/cljfmt"

has "$out" "cljfmt $cljfmt_version" "Found cljfmt version"

out=$(
  printf '%s\n' '(defn greet[name](println "Hello,"name))' |
    "$ROOT/local/cljfmt-$cljfmt_version/bin/cljfmt$exe" --quiet fix -
)

is "$out" '(defn greet [name] (println "Hello," name))' \
  "cljfmt formats stdin to stdout"

done-testing
