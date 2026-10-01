JUST-VERSION ?= 1.58.0
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
JUST-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/just
JUST-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_just
JUST-COMP-FISH := $(LOCAL-SHARE)/fish/vendor_completions.d/just.fish
JUST-COMP := $(JUST-COMP-BASH) $(JUST-COMP-ZSH) $(JUST-COMP-FISH)

SHELL-DEPS += $(JUST) $(JUST-COMP)


$(JUST): $(LOCAL-CACHE)/$(JUST-TAR)
	tar -C $(LOCAL-BIN) -xf $< just
	[[ -e $@ ]]
	touch $@
	@echo

$(LOCAL-CACHE)/$(JUST-TAR):
	@echo "* Installing 'just' locally"
	curl+ $(JUST-DOWN) > $@

$(JUST-COMP-BASH): $(JUST)
	$Q mkdir -p $(@D)
	$Q $(JUST) --completions bash > $@

$(JUST-COMP-ZSH): $(JUST)
	$Q mkdir -p $(@D)
	$Q $(JUST) --completions zsh > $@

$(JUST-COMP-FISH): $(JUST)
	$Q mkdir -p $(@D)
	$Q $(JUST) --completions fish > $@

endif
