#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

cat > "$work/Makefile" <<MAKE
M := $ROOT
MAKES_LOCAL_DIR := $ROOT/local
include \$(M)/init.mk
include \$(M)/jus.mk
include \$(M)/jus.mk

inspect:
	@printf '%s\n' \
	  'executable=\$(JUS)' \
	  'deps=\$(SHELL-DEPS)' \
	  'bbin=\$(BBIN)' \
	  'clojure=\$(CLOJURE)' \
	  'path=\$(PATH)'
MAKE

out=$(make --no-print-directory -f "$work/Makefile" \
  JUS-VERSION=9.8.7 inspect)
has "$out" "executable=$ROOT/local/jus-9.8.7/bin/jus" \
  'Version override selects a separate installation'
has "$out" "bbin=$ROOT/local/bbin-" 'jus includes bbin'
has "$out" "clojure=$ROOT/local/clojure-" 'jus includes Clojure'
has "$out" "path=$ROOT/local/jus-9.8.7/bin:" 'jus is on PATH'
deps=$(printf '%s\n' "$out" | while IFS= read -r line; do
  [[ $line != deps=* ]] || printf '%s' "${line#deps=}"
done)
is "$(wc -w <<< "$deps" | tr -d ' ')" 5 \
  'Repeated includes do not duplicate shell dependencies'

out=$(make --no-print-directory -n -f "$work/Makefile" \
  JUS-VERSION=9.8.7 "$ROOT/local/jus-9.8.7/bin/jus")
has "$out" "BABASHKA_BBIN_BIN_DIR=$ROOT/local/jus-9.8.7/bin" \
  'Installation directs bbin to the versioned jus directory'
has "$out" 'install io.github.paintparty/jus --git/tag v9.8.7' \
  'Installation pins the requested upstream tag'

out=$(make --no-print-directory -n -f "$work/Makefile" \
  JUS-SOURCE="$work/source with spaces" JUS-VERSION=dev \
  "$ROOT/local/jus-dev/bin/jus")
has "$out" "install '$work/source with spaces' --as jus" \
  'Source override installs a quoted local checkout as jus'
has "$out" "test -f '$work/source with spaces/bb.edn'" \
  'Source override checks for the Jus project file'
hasnt "$out" '--git/tag' 'Source override does not pin the published tag'

if [[ -z ${slow-} ]]; then
  pass 'Use slow=1 to run the jus installation tests'
  done-testing
  exit 0
fi

out=$(make --no-pr jus-test CMD='command -v jus; jus --help')
has "$out" "$ROOT/local/jus-" 'Found the managed jus executable'
has "$out" 'Usage:' 'jus loads its dependencies and prints help'

export JUS_TEST_DIR=$work
# Expanded by the Makes shell, not this test shell.
# shellcheck disable=SC2016
out=$(make --no-pr jus-test \
  CMD='cd "$$JUS_TEST_DIR"; jus tasks 2>&1; printf "status=%s\n" "$$?"')
has "$out" 'No bb.edn (with tasks) was found in:' \
  'jus reports a missing task file without opening the TUI'
has "$out" "$work" 'jus examines the caller directory'
has "$out" 'status=1' 'jus preserves the missing-task exit status'

done-testing
