#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

cat > "$work/Makefile" <<MAKE
M := $ROOT
MAKES_LOCAL_DIR := $ROOT/local
include \$(M)/init.mk
include \$(M)/fsharp.mk
include \$(M)/fsharp.mk

inspect:
	@printf '%s\n' \
	  'fsharp=\$(FSHARP)' \
	  'csharp=\$(CSHARP)' \
	  'dotnet=\$(DOTNET)' \
	  'deps=\$(SHELL-DEPS)'
MAKE

out=$(make --no-print-directory -f "$work/Makefile" inspect)
fsharp=$(printf '%s\n' "$out" | perl -ne 'print $1 if /^fsharp=(.*)/')
csharp=$(printf '%s\n' "$out" | perl -ne 'print $1 if /^csharp=(.*)/')
dotnet=$(printf '%s\n' "$out" | perl -ne 'print $1 if /^dotnet=(.*)/')
is "$fsharp" "$csharp" 'F# uses the C# facade'
is "$csharp" "$dotnet" 'The C# facade provides the managed .NET SDK'
has "$out" "deps=$dotnet" 'The .NET SDK is the only shell dependency'

if [[ -z ${slow-} ]]; then
  pass 'Use slow=1 to run the F# compilation test'
  done-testing
  exit 0
fi

project=$work/project
out=$(make --no-pr fsharp-test \
  CMD="dotnet new console --language 'F#' --output '$project' && \
    dotnet run --project '$project'")
has "$out" 'Hello from F#' 'F# compiles and runs'

done-testing
