WASMTIME-VERSION ?= 49.0.2

ifndef WASMTIME-LOADED
WASMTIME-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-linux
OA-linux-int64 := x86_64-linux
OA-macos-arm64 := aarch64-macos
OA-macos-int64 := x86_64-macos

# https://github.com/bytecodealliance/wasmtime/releases/download/v36.0.2/wasmtime-v36.0.2-x86_64-linux.tar.xz
# https://github.com/bytecodealliance/wasmtime/releases/download/v36.0.2/wasmtime-v36.0.2-x86_64-linux.tar.xz

WASMTIME-NAME := wasmtime-v$(WASMTIME-VERSION)-$(OA-$(OS-ARCH))
WASMTIME-TAR := $(WASMTIME-NAME).tar.xz
WASMTIME-DOWN := https://github.com/bytecodealliance/wasmtime
WASMTIME-DOWN := $(WASMTIME-DOWN)/releases/download/v$(WASMTIME-VERSION)/$(WASMTIME-TAR)

WASMTIME := $(LOCAL-BIN)/wasmtime
WASMTIME-COMP-BASH := \
  $(LOCAL-SHARE)/bash-completion/completions/wasmtime
WASMTIME-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_wasmtime
WASMTIME-COMP-FISH := \
  $(LOCAL-SHARE)/fish/vendor_completions.d/wasmtime.fish
WASMTIME-COMP := \
  $(WASMTIME-COMP-BASH) \
  $(WASMTIME-COMP-ZSH) \
  $(WASMTIME-COMP-FISH)

SHELL-DEPS += $(WASMTIME) $(WASMTIME-COMP)


$(WASMTIME): $(LOCAL-CACHE)/$(WASMTIME-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	[[ -e $(LOCAL-CACHE)/$(WASMTIME-NAME)/wasmtime ]]
	mv $(LOCAL-CACHE)/$(WASMTIME-NAME)/wasmtime $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(WASMTIME-TAR):
	@echo "* Installing 'wasmtime' locally"
	curl+ $(WASMTIME-DOWN) > $@

$(WASMTIME-COMP-BASH): $(WASMTIME)
	$Q mkdir -p $(@D)
	$Q $(WASMTIME) completion bash > $@

$(WASMTIME-COMP-ZSH): $(WASMTIME)
	$Q mkdir -p $(@D)
	$Q $(WASMTIME) completion zsh > $@

$(WASMTIME-COMP-FISH): $(WASMTIME)
	$Q mkdir -p $(@D)
	$Q $(WASMTIME) completion fish > $@

endif
