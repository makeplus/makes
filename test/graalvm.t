#!/usr/bin/env bash

source test/init

makefile=$(mktemp)
trap 'rm -f "$makefile"' EXIT

cat > "$makefile" <<MAKE
M := $ROOT
include \$(M)/init.mk
include \$(M)/graalvm.mk

include-check:
	@echo included

graalvm-check: \$(GRAALVM)
MAKE

out=$(
  make --no-print-directory -f "$makefile" \
    OS-NAME=macos ARCH-NAME=int64 include-check
)
is "$out" included "graalvm.mk loads on macOS Intel"

if out=$(
  make --no-print-directory -f "$makefile" \
    OS-NAME=macos ARCH-NAME=int64 graalvm-check 2>&1
); then
  fail "GraalVM target fails on macOS Intel"
else
  pass "GraalVM target fails on macOS Intel"
fi
has "$out" "GraalVM no longer supports macOS Intel"

if [[ -z ${slow-} ]]; then
  pass "Use slow=1 to run slow tests"
  done-testing
  exit 0
fi

# The remaining test needs a supported GraalVM platform.
if [[ $OSTYPE == darwin* && $(uname -m) == x86_64 ]]; then
  pass "Skipping GraalVM install on macOS Intel"
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
