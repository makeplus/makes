DOTNET-VERSION ?= 8.0.412

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-x64
OA-macos-arm64 := osx-arm64
OA-macos-int64 := osx-x64

ifndef DOTNET-LOADED
DOTNET-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

DOTNET-NAME := dotnet-sdk
DOTNET-TARBALL := $(DOTNET-NAME)-$(DOTNET-VERSION)-$(OA-$(OS-ARCH)).tar.gz
DOTNET-DOWNLOAD := https://builds.dotnet.microsoft.com/dotnet/Sdk
DOTNET-DOWNLOAD := $(DOTNET-DOWNLOAD)/$(DOTNET-VERSION)/$(DOTNET-TARBALL)

DOTNET-ROOT := $(LOCAL-ROOT)/$(DOTNET-NAME)-$(DOTNET-VERSION)
export DOTNET_ROOT := $(DOTNET-ROOT)
override PATH := $(DOTNET-ROOT):$(PATH)

DOTNET := $(DOTNET-ROOT)/dotnet

SHELL-DEPS += $(DOTNET)


$(DOTNET): $(DOTNET-ROOT)
	touch $@
	@echo

$(DOTNET-ROOT): $(LOCAL-CACHE)/$(DOTNET-TARBALL)
	mkdir -p $@
	tar -C $@ -xzf $<

$(LOCAL-CACHE)/$(DOTNET-TARBALL):
	@echo "Installing 'GraalVM' locally"
	curl+ $(DOTNET-DOWNLOAD) > $@

endif
