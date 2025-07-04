JUST-VERSION ?= 1.41.0

ifndef JUST-LOADED
JUST-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

OA-linux-arm64 := arm-unknown-linux-musleabihf
OA-linux-int64 := x86_64-unknown-linux-musl
OA-macos-arm64 := aarch64-apple-darwin
OA-macos-int64 := x86_64-apple-darwin

JUST-TARBALL := just-$(JUST-VERSION)-$(OA-$(OS-ARCH)).tar.gz
JUST-DOWNLOAD := https://github.com/casey/just/releases/download/$(JUST-VERSION)/$(JUST-TARBALL)

JUST := $(LOCAL-BIN)/just

SHELL-DEPS += $(JUST)

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
	@echo "Installing 'just' locally"
	curl+ $(JUST-DOWNLOAD) > $@

endif
