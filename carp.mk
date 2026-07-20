CARP-VERSION ?= 0.6.0
# https://github.com/carp-lang/Carp

ifndef CARP-LOADED
CARP-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

CARP-GHC-VERSION ?= 9.6.6
GHC-VERSION := $(CARP-GHC-VERSION)
GHC-TAR-linux-arm64 := ghc-$(GHC-VERSION)-aarch64-deb10-linux.tar.xz
GHC-TAR-linux-int64 := ghc-$(GHC-VERSION)-x86_64-deb11-linux.tar.xz
GHC-TAR-macos-arm64 := ghc-$(GHC-VERSION)-aarch64-apple-darwin.tar.xz
GHC-TAR-macos-int64 := ghc-$(GHC-VERSION)-x86_64-apple-darwin.tar.xz
GHC-TAR-windows-int64 := ghc-$(GHC-VERSION)-x86_64-unknown-mingw32.tar.xz
GHC-TAR := $(GHC-TAR-$(OS-ARCH))

include $(MAKES)/cabal.mk
include $(MAKES)/clang.mk

CARP-REVISION ?= 6452fa5568a201bea0277e2fd6c1c3859182b801
CARP-TAR := carp-$(CARP-VERSION)-$(CARP-REVISION).tar.gz
CARP-DOWN := https://github.com/carp-lang/Carp/archive
CARP-DOWN := $(CARP-DOWN)/$(CARP-REVISION).tar.gz

CARP-LOCAL := $(LOCAL-ROOT)/carp-$(CARP-VERSION)
CARP-BIN := $(CARP-LOCAL)/bin
override PATH := $(CARP-BIN):$(PATH)
export PATH
export CARP_DIR := $(CARP-LOCAL)
export XDG_CONFIG_HOME := $(LOCAL-HOME)/config

ifeq ($(OS-NAME),windows)
CARP := $(CARP-BIN)/carp.exe
else
CARP := $(CARP-BIN)/carp
endif

SHELL-DEPS += $(CARP)


$(CARP): $(LOCAL-CACHE)/$(CARP-TAR) $(CABAL-INDEX) $(CLANG)
	@$(ECHO) "* Building 'Carp $(CARP-VERSION)' locally"
	$Q mkdir -p $(CARP-LOCAL) $(CARP-BIN)
	$Q tar -C $(CARP-LOCAL) --strip-components=1 -xzf $<
	$Q cd $(CARP-LOCAL) && \
	  cabal install exe:carp \
	    --install-method=copy \
	    --installdir=$(CARP-BIN) \
	    --overwrite-policy=always $O
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(CARP-TAR):
	@$(ECHO) "* Downloading 'Carp $(CARP-VERSION)' source"
	$Q curl+ $(CARP-DOWN) > $@

endif
