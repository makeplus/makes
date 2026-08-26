#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

makefile=$(mktemp)
trap 'rm -f "$makefile"' EXIT

cat > "$makefile" <<MAKE
M := $ROOT
include \$(M)/init.mk
include \$(M)/yamlschema.mk

inspect:
	@printf '%s\n' \
	  'archive=\$(YAMLSCHEMA-ARC)' \
	  'executable=\$(YAMLSCHEMA-EXE)' \
	  'version=\$(YAMLSCHEMA-VERSION)'
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
  ysd-0.1.5-linux_amd64.tar.gz ysd
check_platform linux arm64 \
  ysd-0.1.5-linux_arm64.tar.gz ysd
check_platform macos arm64 \
  ysd-0.1.5-darwin_arm64.tar.gz ysd
check_platform windows int64 \
  ysd-0.1.5-windows_amd64.zip ysd.exe
check_platform windows arm64 \
  ysd-0.1.5-windows_arm64.zip ysd.exe

out=$(
  make --no-print-directory -f "$makefile" \
    OS-NAME=linux ARCH-NAME=int64 \
    YAMLSCHEMA-VERSION=9.8.7 inspect
)
has "$out" 'archive=ysd-9.8.7-linux_amd64.tar.gz' \
  'YAMLSCHEMA-VERSION overrides the archive version'
has "$out" 'version=9.8.7' \
  'YAMLSCHEMA-VERSION overrides the module version'

if [[ -z ${slow-} ]]; then
  pass 'Use slow=1 to run the YAMLSchema installation test'
  done-testing
  exit 0
fi

out=$(
  make --no-pr yamlschema-test CMD='which ysd; ysd --version'
)
has "$out" "$ROOT/local/yamlschema-0.1.5/bin/ysd" \
  'Found ysd in local/yamlschema-0.1.5'
has "$out" 'ysd 0.1.5' 'Found YAMLSchema version 0.1.5'

done-testing
