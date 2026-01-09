#!/usr/bin/env bash

source test/init chdir slow

# Skip on Windows (gh.mk doesn't support Windows yet)
if [[ $OSTYPE == msys* || $OSTYPE == cygwin* ]]; then
  pass "Skipping shell.t on Windows"
  done-testing
  exit 0
fi

like \
  "$(source <(make --no-pr shell-env) && gh --version)" \
  'gh version 2\.' \
  "Found gh version"

done-testing
