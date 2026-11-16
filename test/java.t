#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

makefile=$(mktemp)
trap 'rm -f "$makefile"' EXIT

cat > "$makefile" <<MAKE
M := $ROOT
include \$(M)/init.mk
include \$(M)/java.mk

java-url:
	@echo \$(JAVA-DOWN)
MAKE

for version in 27 27.0.1.0.2 27.0.1.0.3; do
  channel=archive
  [[ $version != 27 ]] || channel=latest
  for platform in linux:int64:linux-x64:tar.gz \
    linux:arm64:linux-aarch64:tar.gz \
    macos:arm64:macos-aarch64:tar.gz \
    macos:int64:macos-x64:tar.gz \
    windows:int64:windows-x64:zip; do
    IFS=: read -r os arch package extension <<< "$platform"
    out=$(
      make --no-print-directory -f "$makefile" java-url \
        JAVA-VERSION=$version OS-NAME="$os" ARCH-NAME="$arch"
    )
    expected=https://download.oracle.com/java/27/$channel
    expected=$expected/jdk-${version}_${package}_bin.$extension
    is "$out" "$expected" "Java $version URL for $os $arch"
  done
done

if [[ -z ${slow-} ]]; then
  pass "Use slow=1 to run slow tests"
  done-testing
  exit 0
fi

out=$(
  make --no-pr java-test CMD='which java; java --version'
)

has "$out" "$ROOT/local/jdk-" "Found java in local/jdk"

has "$out" "jdk" "java --version shows jdk"

done-testing
