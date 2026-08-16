#!/usr/bin/env bash

source test/init

makefile=$(mktemp)
trap 'rm -f "$makefile"' EXIT

cat > "$makefile" <<MAKE
M := $ROOT
include \$(M)/init.mk
include \$(M)/cljgo.mk

inspect:
	@printf '%s\n' 'archive=\$(CLJGO-ARC)' 'executable=\$(CLJGO-EXE)'
MAKE

check_platform() {
  local os=$1 arch=$2 archive=$3 executable=$4
  local out

  out=$(
    make --no-print-directory -f "$makefile" \
      OS-NAME="$os" ARCH-NAME="$arch" inspect
  )
  has "$out" "archive=$archive" "$os-$arch selects $archive"
  has "$out" "executable=$executable" "$os-$arch selects $executable"
}

check_platform linux arm64 \
  cljgo_0.9.0_linux_arm64.tar.gz cljgo
check_platform linux int64 \
  cljgo_0.9.0_linux_amd64.tar.gz cljgo
check_platform macos arm64 \
  cljgo_0.9.0_darwin_arm64.tar.gz cljgo
check_platform macos int64 \
  cljgo_0.9.0_darwin_amd64.tar.gz cljgo
check_platform windows arm64 \
  cljgo_0.9.0_windows_arm64.zip cljgo.exe
check_platform windows int64 \
  cljgo_0.9.0_windows_amd64.zip cljgo.exe

if [[ -z ${slow-} ]]; then
  pass "Use slow=1 to run the cljgo installation test"
  done-testing
  exit 0
fi

out=$(
  make --no-pr cljgo-test \
    CMD='which cljgo; cljgo --version; printf "(+ 1 2)\n" | cljgo repl'
)

has "$out" "$ROOT/local/cljgo-0.9.0/bin/cljgo" \
  "Found cljgo in local/cljgo"
has "$out" "cljgo CLI version 0.9.0" \
  "Found cljgo version"
has "$out" $'\n3' \
  "cljgo REPL evaluates an expression"

done-testing
