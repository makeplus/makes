DOTNET-VERSION ?= 8.0.414
# https://www.github.com/dotnet/sdk/tree/v8.0.414

ifndef DOTNET-LOADED
DOTNET-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-x64
OA-macos-arm64 := osx-arm64
OA-macos-int64 := osx-x64

DOTNET-NAME := dotnet-sdk
DOTNET-TAR := $(DOTNET-NAME)-$(DOTNET-VERSION)-$(OA-$(OS-ARCH)).tar.gz
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

$(DOTNET-ROOT): $(LOCAL-CACHE)/$(DOTNET-TAR)
	mkdir -p $@
	tar -C $@ -xzf $<

$(LOCAL-CACHE)/$(DOTNET-TAR):
	@echo "* Installing 'GraalVM' locally"
	curl+ $(DOTNET-DOWN) > $@

endif
