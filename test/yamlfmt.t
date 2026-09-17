#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

makefile=$(mktemp)
trap 'rm -f "$makefile"' EXIT

cat > "$makefile" <<MAKE
M := $ROOT
include \$(M)/init.mk
include \$(M)/yamlfmt.mk

inspect:
	@printf '%s\n' \
	  'archive=\$(YAMLFMT-ARC)' \
	  'download=\$(YAMLFMT-DOWN)' \
	  'executable=\$(YAMLFMT-EXE)'
MAKE

check_platform() {
  local os=$1 arch=$2 archive=$3 executable=$4
  local out

  out=$(
    make --no-print-directory -f "$makefile" \
      OS-NAME="$os" ARCH-NAME="$arch" inspect
  )
  has "$out" "archive=$archive" "$os-$arch selects $archive"
  has "$out" "executable=$executable" \
    "$os-$arch selects $executable"
}

check_platform linux arm64 yamlfmt_0.21.0_Linux_arm64.tar.gz yamlfmt
check_platform linux int64 yamlfmt_0.21.0_Linux_x86_64.tar.gz yamlfmt
check_platform macos arm64 yamlfmt_0.21.0_Darwin_arm64.tar.gz yamlfmt
check_platform macos int64 yamlfmt_0.21.0_Darwin_x86_64.tar.gz yamlfmt
check_platform windows arm64 yamlfmt_0.21.0_Windows_arm64.tar.gz yamlfmt.exe
check_platform windows int64 yamlfmt_0.21.0_Windows_x86_64.tar.gz yamlfmt.exe

out=$(
  make --no-print-directory -f "$makefile" \
    OS-NAME=linux ARCH-NAME=int64 YAMLFMT-VERSION=1.2.3 inspect
)
has "$out" 'archive=yamlfmt_1.2.3_Linux_x86_64.tar.gz' \
  'YAMLFMT-VERSION selects the archive version'
has "$out" \
  'download=https://github.com/google/yamlfmt/releases/download/v1.2.3/' \
  'YAMLFMT-VERSION selects the download version'

if [[ -z ${slow-} ]]; then
  pass 'Use slow=1 to run the yamlfmt installation test'
  done-testing
  exit 0
fi

out=$(
  make --no-pr yamlfmt-test CMD='which yamlfmt; yamlfmt -version'
)
has "$out" "$ROOT/local/yamlfmt-0.21.0/bin/yamlfmt" \
  'Found yamlfmt in local/yamlfmt-0.21.0'
has "$out" '0.21.0' 'Found yamlfmt version'

out=$(
  printf 'a:  1\n' | "$ROOT/local/yamlfmt-0.21.0/bin/yamlfmt" -in
)
is "$out" 'a: 1' 'yamlfmt formats stdin to stdout'

done-testing
