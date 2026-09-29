#!/usr/bin/env bash

# Verify that support files are installed for an existing tool binary.

# shellcheck disable=SC1091
source test/init

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
local_root=$scratch/local
gloat_root=$scratch/gloat
makefile=$scratch/Makefile

mkdir -p \
  "$local_root/cache" \
  "$local_root/jolt-test/bin" \
  "$gloat_root/bin" \
  "$gloat_root/man/man1" \
  "$gloat_root/template"

touch "$local_root/cache/jolt-vtest-x86_64-linux.tar.gz"
cat > "$local_root/jolt-test/bin/jolt" <<'SH'
#!/usr/bin/env bash
printf '# %s completion\n' "$2"
SH
chmod +x "$local_root/jolt-test/bin/jolt"

for shell in bash zsh fish; do
  printf '# %s completion\n' "$shell" \
    > "$gloat_root/template/completion.$shell"
done
for page in \
  gloat.1 \
  gloat-go-interop.1 \
  gloat-install.1 \
  gloat-java-interop.1 \
  gloat-repl.1 \
  gloat-tutorial.1; do
  printf '.TH GLOAT 1\n' > "$gloat_root/man/man1/$page"
done
touch "$gloat_root/bin/gloat"
chmod +x "$gloat_root/bin/gloat"

cat > "$makefile" <<'MAKE'
M := $(ROOT)
export MAKES_LOCAL_DIR := $(TEST-LOCAL)
GLOAT-VERSION := test
GLOAT-DIR := $(TEST-GLOAT)
JOLT-VERSION := test

include $(M)/init.mk
include $(M)/gloat.mk
include $(M)/jolt.mk

support: \
  $(GLOAT-BASH-COMPLETION) \
  $(GLOAT-ZSH-COMPLETION) \
  $(GLOAT-FISH-COMPLETION) \
  $(GLOAT-MAN) \
  $(JOLT-BASH-COMPLETION) \
  $(JOLT-ZSH-COMPLETION) \
  $(JOLT-FISH-COMPLETION)
MAKE

make --no-print-directory -f "$makefile" \
  ROOT="$ROOT" \
  TEST-LOCAL="$local_root" \
  TEST-GLOAT="$gloat_root" \
  OS-NAME=linux \
  ARCH-NAME=int64 \
  support

for file in \
  share/bash-completion/completions/gloat \
  share/zsh/site-functions/_gloat \
  share/fish/vendor_completions.d/gloat.fish \
  man/man1/gloat.1 \
  man/man1/gloat-go-interop.1 \
  man/man1/gloat-install.1 \
  man/man1/gloat-java-interop.1 \
  man/man1/gloat-repl.1 \
  man/man1/gloat-tutorial.1 \
  share/bash-completion/completions/jolt \
  share/zsh/site-functions/_jolt \
  share/fish/vendor_completions.d/jolt.fish; do
  if [[ -s $local_root/$file ]]; then
    pass "$file installed for an existing binary"
  else
    fail "$file installed for an existing binary"
  fi
done

done-testing
