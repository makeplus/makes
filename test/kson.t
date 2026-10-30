#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

cat > "$work/Makefile" <<MAKE
M := $ROOT
MAKES_LOCAL_DIR := $work/local
include \$(M)/init.mk
include \$(M)/kson.mk
include \$(M)/kson.mk

inspect:
	@printf '%s\n' \\
	  'kson=\$(KSON)' \\
	  'download=\$(KSON-DOWN)' \\
	  'gradle=\$(GRADLE-VERSION)' \\
	  'supported=\$(KSON-SUPPORTED)' \\
	  'java-loaded=\$(or \$(JAVA-LOADED),false)' \\
	  'kotlin-loaded=\$(or \$(KOTLIN-LOADED),false)' \\
	  'count=\$(words \$(filter \$(KSON),\$(SHELL-DEPS)))'

install: \$(KSON)
MAKE

for platform in linux-int64 linux-arm64 macos-arm64; do
  out=$(make --no-print-directory -f "$work/Makefile" \
    OS-NAME="${platform%-*}" ARCH-NAME="${platform##*-}" inspect)
  has "$out" "supported=$platform" "$platform supports source builds"
done
has "$out" 'gradle=9.4.1' 'KSON defaults to the upstream Gradle version'
has "$out" 'java-loaded=false' 'KSON uses GraalVM without loading ordinary Java'
has "$out" 'kotlin-loaded=false' 'KSON does not install standalone Kotlin'
has "$out" 'count=1' 'Repeated includes add KSON only once'

out=$(make --no-print-directory -f "$work/Makefile" \
  OS-NAME=linux ARCH-NAME=int64 KSON-VERSION=1.2.3 \
  GRADLE-VERSION=9.8.2 inspect)
has "$out" "kson=$work/local/kson-1.2.3/bin/kson" \
  'Version overrides select a separate installation'
has "$out" \
  'download=https://github.com/kson-org/kson/archive/refs/tags/v1.2.3.tar.gz' \
  'Version overrides select tagged sources'
has "$out" 'gradle=9.8.2' 'An explicit Gradle version is retained'

for platform in windows-int64 windows-arm64 macos-int64; do
  out=$(make --no-print-directory -f "$work/Makefile" \
    OS-NAME="${platform%-*}" ARCH-NAME="${platform##*-}" inspect)
  has "$out" 'supported=' "$platform allows module loading"
  if out=$(make --no-print-directory -f "$work/Makefile" \
    OS-NAME="${platform%-*}" ARCH-NAME="${platform##*-}" install 2>&1); then
    fail "$platform rejects installation"
  else
    has "$out" "KSON source builds are unsupported on $platform" \
      "$platform reports unsupported installation before downloading tools"
  fi
done

if [[ -z ${slow-} ]]; then
  pass 'Use slow=1 to run the native KSON build test'
  done-testing
  exit 0
fi

case $OSTYPE:$(uname -m) in
  linux*:x86_64 | linux*:aarch64 | darwin*:arm64) ;;
  *)
    pass 'Skipping native KSON build on an unsupported platform'
    done-testing
    exit 0
    ;;
esac

kson=$ROOT/local/kson-0.3.0/bin/kson
out=$(make --no-pr kson-test CMD='command -v kson')
has "$out" "$ROOT/local/kson-0.3.0/bin/kson" \
  'KSON is installed in its versioned directory'
out=$("$kson" --version)
has "$out" '0.3.0' 'Native KSON reports its release version'

out=$(printf 'answer: 42\n' | env -u JAVA_HOME PATH=/usr/bin:/bin "$kson" json)
has "$out" '"answer": 42' 'Native KSON converts stdin to JSON'
out=$(printf '{"answer":42}\n' | "$kson" format)
has "$out" 'answer: 42' 'Native KSON formats a document'

if out=$(printf '{"answer":\n' | "$kson" json 2>&1); then
  fail 'Invalid input produces a failure exit status'
else
  pass 'Invalid input produces a failure exit status'
fi

if make --no-print-directory -q -f "$work/Makefile" \
  MAKES_LOCAL_DIR="$ROOT/local" "$kson"; then
  pass 'A second installation reuses the completed native executable'
else
  fail 'A second installation reuses the completed native executable'
fi

done-testing
