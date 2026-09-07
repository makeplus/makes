#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

makefile=$(mktemp)
trap 'rm -f "$makefile"' EXIT

cat > "$makefile" <<MAKE
M := $ROOT
include \$(M)/init.mk
include \$(M)/arturo.mk

inspect:
	@printf '%s\n' \
	  'archive=\$(ARTURO-ZIP)' \
	  'download=\$(ARTURO-DOWN)' \
	  'executable=\$(notdir \$(ARTURO))' \
	  'version=\$(ARTURO-VERSION)'
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

check_platform linux int64 \
  arturo-0.10.0-linux-amd64.zip arturo
check_platform linux arm64 \
  arturo-0.10.0-linux-arm64-mini.zip arturo
check_platform macos int64 \
  arturo-0.10.0-macos-amd64.zip arturo
check_platform macos arm64 \
  arturo-0.10.0-macos-arm64-mini.zip arturo
check_platform windows int64 \
  arturo-0.10.0-windows-amd64.zip arturo.exe

out=$(
  make --no-print-directory -f "$makefile" \
    OS-NAME=linux ARCH-NAME=int64 ARTURO-VERSION=9.8.7 inspect
)
has "$out" 'archive=arturo-9.8.7-linux-amd64.zip' \
  'ARTURO-VERSION overrides the archive version'
expected=https://github.com/arturo-lang/arturo/releases/download
expected=$expected/v9.8.7/arturo-9.8.7-linux-amd64.zip
has "$out" "download=$expected" \
  'ARTURO-VERSION overrides the download version'
has "$out" 'version=9.8.7' \
  'ARTURO-VERSION overrides the module version'

done-testing
