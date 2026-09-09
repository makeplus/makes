#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

check-platform() {
  local os=$1 arch=$2 suffix=$3 ghc_suffix=$4
  local out before after url_before url_after
  local archive=cabal-install-3.18.1.0-$suffix
  out=$(make --no-print-directory -f test/cabal.mk inspect \
    OS-NAME="$os" ARCH-NAME="$arch" CABAL-VERSION=3.18.1.0 GHC-VERSION=9.12.1)
  has "$out" "archive=$archive" "$os-$arch: published archive name"
  has "$out" \
    "download=https://downloads.haskell.org/~cabal/cabal-install-3.18.1.0/$archive" \
    "$os-$arch: published download URL"
  before=$(printf '%s\n' "$out" | perl -ne 'print $1 if /^ghc-before=(.*)/')
  after=$(printf '%s\n' "$out" | perl -ne 'print $1 if /^ghc-after=(.*)/')
  url_before=$(printf '%s\n' "$out" | perl -ne 'print $1 if /^ghc-url-before=(.*)/')
  url_after=$(printf '%s\n' "$out" | perl -ne 'print $1 if /^ghc-url-after=(.*)/')
  is "$after" "$before" "$os-$arch: GHC archive is unchanged"
  is "$url_after" "$url_before" "$os-$arch: GHC download is unchanged"
  is "$after" "ghc-9.12.1-$ghc_suffix.tar.xz" \
    "$os-$arch: published GHC archive ignores unrelated platform mappings"
}

check-platform linux int64 x86_64-linux-unknown.tar.xz x86_64-ubuntu22_04-linux
check-platform linux arm64 aarch64-linux-unknown.tar.xz aarch64-deb12-linux
check-platform macos int64 x86_64-apple-darwin.tar.xz x86_64-apple-darwin
check-platform macos arm64 aarch64-apple-darwin.tar.xz aarch64-apple-darwin
check-platform windows int64 x86_64-mingw64.zip x86_64-unknown-mingw32

out=$(make --no-print-directory -f test/cabal.mk inspect \
  GHC-TAR=custom-ghc.tar.xz)
has "$out" 'ghc-after=custom-ghc.tar.xz' 'Explicit GHC archive override is retained'

out=$(make --no-print-directory -f test/cabal.mk inspect TEST-CARP=1 \
  OS-NAME=linux ARCH-NAME=int64 CABAL-VERSION=3.18.1.0)
has "$out" 'archive=cabal-install-3.18.1.0-x86_64-linux-unknown.tar.xz' \
  'Carp inherits the corrected Cabal archive'
has "$out" 'ghc-after=ghc-9.6.6-x86_64-deb11-linux.tar.xz' \
  'Carp preserves its pinned GHC archive'

if [[ -n ${slow-} ]]; then
  out=$(make --no-print-directory -f test/cabal.mk install-cabal)
  has "$out" 'cabal-install version 3.18.1.0' 'Cabal installs and runs'
fi

done-testing
