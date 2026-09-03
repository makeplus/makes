#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

makefile=$(mktemp)
trap 'rm -f "$makefile"' EXIT

cat > "$makefile" <<MAKE
M := $ROOT
include \$(M)/init.mk
include \$(M)/yamlstar.mk

inspect:
	@printf '%s\n' \
	  'archive=\$(YAMLSTAR-ARC)' \
	  'download=\$(YAMLSTAR-DOWN)' \
	  'executable=\$(YAMLSTAR-EXE)' \
	  'version=\$(YAMLSTAR-VERSION)'
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
  yamlstar-0.1.19-linux-x64.tar.xz yaml
check_platform linux arm64 \
  yamlstar-0.1.19-linux-aarch64.tar.xz yaml
check_platform macos int64 \
  yamlstar-0.1.19-macos-x64.tar.xz yaml
check_platform macos arm64 \
  yamlstar-0.1.19-macos-arm64.tar.xz yaml
check_platform windows int64 \
  yamlstar-0.1.19-windows-x64.zip yaml.exe
check_platform windows arm64 \
  yamlstar-0.1.19-windows-arm64.zip yaml.exe

out=$(
  make --no-print-directory -f "$makefile" \
    OS-NAME=linux ARCH-NAME=int64 YAMLSTAR-VERSION=9.8.7 inspect
)
has "$out" 'archive=yamlstar-9.8.7-linux-x64.tar.xz' \
  'YAMLSTAR-VERSION overrides the archive version'
has "$out" \
  'download=https://github.com/yaml/yamlstar/releases/download/9.8.7/' \
  'YAMLSTAR-VERSION overrides the download version'
has "$out" 'version=9.8.7' \
  'YAMLSTAR-VERSION overrides the module version'

yamlstar_version=$(
  make --no-print-directory -f "$makefile" \
    OS-NAME=linux ARCH-NAME=int64 inspect |
    while IFS='=' read -r key value; do
      if [[ $key == version ]]; then
        printf '%s\n' "$value"
      fi
    done
)

if [[ -z ${slow-} ]]; then
  pass 'Use slow=1 to run the YAMLStar installation test'
  done-testing
  exit 0
fi

out=$(
  make --no-pr yamlstar-test CMD='which yaml; yaml --version'
)
has "$out" "$ROOT/local/yamlstar-$yamlstar_version/bin/yaml" \
  "Found yaml in local/yamlstar-$yamlstar_version"
has "$out" "$yamlstar_version" \
  "Found YAMLStar version $yamlstar_version"

out=$(
  printf '%s\n' 'foo: bar' |
    "$ROOT/local/yamlstar-$yamlstar_version/bin/yaml"
)
is "$out" '{"foo":"bar"}' 'yaml loads YAML from stdin'

done-testing
