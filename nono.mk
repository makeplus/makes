NONO-VERSION ?= 0.79.0
# https://github.com/always-further/nono

ifndef NONO-LOADED
NONO-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

ifdef IS-MACOS
NONO := $(shell command -v nono)
ifeq (,$(NONO))
NONO := $(LOCAL-CACHE)/system/nono
$(NONO):
	$(error nono is not installed.   brew install nono)
endif

else
# Linux: download prebuilt binary

OA-linux-arm64 := aarch64-unknown-linux-gnu
OA-linux-int64 := x86_64-unknown-linux-gnu

NONO-TAR := nono-v$(NONO-VERSION)-$(OA-$(OS-ARCH)).tar.gz
NONO-DOWN := https://github.com/always-further/nono/releases/download
NONO-DOWN := $(NONO-DOWN)/v$(NONO-VERSION)/$(NONO-TAR)

NONO := $(LOCAL-BIN)/nono


$(NONO): $(LOCAL-CACHE)/$(NONO-TAR)
	tar -C $(LOCAL-BIN) -xf $< nono
	[[ -e $@ ]]
	@touch $@
	@echo

$(LOCAL-CACHE)/$(NONO-TAR):
	@echo "* Installing 'nono' locally"
	curl+ $(NONO-DOWN) > $@

endif

NONO-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/nono
NONO-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_nono
NONO-COMP-FISH := $(LOCAL-SHARE)/fish/vendor_completions.d/nono.fish
NONO-COMP := $(NONO-COMP-BASH) $(NONO-COMP-ZSH) $(NONO-COMP-FISH)

SHELL-DEPS += $(NONO) $(NONO-COMP)

$(NONO-COMP-BASH): $(NONO)
	$Q mkdir -p $(@D)
	$Q $(NONO) completion bash > $@

$(NONO-COMP-ZSH): $(NONO)
	$Q mkdir -p $(@D)
	$Q $(NONO) completion zsh > $@

$(NONO-COMP-FISH): $(NONO)
	$Q mkdir -p $(@D)
	$Q $(NONO) completion fish > $@

endif
