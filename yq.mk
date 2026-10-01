YQ-VERSION ?= 4.54.1

ifndef YQ-LOADED
YQ-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux_arm64
OA-linux-int64 := linux_amd64
OA-macos-arm64 := darwin_arm64
OA-macos-int64 := darwin_amd64

YQ-NAME := yq_$(OA-$(OS-ARCH))
YQ-TAR := $(YQ-NAME).tar.gz
YQ-DOWN := https://github.com/mikefarah/yq
YQ-DOWN := $(YQ-DOWN)/releases/download/v$(YQ-VERSION)/$(YQ-TAR)

YQ := $(LOCAL-BIN)/yq
YQ-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/yq
YQ-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_yq
YQ-COMP-FISH := $(LOCAL-SHARE)/fish/vendor_completions.d/yq.fish
YQ-COMP := \
  $(YQ-COMP-BASH) \
  $(YQ-COMP-ZSH) \
  $(YQ-COMP-FISH)
YQ-MAN := $(LOCAL-MAN)/man1/yq.1

SHELL-DEPS += $(YQ) $(YQ-COMP) $(YQ-MAN)


$(YQ): $(LOCAL-CACHE)/$(YQ-TAR)
	tar -C $(LOCAL-CACHE) -xf $< -- ./$(YQ-NAME)
	[[ -e $(LOCAL-CACHE)/$(YQ-NAME) ]]
	mv $(LOCAL-CACHE)/$(YQ-NAME) $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(YQ-TAR):
	@echo "* Installing 'yq' locally"
	curl+ $(YQ-DOWN) > $@

$(YQ-COMP-BASH): $(YQ)
	$Q mkdir -p $(@D)
	$Q $(YQ) completion bash > $@

$(YQ-COMP-ZSH): $(YQ)
	$Q mkdir -p $(@D)
	$Q $(YQ) completion zsh > $@

$(YQ-COMP-FISH): $(YQ)
	$Q mkdir -p $(@D)
	$Q $(YQ) completion fish > $@

$(YQ-MAN): $(LOCAL-CACHE)/$(YQ-TAR)
	$Q mkdir -p $(@D)
	$Q tar -xOf $< yq.1 > $@

endif
