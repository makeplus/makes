VLANG-VERSION ?= 0.5.2
# https://github.com/vlang/v

ifndef VLANG-LOADED
VLANG-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux
OA-linux-int64 := linux
OA-macos-arm64 := macos
OA-macos-int64 := macos
OA-windows-int64 := windows

VLANG-ZIP := v_$(OA-$(OS-ARCH)).zip
VLANG-DOWN := https://github.com/vlang/v/releases/download
VLANG-DOWN := $(VLANG-DOWN)/$(VLANG-VERSION)/$(VLANG-ZIP)

VLANG-LOCAL := $(LOCAL-ROOT)/vlang-$(VLANG-VERSION)
VLANG-BIN := $(VLANG-LOCAL)
override PATH := $(VLANG-BIN):$(PATH)
export PATH

ifeq ($(OS-NAME),windows)
VLANG := $(VLANG-BIN)/v.exe
else
VLANG := $(VLANG-BIN)/v
endif
VLANG-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/v
VLANG-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_v
VLANG-COMP-FISH := $(LOCAL-SHARE)/fish/vendor_completions.d/v.fish
VLANG-COMP := \
  $(VLANG-COMP-BASH) \
  $(VLANG-COMP-ZSH) \
  $(VLANG-COMP-FISH)

SHELL-DEPS += $(VLANG) $(VLANG-COMP)

$(VLANG): $(LOCAL-CACHE)/$(VLANG-ZIP)
	cd $(LOCAL-CACHE) && unzip -qo $(VLANG-ZIP)
	rm -rf $(VLANG-LOCAL)
	mv $(LOCAL-CACHE)/v $(VLANG-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(VLANG-ZIP):
	@echo "* Installing 'v' locally"
	curl+ $(VLANG-DOWN) > $@

$(VLANG-COMP-BASH): $(VLANG)
	$Q mkdir -p $(@D)
	$Q $(VLANG) complete setup bash > $@

$(VLANG-COMP-ZSH): $(VLANG)
	$Q mkdir -p $(@D)
	$Q $(VLANG) complete setup zsh > $@

$(VLANG-COMP-FISH): $(VLANG)
	$Q mkdir -p $(@D)
	$Q $(VLANG) complete setup fish > $@

endif
