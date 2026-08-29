#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

tmp=$(mktemp -d)
makefile=$tmp/Makefile
docker=$tmp/fake-docker
compose=$tmp/fake-compose
trap 'rm -rf "$tmp"' EXIT

cat > "$makefile" <<MAKE
M := $ROOT
include \$(M)/init.mk
include \$(M)/docker-compose.mk

inspect:
	@printf '%s\n' \
	  'docker-compose=\$(DOCKER-COMPOSE)' \
	  'shell-deps=\$(SHELL-DEPS)'

check: \$(DOCKER-COMPOSE)
	@docker info
	@docker compose up --dry-run
MAKE

cat > "$docker" <<'BASH'
#!/usr/bin/env bash

if [[ ${1-} == compose && ${DOCKER_TEST_COMPOSE-} != native ]]; then
  exit 1
fi
printf 'docker:%s\n' "$*"
BASH
chmod +x "$docker"

cat > "$compose" <<'BASH'
#!/usr/bin/env bash

printf 'compose:%s\n' "$*"
BASH
chmod +x "$compose"

run_make() {
  make --no-print-directory -f "$makefile" \
    MAKES_LOCAL_DIR="$tmp/local" \
    MAKES_QUIET=1 \
    DOCKER="$docker" \
    COMPOSE="$compose" \
    "$@"
}

not_has() {
  local got=$1 unexpected=$2 name=$3

  if [[ $got == *"$unexpected"* ]]; then
    fail "$name"
  else
    pass "$name"
  fi
}

out=$(DOCKER_TEST_COMPOSE=native run_make inspect)
has "$out" "docker-compose=$docker" \
  'An existing Docker Compose plugin is preferred'
not_has "$out" "$compose" \
  'Native Docker Compose does not add the managed fallback'

out=$(run_make inspect)
has "$out" "docker-compose=$tmp/local/bin/docker" \
  'A cache-local Docker wrapper provides the fallback'
has "$out" "$compose" \
  'The managed Compose fallback is a shell dependency'

out=$(run_make check)
has "$out" 'docker:info' \
  'The wrapper forwards ordinary commands to Docker'
has "$out" 'compose:up --dry-run' \
  'The wrapper forwards compose commands to managed Compose'

out=$(DOCKER_TEST_COMPOSE=native run_make check)
has "$out" 'docker:compose up --dry-run' \
  'The wrapper prefers native Compose when it becomes available'
not_has "$out" 'compose:up --dry-run' \
  'Native Compose bypasses the managed fallback'

done-testing
