GHC-VERSION ?= 9.12.1

ifndef GHC-LOADED
GHC-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-deb12-linux
OA-linux-int64 := x86_64-ubuntu22_04-linux
OA-macos-arm64 := aarch64-apple-darwin
OA-macos-int64 := x86_64-apple-darwin

GHC-TARBALL := ghc-$(GHC-VERSION)-$(OA-$(OS-ARCH)).tar.xz
GHC-DOWNLOAD := https://downloads.haskell.org/ghc/$(GHC-VERSION)/$(GHC-TARBALL)

GHC-LOCAL := $(LOCAL-ROOT)/ghc-$(GHC-VERSION)
GHC-BIN := $(GHC-LOCAL)/bin

override PATH := $(GHC-BIN):$(PATH)

GHC := $(GHC-BIN)/ghc

SHELL-DEPS += $(GHC)


$(GHC): $(LOCAL-CACHE)/$(GHC-TARBALL)
	tar -C $(LOCAL-ROOT) -xf $<
	mv $(LOCAL-ROOT)/ghc-$(GHC-VERSION)-* $(GHC-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(GHC-TARBALL):
	@echo "Installing 'GHC $(GHC-VERSION)' locally"
	curl+ $(GHC-DOWNLOAD) > $@

endif
