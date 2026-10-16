#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

unset BABASHKA_BBIN_DIR BABASHKA_BBIN_BIN_DIR BABASHKA_BBIN_JARS_DIR

if [[ $OSTYPE == msys* || $OSTYPE == cygwin* ]]; then
  pass "Skipping bbin.t on Windows"
  done-testing
  exit 0
fi

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
	  "bin=\$\${BABASHKA_BBIN_BIN_DIR-unset}" \
	  "jars=\$\${BABASHKA_BBIN_JARS_DIR-unset}" \
	  "legacy=\$\${BABASHKA_BBIN_DIR-unset}"
MAKE

out=$(make --no-print-directory -f "$work/Makefile" \
  BBIN-VERSION=9.8.7 inspect)
has "$out" 'download=https://raw.githubusercontent.com/babashka/bbin/v9.8.7/bbin' \
  'Version override selects the tagged script'
has "$out" 'cache=bbin-9.8.7' 'Download cache includes the version'
has "$out" "executable=$ROOT/local/bbin-9.8.7/bin/bbin" \
  'Executable has a versioned installation directory'
has "$out" 'bin=unset' 'Application directory keeps the upstream default'
has "$out" 'jars=unset' 'JAR directory keeps the upstream default'
has "$out" 'legacy=unset' 'Legacy directory keeps the upstream default'
has "$out" 'deps='"$ROOT/local/babashka-" \
  'Babashka is a shell dependency'
has "$out" "$ROOT/local/jdk-" 'Java is supplied'
deps=$(printf '%s\n' "$out" | while IFS= read -r line; do
  [[ $line != deps=* ]] || printf '%s' "${line#deps=}"
done)
read -r -a dep_list <<< "$deps"
declare -A unique_deps=()
for dep in "${dep_list[@]}"; do
  unique_deps[$dep]=1
done
is "${#dep_list[@]}" "${#unique_deps[@]}" \
  'Repeated includes do not duplicate shell dependencies'

out=$(make --no-print-directory -f "$work/Makefile" \
  PRELOAD="$ROOT/graalvm.mk" inspect)
has "$out" "java=$ROOT/local/graalvm-" 'An existing GraalVM supplies Java'

out=$(BABASHKA_BBIN_BIN_DIR="$work/custom bin" \
  BABASHKA_BBIN_JARS_DIR="$work/custom jars" \
  BABASHKA_BBIN_DIR="$work/custom legacy" \
  make --no-print-directory -f "$work/Makefile" inspect)
has "$out" "bin=$work/custom bin" \
  'Caller can override the application directory'
has "$out" "jars=$work/custom jars" 'Caller can override the JAR directory'
has "$out" "legacy=$work/custom legacy" \
  'Caller can override the legacy directory'

if [[ -z ${slow-} ]]; then
  pass 'Use slow=1 to run the bbin installation tests'
  done-testing
  exit 0
fi

# Keep runtime dependency caches and bbin's default paths inside the test.
export BBIN_TEST_HOME=$work/home
export CLJ_CONFIG=$work/clojure
export CLJ_CACHE=$work/clj-cache
export XDG_CACHE_HOME=$work/cache
unset XDG_DATA_HOME
export BABASHKA_PRELOADS='
(System/setProperty "user.home" (System/getenv "BBIN_TEST_HOME"))'
mkdir -p "$BBIN_TEST_HOME" "$CLJ_CONFIG"

out=$(make --no-pr bbin-test CMD='command -v bbin; bbin version; bbin bin')
has "$out" "$ROOT/local/bbin-" 'Found the managed bbin executable'
has "$out" 'bbin 0.' 'bbin runs with managed dependencies'
has "$out" "$work/home/.local/bin" \
  'bbin reports the default application directory'

out=$(BABASHKA_BBIN_BIN_DIR="$work/custom bin" make --no-pr bbin-test \
  CMD='bbin bin')
has "$out" "$work/custom bin" 'bbin honors the caller application directory'

mkdir -p "$work/home/.babashka/bbin/bin"
out=$(make --no-pr bbin-test CMD='bbin bin')
has "$out" "$work/home/.babashka/bbin/bin" \
  'bbin honors existing legacy installations'

done-testing
