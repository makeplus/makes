#!/usr/bin/env bash

source test/init chdir slow

like \
  "$(source <(make --no-pr shell-env) && gh --version)" \
  'gh version 2\.' \
  "Found gh version"

done-testing
