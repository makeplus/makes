#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

makefile=$(mktemp)
trap 'rm -f "$makefile"' EXIT

cat > "$makefile" <<MAKE
M := $ROOT
include \$(M)/init.mk
include \$(M)/go-yaml.mk

inspect:
	@printf '%s\n' \
	  'package=\$(GO-YAML-PKG)' \
	  'binary=\$(GO-YAML)' \
	  'deps=\$(SHELL-DEPS)'
MAKE

out=$(make --no-print-directory -f "$makefile" inspect)
has "$out" 'package=go.yaml.in/yaml/v4/cmd/go-yaml@main' \
  'go-yaml builds from main'
has "$out" "binary=$ROOT/local/bin/go-yaml" \
  'go-yaml installs in local/bin'
has "$out" " $ROOT/local/bin/go-yaml" \
  'go-yaml is a shell dependency'

if [[ -z ${slow-} ]]; then
  pass 'Use slow=1 to run the go-yaml installation test'
  done-testing
  exit 0
fi

out=$(make --no-pr go-yaml-test CMD='which go-yaml')
has "$out" "$ROOT/local/bin/go-yaml" \
  'Found go-yaml in local/bin'

out=$(printf 'foo: bar\n' | "$ROOT/local/bin/go-yaml" -y)
is "$out" 'foo: bar' 'go-yaml processes YAML from stdin'

done-testing
