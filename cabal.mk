CABAL-VERSION ?= 3.18.1.0
# https://github.com/haskell/cabal

ifndef CABAL-LOADED
CABAL-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/ghc.mk

export CABAL_DIR := $(LOCAL-HOME)/cabal
CABAL-INDEX := $(CABAL_DIR)/.index-updated

CABAL-PLATFORM-linux-arm64 := aarch64-linux-unknown
CABAL-PLATFORM-linux-int64 := x86_64-linux-unknown
CABAL-PLATFORM-macos-arm64 := aarch64-apple-darwin
CABAL-PLATFORM-macos-int64 := x86_64-apple-darwin
CABAL-PLATFORM-windows-int64 := x86_64-mingw64

ifeq ($(OS-NAME),windows)
CABAL-TAR := cabal-install-$(CABAL-VERSION)-$(CABAL-PLATFORM-$(OS-ARCH)).zip
else
CABAL-TAR := cabal-install-$(CABAL-VERSION)-$(CABAL-PLATFORM-$(OS-ARCH)).tar.xz
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

$(CABAL-INDEX): $(CABAL) $(GHC)
	@echo "* Updating the Cabal package index"
	cabal update
	touch $@

endif
