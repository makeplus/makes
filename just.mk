JUST-VERSION ?= 1.42.4
# https://github.com/casey/just

ifndef JUST-LOADED
JUST-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

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

OA-linux-arm64 := arm-unknown-linux-musleabihf
OA-linux-int64 := x86_64-unknown-linux-musl
OA-macos-arm64 := aarch64-apple-darwin
OA-macos-int64 := x86_64-apple-darwin

JUST-TAR := just-$(JUST-VERSION)-$(OA-$(OS-ARCH)).tar.gz
JUST-DOWN := https://github.com/casey/just/releases/download
JUST-DOWN := $(JUST-DOWN)/$(JUST-VERSION)/$(JUST-TAR)

JUST := $(LOCAL-BIN)/just

SHELL-DEPS += $(JUST)


$(JUST): $(LOCAL-CACHE)/$(JUST-TAR)
	tar -C $(LOCAL-BIN) -xf $< just
	[[ -e $@ ]]
	touch $@
	@echo

$(LOCAL-CACHE)/$(JUST-TAR):
	@echo "Installing 'just' locally"
	curl+ $(JUST-DOWN) > $@

endif
