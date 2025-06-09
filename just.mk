ifndef MAKES
$(error Please 'include .makes/init.mk')
endif
ifndef LOCAL-ROOT
include $(MAKES)/local.mk
endif

JUST-VERSION ?= 1.40.0

JUST-TARBALL := just-$(JUST-VERSION)-x86_64-unknown-linux-musl.tar.gz
JUST-DOWNLOAD := https://github.com/casey/just/releases/download/$(JUST-VERSION)/$(JUST-TARBALL)

JUST := $(LOCAL-BIN)/just

JUST-CMDS := \
  bench \
  check \
  fmt-check \
  build \
  clean \
  fuzz \
  test-unit \
  clean-rust \
  clippy \
  guests \
  test \
  test-isolated \

$(JUST): $(LOCAL-CACHE)/$(JUST-TARBALL)
	tar -C $(LOCAL-BIN) -xf $< just
	[[ -e $@ ]]
	touch $@
	@echo

$(LOCAL-CACHE)/$(JUST-TARBALL):
	@echo "Installing 'go' locally"
	curl -Ls $(JUST-DOWNLOAD) > $@
