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
  ysd-0.1.3-linux_amd64.tar.gz ysd
check_platform macos arm64 \
  ysd-0.1.3-darwin_arm64.tar.gz ysd
check_platform windows int64 \
  ysd-0.1.3-windows_amd64.zip ysd.exe

out=$(
  make --no-print-directory -f "$makefile" \
    OS-NAME=linux ARCH-NAME=int64 \
    YAMLSCHEMA-VERSION=9.8.7 inspect
)
has "$out" 'archive=ysd-9.8.7-linux_amd64.tar.gz' \
  'YAMLSCHEMA-VERSION overrides the archive version'
has "$out" 'version=9.8.7' \
  'YAMLSCHEMA-VERSION overrides the module version'

if out=$(
  make --no-print-directory -f "$makefile" \
    OS-NAME=linux ARCH-NAME=arm64 inspect 2>&1
); then
  fail 'Linux ARM is rejected'
else
  pass 'Linux ARM is rejected'
fi
has "$out" "'YAMLSchema' has no prebuilt binary for linux-arm64"

if [[ -z ${slow-} ]]; then
  pass 'Use slow=1 to run the YAMLSchema installation test'
  done-testing
  exit 0
fi

out=$(
  make --no-pr yamlschema-test CMD='which ysd; ysd --version'
)
has "$out" "$ROOT/local/yamlschema-0.1.3/bin/ysd" \
  'Found ysd in local/yamlschema-0.1.3'
has "$out" 'ysd 0.1.3' 'Found YAMLSchema version 0.1.3'

done-testing
