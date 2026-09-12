#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

cat > "$work/Makefile" <<MAKE
M := $ROOT
MAKES_LOCAL_DIR := $ROOT/local
include \$(M)/init.mk
include \$(M)/cljr.mk
include \$(M)/cljr.mk

inspect:
	@printf '%s\n' \
	  'executable=\$(CLJR)' \
	  'dotnet=\$(DOTNET)' \
	  'deps=\$(SHELL-DEPS)' \
	  'home='\$\$DOTNET_CLI_HOME \
	  'packages='\$\$NUGET_PACKAGES \
	  'path=\$(PATH)'
MAKE

out=$(make --no-print-directory -f "$work/Makefile" \
  CLJR-VERSION=9.8.7 inspect)
has "$out" \
  "executable=$ROOT/local/cljr-9.8.7/bin/cljr" \
  'Version override selects a separate installation'
has "$out" "dotnet=$ROOT/local/dotnet-sdk-" \
  'ClojureCLR includes the managed .NET SDK'
has "$out" "home=$ROOT/local/cache/dotnet-home" \
  '.NET CLI state stays local'
has "$out" "packages=$ROOT/local/cache/nuget-packages" \
  'NuGet packages stay local'
has "$out" "path=$ROOT/local/cljr-9.8.7/bin:" \
  'ClojureCLR is on PATH'
deps=$(printf '%s\n' "$out" | while IFS= read -r line; do
  [[ $line != deps=* ]] || printf '%s' "${line#deps=}"
done)
is "$(wc -w <<< "$deps" | tr -d ' ')" 2 \
  'Repeated includes do not duplicate shell dependencies'

out=$(make --no-print-directory -f "$work/Makefile" \
  OS-NAME=windows ARCH-NAME=int64 inspect)
has "$out" '/bin/cljr.exe' \
  'Windows selects the executable suffix'

out=$(make --no-print-directory -n -f "$work/Makefile" \
  CLJR-VERSION=9.8.7 \
  "$ROOT/local/cljr-9.8.7/bin/cljr")
has "$out" \
  'dotnet tool install' \
  'Installation uses the managed .NET SDK'
has "$out" \
  "--tool-path $ROOT/local/cljr-9.8.7/bin" \
  'Installation uses a local .NET tool path'
has "$out" \
  '--version 9.8.7 Clojure.Main' \
  'Installation pins the requested NuGet package version'
has "$out" \
  '/bin/Clojure.Main' \
  'Installation renames the upstream tool shim'

if [[ -z ${slow-} ]]; then
  pass 'Use slow=1 to run the ClojureCLR installation test'
  done-testing
  exit 0
fi

out=$(make --no-pr cljr-test \
  CMD='command -v cljr; printf "(+ 20 22)\n" | cljr')
has "$out" "$ROOT/local/cljr-1.12.6/bin/cljr" \
  'Found the managed ClojureCLR executable'
has "$out" 'Clojure 1.12.6' 'Found the ClojureCLR version'
has "$out" 'user=> 42' 'ClojureCLR evaluates an expression'

done-testing
