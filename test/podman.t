#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

tmp=$(mktemp -d)
makefile=$tmp/Makefile
podman=$tmp/fake-podman
trap 'rm -rf "$tmp"' EXIT

cat > "$makefile" <<MAKE
M := $ROOT
include \$(M)/init.mk
include \$(M)/podman.mk

check: \$(PODMAN)
MAKE

cat > "$podman" <<'BASH'
#!/usr/bin/env bash

if [[ ${1-} == info && ${PODMAN_TEST_INFO-} == fail ]]; then
  echo 'fake Podman diagnostic' >&2
  exit 1
fi
BASH
chmod +x "$podman"

run_make() {
  make --no-print-directory -f "$makefile" \
    MAKES_LOCAL_DIR="$tmp/local" "$@"
}

out=$(run_make PODMAN="$podman" check)
is "$out" '' 'Podman check succeeds silently when the engine is available'

check_missing() {
  local os=$1 out

  if out=$(run_make OS-NAME="$os" PODMAN=missing-podman check 2>&1); then
    fail "$os check fails when Podman is missing"
  else
    pass "$os check fails when Podman is missing"
  fi
  has "$out" 'Podman is not installed or not in PATH' \
    "$os missing check explains the problem"
  has "$out" 'https://podman.io/docs/installation' \
    "$os missing check provides installation help"
}

check_missing linux
check_missing macos
check_missing windows

check_unavailable() {
  local os=$1 hint=$2 out

  if out=$(
    PODMAN_TEST_INFO=fail \
      run_make OS-NAME="$os" PODMAN="$podman" check 2>&1
  ); then
    fail "$os check fails when Podman is unavailable"
  else
    pass "$os check fails when Podman is unavailable"
  fi
  has "$out" 'Podman is installed but not available' \
    "$os unavailable check explains the problem"
  has "$out" "$hint" "$os unavailable check provides startup help"
  has "$out" 'fake Podman diagnostic' \
    "$os unavailable check preserves the Podman diagnostic"
}

check_unavailable linux 'Check rootless Podman setup'
check_unavailable macos 'Run podman machine start'
check_unavailable windows 'Run podman machine start'

done-testing
