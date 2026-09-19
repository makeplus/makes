#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

cat > "$work/Makefile" <<MAKE
M := $ROOT
MAKES_LOCAL_DIR := $work/local
include \$(M)/init.mk
include \$(M)/tiny-go.mk
include \$(M)/tinygo.mk

inspect:
	@printf '%s\n' \
	  'archive=\$(TINYGO-ARC)' \
	  'deps=\$(SHELL-DEPS)' \
	  'download=\$(TINYGO-DOWN)' \
	  'executable=\$(TINYGO-EXE)' \
	  'tinygo=\$(TINYGO)' \
	  'version=\$(TINYGO-VERSION)'

compile: \$(TINYGO)
	@command -v tinygo
	@tinygo version
	@tinygo build -target=wasi -o \$(OUTPUT) \$(SOURCE)
	@test -s \$(OUTPUT) && printf 'compiled-wasi\n'
MAKE

check_platform() {
  local os=$1 arch=$2 archive=$3 executable=$4
  local out

  out=$(
    make --no-print-directory -f "$work/Makefile" \
      OS-NAME="$os" ARCH-NAME="$arch" inspect
  )
  has "$out" "archive=$archive" "$os-$arch selects $archive"
  has "$out" "executable=$executable" \
    "$os-$arch selects $executable"
}

check_platform linux arm64 \
  tinygo0.42.0.linux-arm64.tar.gz tinygo
check_platform linux int64 \
  tinygo0.42.0.linux-amd64.tar.gz tinygo
check_platform macos arm64 \
  tinygo0.42.0.darwin-arm64.tar.gz tinygo
check_platform macos int64 \
  tinygo0.42.0.darwin-amd64.tar.gz tinygo
check_platform windows int64 \
  tinygo0.42.0.windows-amd64.zip tinygo.exe

out=$(
  make --no-print-directory -f "$work/Makefile" \
    OS-NAME=linux ARCH-NAME=int64 TINYGO-VERSION=1.2.3 inspect
)
has "$out" 'archive=tinygo1.2.3.linux-amd64.tar.gz' \
  'TINYGO-VERSION selects the archive version'
has "$out" \
  'download=https://github.com/tinygo-org/tinygo/releases/download/v1.2.3/' \
  'TINYGO-VERSION selects the download version'
has "$out" 'tinygo='"$work"'/local/tinygo-1.2.3/bin/tinygo' \
  'TINYGO-VERSION selects a separate installation'

deps=$(printf '%s\n' "$out" | perl -ne 'print $1 if /^deps=(.*)/')
is "$(wc -w <<< "$deps" | tr -d ' ')" 1 \
  'The compatibility include does not duplicate shell dependencies'

if out=$(
  make --no-print-directory -f "$work/Makefile" \
    OS-NAME=windows ARCH-NAME=arm64 inspect 2>&1
); then
  fail 'Windows arm64 fails without an upstream release asset'
else
  has "$out" \
    "'tinygo' has no prebuilt binary for windows-arm64" \
    'Windows arm64 reports the missing upstream release asset'
fi

if [[ -z ${slow-} ]]; then
  pass 'Use slow=1 to run the TinyGo compilation test'
  done-testing
  exit 0
fi

source_file=$work/main.go
output_file=$work/main.wasm
printf 'package main\nfunc main() {}\n' > "$source_file"
out=$(make --no-print-directory -f "$work/Makefile" \
  SOURCE="$source_file" OUTPUT="$output_file" compile)
has "$out" "$work/local/tinygo-0.42.0/bin/tinygo" \
  'Found TinyGo in the versioned local installation'
has "$out" 'tinygo version 0.42.0' 'Found TinyGo version 0.42.0'
has "$out" 'compiled-wasi' 'TinyGo compiles a WASI program'

done-testing
