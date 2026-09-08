#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

cat > "$work/Makefile" <<MAKE
M := $ROOT
MAKES_LOCAL_DIR := $ROOT/local
include \$(M)/init.mk
include \$(PRELOAD)
include \$(M)/bbin.mk
include \$(M)/bbin.mk

inspect:
	@printf '%s\n' \
	  'download=\$(BBIN-DOWN)' \
	  'cache=\$(BBIN-CACHE)' \
	  'executable=\$(BBIN)' \
	  'deps=\$(SHELL-DEPS)' \
	  'java=\$(JAVA)' \
	  'bin='\$\$BABASHKA_BBIN_BIN_DIR \
	  'jars='\$\$BABASHKA_BBIN_JARS_DIR \
	  'legacy='\$\$BABASHKA_BBIN_DIR
MAKE

out=$(make --no-print-directory -f "$work/Makefile" \
  BBIN-VERSION=9.8.7 inspect)
has "$out" 'download=https://raw.githubusercontent.com/babashka/bbin/v9.8.7/bbin' \
  'Version override selects the tagged script'
has "$out" 'cache=bbin-9.8.7' 'Download cache includes the version'
has "$out" "executable=$ROOT/local/bbin-9.8.7/bin/bbin" \
  'Executable has a versioned installation directory'
has "$out" "bin=$ROOT/local/bin" 'Applications install locally'
has "$out" "jars=$ROOT/local/cache/bbin-jars" 'JARs cache locally'
has "$out" "legacy=$ROOT/local/cache/bbin-legacy" \
  'Legacy lookup stays outside the personal home'
has "$out" 'deps='"$ROOT/local/babashka-" \
  'Babashka is a shell dependency'
has "$out" "$ROOT/local/jdk-" 'Java is supplied'
deps=$(printf '%s\n' "$out" | while IFS= read -r line; do
  [[ $line != deps=* ]] || printf '%s' "${line#deps=}"
done)
is "$(wc -w <<< "$deps" | tr -d ' ')" 3 \
  'Repeated includes do not duplicate shell dependencies'

out=$(make --no-print-directory -f "$work/Makefile" \
  PRELOAD="$ROOT/graalvm.mk" inspect)
has "$out" "java=$ROOT/local/graalvm-" 'An existing GraalVM supplies Java'

if [[ -z ${slow-} ]]; then
  pass 'Use slow=1 to run the bbin installation tests'
  done-testing
  exit 0
fi

out=$(make --no-pr bbin-test CMD='command -v bbin; bbin version; bbin bin')
has "$out" "$ROOT/local/bbin-" 'Found the managed bbin executable'
has "$out" 'bbin 0.' 'bbin runs with managed dependencies'
has "$out" "$ROOT/local/bin" 'bbin reports the managed application directory'

mkdir -p "$work/home/.babashka/bbin/bin"
export BBIN_TEST_HOME=$work/home
# Expanded by the Makes shell, not this test shell.
# shellcheck disable=SC2016
out=$(make --no-pr bbin-test \
  CMD='bb -Duser.home="$$BBIN_TEST_HOME" "$$(command -v bbin)" bin')
has "$out" "$ROOT/local/bin" 'A legacy home installation cannot redirect bbin'

done-testing
