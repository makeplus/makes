#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

tmp=$(mktemp -d)
makefile=$tmp/Makefile
docker=$tmp/fake-docker
podman=$tmp/fake-podman
trap 'rm -rf "$tmp"' EXIT

cat > "$makefile" <<MAKE
M := $ROOT
include \$(M)/init.mk
include \$(M)/docker-or-podman.mk

inspect:
	@printf '%s\n' \
	  'engine=\$(DOCKER-OR-PODMAN)' \
	  'shell-deps=\$(SHELL-DEPS)'

check: \$(DOCKER-OR-PODMAN)
MAKE

cat > "$docker" <<'BASH'
#!/usr/bin/env bash

if [[ ${1-} == info && ${DOCKER_TEST_INFO-} == fail ]]; then
  echo 'fake Docker diagnostic' >&2
  exit 1
fi
BASH
chmod +x "$docker"

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
    MAKES_LOCAL_DIR="$tmp/local" \
    DOCKER="$docker" \
    PODMAN="$podman" \
    "$@"
}

out=$(run_make inspect)
has "$out" "engine=$docker" 'Docker is preferred when both engines work'
has "$out" "shell-deps=$docker" \
  'The managed shell checks only the selected engine'

out=$(run_make docker-or-podman)
is "$out" '' 'The public target validates Docker'

out=$(DOCKER_TEST_INFO=fail run_make inspect)
has "$out" "engine=$podman" \
  'Podman is selected when Docker is unavailable'
has "$out" "shell-deps=$podman" \
  'The managed shell follows the Podman selection'

out=$(DOCKER_TEST_INFO=fail run_make docker-or-podman)
is "$out" '' 'The public target validates the Podman fallback'

out=$(
  run_make DOCKER=missing-docker inspect
)
has "$out" "engine=$podman" 'Podman is selected when Docker is missing'

out=$(DOCKER_TEST_INFO=fail run_make check)
is "$out" '' 'The selected Podman prerequisite succeeds'

if out=$(
  DOCKER_TEST_INFO=fail \
    PODMAN_TEST_INFO=fail \
    run_make docker-or-podman 2>&1
); then
  fail 'The combined check fails when neither engine is available'
else
  pass 'The combined check fails when neither engine is available'
fi
has "$out" 'Neither Docker nor Podman is available' \
  'The combined check explains the problem'
has "$out" 'fake Docker diagnostic' \
  'The combined check preserves the Docker diagnostic'
has "$out" 'fake Podman diagnostic' \
  'The combined check preserves the Podman diagnostic'

done-testing
