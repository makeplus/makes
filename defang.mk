DEFANG-VERSION ?= 3.15.4

ifndef DEFANG-LOADED
DEFANG-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux_arm64
OA-linux-int64 := linux_amd64
OA-macos-arm64 := macOS
OA-macos-int64 := macOS

DEFANG-NAME := defang_$(DEFANG-VERSION)_$(OA-$(OS-ARCH))
DEFANG-TAR := $(DEFANG-NAME).$(if $(IS-MACOS),zip,tar.gz)
DEFANG-DOWN := https://github.com/defanglabs/defang/releases/download
DEFANG-DOWN := $(DEFANG-DOWN)/v$(DEFANG-VERSION)/$(DEFANG-TAR)

DEFANG := $(LOCAL-BIN)/defang
DEFANG-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/defang
DEFANG-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_defang
DEFANG-COMP-FISH := $(LOCAL-SHARE)/fish/vendor_completions.d/defang.fish
DEFANG-COMP := \
  $(DEFANG-COMP-BASH) \
  $(DEFANG-COMP-ZSH) \
  $(DEFANG-COMP-FISH)

SHELL-DEPS += $(DEFANG) $(DEFANG-COMP)


$(DEFANG): $(LOCAL-CACHE)/$(DEFANG-TAR)
ifdef IS-MACOS
	cd $(LOCAL-BIN) && unzip $< defang
else
	tar -C $(LOCAL-BIN) -xf $< defang
endif
	[[ -e $@ ]]
	@touch $@
	@echo

$(LOCAL-CACHE)/$(DEFANG-TAR):
	@echo "* Installing 'defang' locally"
	curl+ $(DEFANG-DOWN) > $@
	@touch $@

$(DEFANG-COMP-BASH): $(DEFANG)
	$Q mkdir -p $(@D)
	$Q $(DEFANG) completion bash > $@

$(DEFANG-COMP-ZSH): $(DEFANG)
	$Q mkdir -p $(@D)
	$Q $(DEFANG) completion zsh > $@

$(DEFANG-COMP-FISH): $(DEFANG)
	$Q mkdir -p $(@D)
	$Q $(DEFANG) completion fish > $@

endif
