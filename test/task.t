#!/usr/bin/env bash

# shellcheck disable=SC1091
source test/init

makefile=$(mktemp)
trap 'rm -f "$makefile"' EXIT

cat > "$makefile" <<MAKE
M := $ROOT
include \$(M)/init.mk
include \$(M)/task.mk

inspect:
	@printf '%s\n' \
	  'archive=\$(TASK-ARC)' \
	  'cache=\$(TASK-CACHE)' \
	  'download=\$(TASK-DOWN)' \
	  'executable=\$(TASK-EXE)' \
	  'version=\$(TASK-VERSION)'
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

check_platform linux int64 task_linux_amd64.tar.gz task
check_platform linux arm64 task_linux_arm64.tar.gz task
check_platform macos int64 task_darwin_amd64.tar.gz task
check_platform macos arm64 task_darwin_arm64.tar.gz task
check_platform windows int64 task_windows_amd64.zip task.exe
check_platform windows arm64 task_windows_arm64.zip task.exe

out=$(
  make --no-print-directory -f "$makefile" \
    OS-NAME=linux ARCH-NAME=int64 TASK-VERSION=9.8.7 inspect
)
has "$out" 'cache=task-9.8.7-task_linux_amd64.tar.gz' \
  'TASK-VERSION overrides the cache version'
has "$out" \
  'download=https://github.com/go-task/task/releases/download/v9.8.7/' \
  'TASK-VERSION overrides the download version'
has "$out" 'version=9.8.7' \
  'TASK-VERSION overrides the module version'

task_version=$(
  make --no-print-directory -f "$makefile" \
    OS-NAME=linux ARCH-NAME=int64 inspect |
    while IFS='=' read -r key value; do
      if [[ $key == version ]]; then
        printf '%s\n' "$value"
      fi
    done
)

if [[ -z ${slow-} ]]; then
  pass 'Use slow=1 to run the Task installation test'
  done-testing
  exit 0
fi

out=$(
  make --no-pr task-test CMD='which task; task --version'
)
has "$out" "$ROOT/local/task-$task_version/bin/task" \
  "Found task in local/task-$task_version"
has "$out" "$task_version" "Found Task version $task_version"

done-testing
