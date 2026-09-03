#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

makefile=$(mktemp)
trap 'rm -f "$makefile"' EXIT

cat > "$makefile" <<MAKE
M := $ROOT
include \$(M)/init.mk
include \$(M)/libyamlstar.mk

inspect:
	@printf '%s\n' \
	  'archive=\$(LIBYAMLSTAR-ARC)' \
	  'download=\$(LIBYAMLSTAR-DOWN)' \
	  'library=\$(LIBYAMLSTAR-FILE)' \
	  'version=\$(LIBYAMLSTAR-VERSION)'
MAKE

check_platform() {
  local os=$1 arch=$2 archive=$3 library=$4
  local out

  out=$(
    make --no-print-directory -f "$makefile" \
      OS-NAME="$os" ARCH-NAME="$arch" inspect
  )
  has "$out" "archive=$archive" "$os-$arch selects $archive"
  has "$out" "library=$library" \
    "$os-$arch selects $library"
}

check_platform linux int64 \
  libyamlstar-0.1.19-linux-x64.tar.xz libyamlstar.so
check_platform linux arm64 \
  libyamlstar-0.1.19-linux-aarch64.tar.xz libyamlstar.so
check_platform macos int64 \
  libyamlstar-0.1.19-macos-x64.tar.xz libyamlstar.dylib
check_platform macos arm64 \
  libyamlstar-0.1.19-macos-arm64.tar.xz libyamlstar.dylib
check_platform windows int64 \
  libyamlstar-0.1.19-windows-x64.zip libyamlstar.dll
check_platform windows arm64 \
  libyamlstar-0.1.19-windows-arm64.zip libyamlstar.dll

out=$(
  make --no-print-directory -f "$makefile" \
    OS-NAME=linux ARCH-NAME=int64 \
    LIBYAMLSTAR-VERSION=9.8.7 inspect
)
has "$out" 'archive=libyamlstar-9.8.7-linux-x64.tar.xz' \
  'LIBYAMLSTAR-VERSION overrides the archive version'
has "$out" \
  'download=https://github.com/yaml/yamlstar/releases/download/9.8.7/' \
  'LIBYAMLSTAR-VERSION overrides the download version'
has "$out" 'version=9.8.7' \
  'LIBYAMLSTAR-VERSION overrides the module version'

if [[ -z ${slow-} ]]; then
  pass 'Use slow=1 to run the libyamlstar installation test'
  done-testing
  exit 0
fi

make --no-pr libyamlstar-test CMD=true

library=$ROOT/local/lib/libyamlstar.so
if [[ -s $library ]]; then
  pass "Installed $library"
else
  fail "Installed $library"
fi

done-testing
