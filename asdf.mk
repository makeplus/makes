ASDF-VERSION ?= 0.20.2
# https://github.com/asdf-vm/asdf

ifndef ASDF-LOADED
ASDF-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-amd64

ASDF-TAR := asdf-v$(ASDF-VERSION)-$(OA-$(OS-ARCH)).tar.gz
ASDF-DOWN := https://github.com/asdf-vm/asdf/releases/download/v$(ASDF-VERSION)/$(ASDF-TAR)
ASDF-LOCAL := $(LOCAL-ROOT)/asdf-v$(ASDF-VERSION)
ASDF := $(ASDF-LOCAL)/asdf
ASDF-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/asdf
ASDF-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_asdf
ASDF-COMP-FISH := $(LOCAL-SHARE)/fish/vendor_completions.d/asdf.fish
ASDF-COMP := $(ASDF-COMP-BASH) $(ASDF-COMP-ZSH) $(ASDF-COMP-FISH)
override PATH := $(ASDF-LOCAL):$(PATH)
export PATH
export ASDF_DATA_DIR := $(LOCAL-ROOT)/asdf

SHELL-DEPS += $(ASDF) $(ASDF-COMP)


$(ASDF): $(LOCAL-CACHE)/$(ASDF-TAR)
	mkdir -p $(ASDF-LOCAL)
	tar -C $(ASDF-LOCAL) -xzf $<
	touch $@
	@echo

$(LOCAL-CACHE)/$(ASDF-TAR):
	@echo "* Installing 'asdf' locally"
	curl+ $(ASDF-DOWN) > $@

$(ASDF-COMP-BASH): $(ASDF)
	$Q mkdir -p $(@D)
	$Q $(ASDF) completion bash > $@

$(ASDF-COMP-ZSH): $(ASDF)
	$Q mkdir -p $(@D)
	$Q $(ASDF) completion zsh > $@

$(ASDF-COMP-FISH): $(ASDF)
	$Q mkdir -p $(@D)
	$Q $(ASDF) completion fish > $@

endif
