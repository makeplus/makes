#!/usr/bin/env bash

source test/init

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

case $OSTYPE in
  msys*|cygwin*) exe=.exe ;;
  *) exe= ;;
esac

make_fake() {
  local file=$1 version=$2 identity=$3

  cat > "$file" <<FAKE
#!/usr/bin/env bash
case \${1-} in
  --version)
    printf '%s\n' '$version'
    ;;
  -q)
    cat >/dev/null
    printf '%s\n' '$identity'
    ;;
  *)
    exit 1
    ;;
esac
FAKE
  chmod +x "$file"
}

make_inspector() {
  local root=$1 makefile=$2

  cat > "$makefile" <<MAKE
M := $ROOT
MAKES_LOCAL_DIR := $root/local
include \$(M)/init.mk
include \$(M)/chezscheme.mk

inspect:
	@printf '%s\n' \
	  'chez=\$(CHEZSCHEME)' \
	  'petite=\$(PETITE-CHEZSCHEME)' \
	  'gcc-origin=\$(origin GCC-LOADED)' \
	  'local-origin=\$(origin LOCAL-LOADED)'
MAKE
}

matching=$tmp/matching
mkdir -p "$matching"
make_fake \
  "$matching/chez$exe" \
  10.4.1 \
  'Chez Scheme Version 10.4.1'
make_fake \
  "$matching/petite$exe" \
  10.4.1 \
  'Petite Chez Scheme Version 10.4.1'
make_inspector "$tmp/matching-root" "$tmp/matching.mk"

out=$(
  PATH="$matching:$PATH" \
    make --no-print-directory -f "$tmp/matching.mk" inspect
)
has "$out" "chez=$matching/chez$exe" \
  "matching system Chez is reused"
has "$out" "petite=$matching/petite$exe" \
  "matching system Petite is reused"
has "$out" "gcc-origin=undefined" \
  "system Chez does not load gcc.mk"
has "$out" "local-origin=undefined" \
  "system Chez does not load local.mk"

ordered=$tmp/ordered
mkdir -p "$ordered"
make_fake \
  "$ordered/chez$exe" \
  10.4.0 \
  'Chez Scheme Version 10.4.0'
make_fake \
  "$ordered/chezscheme$exe" \
  10.4.1 \
  'Not Chez Scheme 10.4.1'
make_fake \
  "$ordered/scheme$exe" \
  10.4.1 \
  'Chez Scheme Version 10.4.1'
make_fake \
  "$ordered/petite$exe" \
  10.4.1 \
  'Petite Chez Scheme Version 10.4.1'
make_inspector "$tmp/ordered-root" "$tmp/ordered.mk"

out=$(
  PATH="$ordered:$PATH" \
    make --no-print-directory -f "$tmp/ordered.mk" inspect
)
has "$out" "chez=$ordered/scheme$exe" \
  "lookup continues to a valid later command"

incomplete=$tmp/incomplete
mkdir -p "$incomplete"
make_fake \
  "$incomplete/chez$exe" \
  10.4.1 \
  'Chez Scheme Version 10.4.1'
make_fake \
  "$incomplete/chezscheme$exe" \
  10.4.1 \
  'Not Chez Scheme 10.4.1'
make_fake \
  "$incomplete/scheme$exe" \
  10.4.1 \
  'Not Chez Scheme 10.4.1'
make_fake \
  "$incomplete/petite$exe" \
  10.4.0 \
  'Petite Chez Scheme Version 10.4.0'
make_inspector "$tmp/incomplete-root" "$tmp/incomplete.mk"

out=$(
  PATH="$incomplete:$PATH" \
    make --no-print-directory -f "$tmp/incomplete.mk" inspect
)
has "$out" "chez=$tmp/incomplete-root/local/chezscheme-10.4.1/bin/scheme$exe" \
  "incomplete system installation selects local Chez"
has "$out" "gcc-origin=file" \
  "local fallback loads gcc.mk"
has "$out" "local-origin=file" \
  "local fallback loads local.mk"

out=$(
  PATH="$matching:$PATH" \
    make --no-print-directory -f "$tmp/matching.mk" \
      CHEZSCHEME-USE-SYSTEM=0 inspect
)
has "$out" "chez=$tmp/matching-root/local/chezscheme-10.4.1/bin/scheme$exe" \
  "system reuse can be disabled"
has "$out" "gcc-origin=file" \
  "forced local mode loads gcc.mk"

if [[ -z ${slow-} ]]; then
  pass "Use slow=1 to run the Chez Scheme installation test"
  done-testing
  exit 0
fi

out=$(
  make --no-pr chezscheme-test \
    CHEZSCHEME-USE-SYSTEM=0 \
    CMD='which scheme; scheme --version; which petite; petite --version; printf "(display (+ 20 22)) (newline)\n" | scheme -q'
)

has "$out" "$ROOT/local/chezscheme-10.4.1/bin/scheme$exe" \
  "Found locally built Chez Scheme"
has "$out" "$ROOT/local/chezscheme-10.4.1/bin/petite$exe" \
  "Found locally built Petite Chez Scheme"
has "$out" "10.4.1" "Found Chez Scheme version"
has "$out" "42" "Chez Scheme evaluates an expression"

done-testing
