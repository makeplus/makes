#!/usr/bin/env bash

# Keep every advertised shell-support module on the standard target contract.

# shellcheck disable=SC1091
source test/init

completion_tools=(
  alire asdf bbin buf bun cairo cmake crystal defang dotnet gh ghc gloat
  golangci-lint groovy hcloud helm jolt just k3d lein lgx luarocks nono
  ocaml pandoc phel pulumi rebar3 rg rust scala task uv vlang wasmtime
  yamlschema yq
)

man_tools=(
  buf clojure cmake crystal dotnet erlang fennel futhark gh gloat graalvm
  hcloud helm janet java jq lua nim node pandoc powershell prolog rg
  shellcheck swift yamlschema yq
)

for tool in "${completion_tools[@]}"; do
  prefix=$(printf '%s' "$tool" | tr '[:lower:]' '[:upper:]')
  file=$ROOT/$tool.mk
  source=$(< "$file")
  has "$source" "$prefix-COMP :=" \
    "$tool defines an aggregate completion target"
  has "$source" "\$($prefix-COMP)" \
    "$tool installs its aggregate completion target"
done

for tool in "${man_tools[@]}"; do
  prefix=$(printf '%s' "$tool" | tr '[:lower:]' '[:upper:]')
  file=$ROOT/$tool.mk
  source=$(< "$file")
  has "$source" "$prefix-MAN :=" \
    "$tool defines a manual target"
  has "$source" "\$($prefix-MAN)" \
    "$tool installs its manual target"
done

done-testing
