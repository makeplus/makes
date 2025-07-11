CABAL-VERSION ?= 3.14.2.0

ifndef CABAL-LOADED
CABAL-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))
include $(MAKES)/ghc.mk

OA-linux-arm64 := aarch64-linux-deb12
OA-linux-int64 := x86_64-linux-ubuntu22_04
OA-macos-arm64 := aarch64-darwin
OA-macos-int64 := x86_64-darwin

CABAL-TARBALL := cabal-install-$(CABAL-VERSION)-$(OA-$(OS-ARCH)).tar.xz
CABAL-DOWNLOAD := https://downloads.haskell.org/~cabal/cabal-install-$(CABAL-VERSION)/$(CABAL-TARBALL)

CABAL := $(LOCAL-BIN)/cabal

SHELL-DEPS += $(CABAL)


$(CABAL): $(LOCAL-CACHE)/$(CABAL-TARBALL)
	tar -C $(LOCAL-BIN) -xf $< cabal
	touch $@
	@echo

$(LOCAL-CACHE)/$(CABAL-TARBALL):
	@echo "Installing 'Cabal $(CABAL-VERSION)' locally"
	curl+ $(CABAL-DOWNLOAD) > $@

endif 
