#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

cat > "$work/Makefile" <<MAKE
M := $ROOT
MAKES_LOCAL_DIR := $ROOT/local
include \$(M)/init.mk
include \$(M)/csharp.mk
include \$(M)/csharp.mk

inspect:
	@printf '%s\n' \
	  'csharp=\$(CSHARP)' \
	  'dotnet=\$(DOTNET)' \
	  'deps=\$(SHELL-DEPS)' \
	  'home='\$\$DOTNET_CLI_HOME \
	  'packages='\$\$NUGET_PACKAGES
MAKE

out=$(make --no-print-directory -f "$work/Makefile" inspect)
csharp=$(printf '%s\n' "$out" | perl -ne 'print $1 if /^csharp=(.*)/')
dotnet=$(printf '%s\n' "$out" | perl -ne 'print $1 if /^dotnet=(.*)/')
is "$csharp" "$dotnet" 'C# uses the managed .NET SDK'
has "$out" "deps=$dotnet" 'The .NET SDK is the only shell dependency'
has "$out" "home=$ROOT/local/cache/dotnet-home" \
  '.NET CLI state stays local'
has "$out" "packages=$ROOT/local/cache/nuget-packages" \
  'NuGet packages stay local'

if [[ -z ${slow-} ]]; then
  pass 'Use slow=1 to run the C# compilation test'
  done-testing
  exit 0
fi

project=$work/project
out=$(make --no-pr csharp-test \
  CMD="dotnet new console --language 'C#' --output '$project' && \
    dotnet run --project '$project'")
has "$out" 'Hello, World!' 'C# compiles and runs'

done-testing
