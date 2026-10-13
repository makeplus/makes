#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

makefile=$(mktemp)
install_dir=$(mktemp -d)
trap 'rm -f "$makefile"; rm -rf "$install_dir"' EXIT

cat > "$makefile" <<MAKE
M := $ROOT
include \$(M)/init.mk
include \$(M)/golangci-lint.mk

inspect:
	@printf '%s\n' \
	  'archive=\$(GOLANGCI-LINT-ARC)' \
	  'download=\$(GOLANGCI-LINT-DOWN)' \
	  'executable=\$(GOLANGCI-LINT-EXE)' \
	  'binary=\$(GOLANGCI-LINT)' \
	  'go-loaded=\$(GO-LOADED)'

install: \$(SHELL-DEPS)
	@command -v golangci-lint
	@golangci-lint version
MAKE

check_platform() {
  local os=$1 arch=$2 platform=$3 extension=$4 executable=$5
  local out

  out=$(
    make --no-print-directory -f "$makefile" \
      MAKES_LOCAL_DIR="$install_dir" \
      OS-NAME="$os" ARCH-NAME="$arch" inspect
  )
  has "$out" "archive=golangci-lint-2.14.0-$platform.$extension" \
    "$os-$arch selects the release archive"
  has "$out" "executable=$executable" \
    "$os-$arch selects $executable"
}

check_platform linux arm64 linux-arm64 tar.gz golangci-lint
check_platform linux int64 linux-amd64 tar.gz golangci-lint
check_platform macos arm64 darwin-arm64 tar.gz golangci-lint
check_platform macos int64 darwin-amd64 tar.gz golangci-lint
check_platform windows arm64 windows-arm64 zip golangci-lint.exe
check_platform windows int64 windows-amd64 zip golangci-lint.exe

for version in 1.2.3 v1.2.3; do
  out=$(
    make --no-print-directory -f "$makefile" \
      MAKES_LOCAL_DIR="$install_dir" OS-NAME=linux ARCH-NAME=int64 \
      GOLANGCI-LINT-VERSION="$version" inspect
  )
  has "$out" 'archive=golangci-lint-1.2.3-linux-amd64.tar.gz' \
    "Version $version selects an unprefixed archive version"
  has "$out" \
    'download=https://github.com/golangci/golangci-lint/releases/download/v1.2.3/' \
    "Version $version selects a single v in the release tag"
  has "$out" "binary=$install_dir/golangci-lint-1.2.3/bin/golangci-lint" \
    "Version $version selects the normalized installation path"
done

out=$(
  make --no-print-directory -n -f "$makefile" \
    MAKES_LOCAL_DIR="$install_dir" GO=/unavailable/go \
    GO-VERSION=1.18.10 install
)
has "$out" 'releases/download/v2.14.0/' \
  'Installation downloads the release binary with Go 1.18 selected'
if [[ $out == *'/unavailable/go'* || $out == *'go install'* ]]; then
  fail 'Installation does not build or require Go'
else
  pass 'Installation does not build or require Go'
fi

if [[ -z ${slow-} ]]; then
  pass 'Use slow=1 to run the golangci-lint installation test'
  done-testing
  exit 0
fi

for version in 2.14.0 v2.14.0; do
  out=$(
    make --no-print-directory -f "$makefile" \
      MAKES_LOCAL_DIR="$install_dir" GO=/unavailable/go \
      GO-VERSION=1.18.10 GOLANGCI-LINT-VERSION="$version" install
  )
  has "$out" "$install_dir/golangci-lint-2.14.0/bin/golangci-lint" \
    "Version $version installs in the normalized version directory"
  has "$out" 'golangci-lint has version 2.14.0' \
    "Version $version runs the release binary"
done

for completion in \
  share/bash-completion/completions/golangci-lint \
  share/zsh/site-functions/_golangci-lint \
  share/fish/vendor_completions.d/golangci-lint.fish; do
  if [[ -s $install_dir/$completion ]]; then
    pass "Installed $completion"
  else
    fail "Installed $completion"
  fi
done

done-testing
