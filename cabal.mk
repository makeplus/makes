CABAL-VERSION ?= 3.16.1.0
# https://github.com/haskell/cabal

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
OA-windows-int64 := x86_64-windows

ifeq ($(OS-NAME),windows)
CABAL-TAR := cabal-install-$(CABAL-VERSION)-$(OA-$(OS-ARCH)).zip
else
CABAL-TAR := cabal-install-$(CABAL-VERSION)-$(OA-$(OS-ARCH)).tar.xz
endif
CABAL-DOWN := https://downloads.haskell.org/~cabal
CABAL-DOWN := $(CABAL-DOWN)/cabal-install-$(CABAL-VERSION)/$(CABAL-TAR)

ifeq ($(OS-NAME),windows)
CABAL := $(LOCAL-BIN)/cabal.exe
else
CABAL := $(LOCAL-BIN)/cabal
endif

SHELL-DEPS += $(CABAL)


ifeq ($(OS-NAME),windows)
$(CABAL): $(LOCAL-CACHE)/$(CABAL-TAR)
	unzip -q -j $< cabal.exe -d $(LOCAL-BIN)
	touch $@
	@echo
else
$(CABAL): $(LOCAL-CACHE)/$(CABAL-TAR)
	tar -C $(LOCAL-BIN) -xf $< cabal
	touch $@
	@echo
endif

$(LOCAL-CACHE)/$(CABAL-TAR):
	@echo "* Installing 'Cabal $(CABAL-VERSION)' locally"
	curl+ $(CABAL-DOWN) > $@

endif
