DOTNET-VERSION ?= 8.0.415
# https://www.github.com/dotnet/sdk/tree/v8.0.414

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

DOTNET := $(DOTNET-ROOT)/dotnet

SHELL-DEPS += $(DOTNET)


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

endif
