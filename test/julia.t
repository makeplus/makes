#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
local=$work/local

cat > "$work/Makefile" <<MAKE
M := $ROOT
MAKES_LOCAL_DIR := $local
include \$(M)/init.mk
include \$(M)/julia.mk

inspect:
	@printf '%s\n' \
	  'series=\$(JULIA-VER)' \
	  'download=\$(JULIA-DOWN)'
MAKE

out=$(make --no-print-directory -f "$work/Makefile" \
  JULIA-VERSION=9.8.7 inspect)
has "$out" 'series=9.8' \
  'Download series follows the selected Julia version'
has "$out" '/9.8/julia-9.8.7-' \
  'Download URL uses the matching Julia series'

out=$(make --no-print-directory -f "$work/Makefile" \
  JULIA-VERSION=9.8.7 JULIA-VER=preview inspect)
has "$out" 'series=preview' \
  'Download series can still be overridden'

done-testing
