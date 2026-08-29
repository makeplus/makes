#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

tmp=$(mktemp -d)
makefile=$tmp/Makefile
docker=$tmp/fake-docker
trap 'rm -rf "$tmp"' EXIT

cat > "$makefile" <<MAKE
M := $ROOT
include \$(M)/init.mk
include \$(M)/docker.mk

check: \$(DOCKER)
MAKE

cat > "$docker" <<'BASH'
#!/usr/bin/env bash

case ${1-} in
  info)
    if [[ ${DOCKER_TEST_INFO-} == fail ]]; then
      echo 'fake daemon diagnostic' >&2
      exit 1
    fi
    ;;
  ps)
    if [[ ${DOCKER_TEST_PS-} ]]; then
      echo 'makes-makes fake container'
    fi
    ;;
esac
BASH
chmod +x "$docker"

run_make() {
  make --no-print-directory -f "$makefile" \
    MAKES_LOCAL_DIR="$tmp/local" "$@"
}

out=$(run_make DOCKER="$docker" check)
is "$out" '' 'Docker check succeeds silently when the engine is available'

check_missing() {
  local os=$1 url=$2 out

  if out=$(run_make OS-NAME="$os" DOCKER=missing-docker check 2>&1); then
    fail "$os check fails when Docker is missing"
  else
    pass "$os check fails when Docker is missing"
  fi
  has "$out" 'Docker is not installed or not in PATH' \
    "$os missing check explains the problem"
  has "$out" "$url" "$os missing check provides installation help"
}

check_missing \
  linux \
  https://docs.docker.com/engine/install/
check_missing \
  macos \
  https://docs.docker.com/desktop/setup/install/mac-install/
check_missing \
  windows \
  https://docs.docker.com/desktop/setup/install/windows-install/

check_unavailable() {
  local os=$1 hint=$2 out

  if out=$(
    DOCKER_TEST_INFO=fail \
      run_make OS-NAME="$os" DOCKER="$docker" check 2>&1
  ); then
    fail "$os check fails when the Docker engine is unavailable"
  else
    pass "$os check fails when the Docker engine is unavailable"
  fi
  has "$out" 'Docker is installed but not available' \
    "$os unavailable check explains the problem"
  has "$out" "$hint" "$os unavailable check provides startup help"
  has "$out" 'fake daemon diagnostic' \
    "$os unavailable check preserves the Docker diagnostic"
}

check_unavailable \
  linux \
  https://docs.docker.com/engine/install/linux-postinstall/
check_unavailable macos 'Start Docker Desktop and wait until it is ready'
check_unavailable windows 'Start Docker Desktop and wait until it is ready'

out=$(
  DOCKER_TEST_PS=1 \
    run_make DOCKER="$docker" docker-ps
)
has "$out" 'makes-makes fake container' \
  'Existing Docker operations use the configured DOCKER command'

done-testing
