DOTNET-VERSION ?= 10.0.401
# https://www.github.com/dotnet/sdk/tree/v10.0.401

ifndef DOTNET-LOADED
DOTNET-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-x64
OA-macos-arm64 := osx-arm64
OA-macos-int64 := osx-x64
OA-windows-arm64 := win-arm64
OA-windows-int64 := win-x64

DOTNET-NAME := dotnet-sdk
ifeq ($(OS-NAME),windows)
DOTNET-TAR := $(DOTNET-NAME)-$(DOTNET-VERSION)-$(OA-$(OS-ARCH)).zip
else
DOTNET-TAR := $(DOTNET-NAME)-$(DOTNET-VERSION)-$(OA-$(OS-ARCH)).tar.gz
endif
DOTNET-DOWN := https://builds.dotnet.microsoft.com/dotnet/Sdk
DOTNET-DOWN := $(DOTNET-DOWN)/$(DOTNET-VERSION)/$(DOTNET-TAR)

DOTNET-ROOT := $(LOCAL-ROOT)/$(DOTNET-NAME)-$(DOTNET-VERSION)
export DOTNET_ROOT := $(DOTNET-ROOT)
override PATH := $(DOTNET-ROOT):$(PATH)
export PATH
export DOTNET_CLI_HOME ?= $(LOCAL-CACHE)/dotnet-home
export NUGET_PACKAGES ?= $(LOCAL-CACHE)/nuget-packages

DOTNET := $(DOTNET-ROOT)/dotnet
DOTNET-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/dotnet
DOTNET-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_dotnet
DOTNET-COMP-FISH := \
  $(LOCAL-SHARE)/fish/vendor_completions.d/dotnet.fish
DOTNET-COMP := \
  $(DOTNET-COMP-BASH) \
  $(DOTNET-COMP-ZSH) \
  $(DOTNET-COMP-FISH)
DOTNET-MAN-CACHE := $(LOCAL-CACHE)/dotnet-$(DOTNET-VERSION).1
DOTNET-MAN-DOWN := https://raw.githubusercontent.com/dotnet/sdk
DOTNET-MAN-DOWN := \
  $(DOTNET-MAN-DOWN)/v$(DOTNET-VERSION)/documentation/manpages/sdk/dotnet.1
DOTNET-MAN := $(LOCAL-MAN)/man1/dotnet.1

SHELL-DEPS += $(DOTNET) $(DOTNET-COMP) $(DOTNET-MAN)


$(DOTNET): $(DOTNET-ROOT)
	touch $@
	@echo

ifeq ($(OS-NAME),windows)
$(DOTNET-ROOT): $(LOCAL-CACHE)/$(DOTNET-TAR)
	mkdir -p $@
	cd $@ && unzip -q ../cache/$(DOTNET-TAR)
else
$(DOTNET-ROOT): $(LOCAL-CACHE)/$(DOTNET-TAR)
	mkdir -p $@
	tar -C $@ -xzf $<
endif

$(LOCAL-CACHE)/$(DOTNET-TAR):
	@echo "* Installing 'dotnet' locally"
	curl+ $(DOTNET-DOWN) > $@

$(DOTNET-COMP-BASH): $(DOTNET)
	$Q mkdir -p $(@D)
	$Q $(DOTNET) completions script bash > $@

$(DOTNET-COMP-ZSH): $(DOTNET)
	$Q mkdir -p $(@D)
	$Q $(DOTNET) completions script zsh > $@

$(DOTNET-COMP-FISH): $(DOTNET)
	$Q mkdir -p $(@D)
	$Q $(DOTNET) completions script fish > $@

$(DOTNET-MAN): $(DOTNET-MAN-CACHE)
	$Q mkdir -p $(@D)
	$Q cp $< $@

$(DOTNET-MAN-CACHE):
	$Q curl+ $(DOTNET-MAN-DOWN) > $@

endif
