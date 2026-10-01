#!/usr/bin/env bash

# Verify completion and man support for tools with mixed support sources.

# shellcheck disable=SC1091
source test/init

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
local_root=$scratch/local
crystal_root=$local_root/crystal-test-1
dotnet_root=$local_root/dotnet-sdk-test
gh_root=$local_root/gh-test
yamlschema_root=$local_root/yamlschema-test
makefile=$scratch/Makefile

mkdir -p \
  "$local_root/bin" \
  "$local_root/cache" \
  "$crystal_root/bin" \
  "$crystal_root/share/bash-completion/completions" \
  "$crystal_root/share/fish/vendor_completions.d" \
  "$crystal_root/share/man/man1" \
  "$crystal_root/share/man/man5" \
  "$dotnet_root" \
  "$gh_root/bin" \
  "$gh_root/share/man/man1" \
  "$yamlschema_root/bin"

touch \
  "$local_root/cache/crystal-test-1-linux-x86_64-bundled.tar.gz" \
  "$local_root/cache/dotnet-sdk-test-linux-x64.tar.gz" \
  "$local_root/cache/gh_test_linux_amd64.tar.gz" \
  "$local_root/cache/helm-vtest-linux-amd64.tar.gz" \
  "$local_root/cache/ysd-test-linux_amd64.tar.gz"

printf '# bash completion\n' \
  > "$crystal_root/share/bash-completion/completions/crystal"
printf '# zsh completion\n' \
  > "$local_root/cache/crystal-test-completion.zsh"
printf '# fish completion\n' \
  > "$crystal_root/share/fish/vendor_completions.d/crystal.fish"
printf '.TH CRYSTAL 1\n' > "$crystal_root/share/man/man1/crystal.1.gz"
printf '.TH CRYSTAL-BUILD 1\n' \
  > "$crystal_root/share/man/man1/crystal-build.1.gz"
printf '.TH SHARD.YML 5\n' \
  > "$crystal_root/share/man/man5/shard.yml.5.gz"

printf '.TH DOTNET 1\n' > "$local_root/cache/dotnet-test.1"
printf '.TH GH 1\n' > "$gh_root/share/man/man1/gh.1"
printf '.TH GH-HELP 1\n' > "$gh_root/share/man/man1/gh-help.1"

ys_source=$scratch/yamlschema-test
mkdir -p "$ys_source/share" "$ys_source/man/man1" "$ys_source/man/man5"
for shell in bash zsh fish; do
  printf '# %s completion\n' "$shell" > "$ys_source/share/complete.$shell"
done
printf '.TH YSD 1\n' > "$ys_source/man/man1/ysd.1"
for page in yamlschema-design yamlschema-json-schema yamlschema; do
  printf '.TH YAMLSCHEMA 5\n' > "$ys_source/man/man5/$page.5"
done
tar -C "$scratch" -czf \
  "$local_root/cache/yamlschema-test-source.tar.gz" \
  yamlschema-test

yq_source=$scratch/yq-source
mkdir -p "$yq_source"
printf '.TH YQ 1\n' > "$yq_source/yq.1"
printf '#!/usr/bin/env bash\n' > "$yq_source/yq_linux_amd64"
tar -C "$yq_source" -czf "$local_root/cache/yq_linux_amd64.tar.gz" \
  yq.1 yq_linux_amd64

cat > "$crystal_root/bin/crystal" <<'SH'
#!/usr/bin/env bash
exit 0
SH

cat > "$dotnet_root/dotnet" <<'SH'
#!/usr/bin/env bash
[[ $1 == completions && $2 == script ]] || exit 1
printf '# %s completion\n' "$3"
SH

cat > "$gh_root/bin/gh" <<'SH'
#!/usr/bin/env bash
printf '# %s completion\n' "$3"
SH

cat > "$local_root/bin/helm" <<'SH'
#!/usr/bin/env bash
if [[ $1 == completion ]]; then
  printf '# %s completion\n' "$2"
elif [[ $1 == docs ]]; then
  shift
  while (($#)); do
    if [[ $1 == --dir ]]; then
      dir=$2
      shift 2
    else
      shift
    fi
  done
  printf '.TH HELM 1\n' > "$dir/helm.1"
  printf '.TH HELM-INSTALL 1\n' > "$dir/helm-install.1"
fi
SH

cat > "$yamlschema_root/bin/ysd" <<'SH'
#!/usr/bin/env bash
exit 0
SH

cat > "$local_root/bin/yq" <<'SH'
#!/usr/bin/env bash
printf '# %s completion\n' "$2"
SH

chmod +x \
  "$crystal_root/bin/crystal" \
  "$dotnet_root/dotnet" \
  "$gh_root/bin/gh" \
  "$local_root/bin/helm" \
  "$yamlschema_root/bin/ysd" \
  "$local_root/bin/yq"

cat > "$makefile" <<'MAKE'
M := $(ROOT)
export MAKES_LOCAL_DIR := $(TEST-LOCAL)
CRYSTAL-VERSION := test
DOTNET-VERSION := test
GH-VERSION := test
HELM-VERSION := test
YAMLSCHEMA-VERSION := test
YQ-VERSION := test

include $(M)/init.mk
include $(M)/crystal.mk
include $(M)/dotnet.mk
include $(M)/gh.mk
include $(M)/helm.mk
include $(M)/yamlschema.mk
include $(M)/yq.mk

support: $(SHELL-DEPS)
MAKE

make --no-print-directory -f "$makefile" \
  ROOT="$ROOT" \
  TEST-LOCAL="$local_root" \
  OS-NAME=linux \
  ARCH-NAME=int64 \
  support

for file in \
  share/bash-completion/completions/crystal \
  share/zsh/site-functions/_crystal \
  share/fish/vendor_completions.d/crystal.fish \
  man/man1/crystal.1.gz \
  man/man1/crystal-build.1.gz \
  man/man5/shard.yml.5.gz \
  share/bash-completion/completions/dotnet \
  share/zsh/site-functions/_dotnet \
  share/fish/vendor_completions.d/dotnet.fish \
  man/man1/dotnet.1 \
  share/bash-completion/completions/gh \
  share/zsh/site-functions/_gh \
  share/fish/vendor_completions.d/gh.fish \
  man/man1/gh.1 \
  man/man1/gh-help.1 \
  share/bash-completion/completions/helm \
  share/zsh/site-functions/_helm \
  share/fish/vendor_completions.d/helm.fish \
  man/man1/helm.1 \
  man/man1/helm-install.1 \
  share/bash-completion/completions/ysd \
  share/zsh/site-functions/_ysd \
  share/fish/vendor_completions.d/ysd.fish \
  man/man1/ysd.1 \
  man/man5/yamlschema-design.5 \
  man/man5/yamlschema-json-schema.5 \
  man/man5/yamlschema.5 \
  share/bash-completion/completions/yq \
  share/zsh/site-functions/_yq \
  share/fish/vendor_completions.d/yq.fish \
  man/man1/yq.1; do
  if [[ -s $local_root/$file ]]; then
    pass "$file installed for an existing binary"
  else
    fail "$file installed for an existing binary"
  fi
done

done-testing
