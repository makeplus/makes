CABAL-VERSION ?= 3.14.2.0
# https://www.github.com/haskell/cabal/releases

ifndef CABAL-LOADED
CABAL-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/ghc.mk

export CABAL_DIR := $(LOCAL-HOME)/cabal

OA-linux-arm64 := aarch64-linux-deb12
OA-linux-int64 := x86_64-linux-ubuntu22_04
OA-macos-arm64 := aarch64-darwin
OA-macos-int64 := x86_64-darwin

CABAL-TAR := cabal-install-$(CABAL-VERSION)-$(OA-$(OS-ARCH)).tar.xz
CABAL-DOWN := https://downloads.haskell.org/~cabal
CABAL-DOWN := $(CABAL-DOWN)/cabal-install-$(CABAL-VERSION)/$(CABAL-TAR)

CABAL := $(LOCAL-BIN)/cabal

SHELL-DEPS += $(CABAL)


$(CABAL): $(LOCAL-CACHE)/$(CABAL-TAR)
	tar -C $(LOCAL-BIN) -xf $< cabal
	touch $@
	@echo

$(LOCAL-CACHE)/$(CABAL-TAR):
	@echo "* Installing 'Cabal $(CABAL-VERSION)' locally"
	curl+ $(CABAL-DOWN) > $@

endif
