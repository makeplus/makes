GHC-VERSION ?= 9.12.1
# https://www.github.com/ghc/ghc/tags

ifndef GHC-LOADED
GHC-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-deb12-linux
OA-linux-int64 := x86_64-ubuntu22_04-linux
OA-macos-arm64 := aarch64-apple-darwin
OA-macos-int64 := x86_64-apple-darwin
OA-windows-int64 := x86_64-unknown-mingw32

GHC-TAR ?= ghc-$(GHC-VERSION)-$(OA-$(OS-ARCH)).tar.xz
GHC-DOWN := https://downloads.haskell.org/ghc/$(GHC-VERSION)/$(GHC-TAR)

GHC-LOCAL := $(LOCAL-ROOT)/ghc-$(GHC-VERSION)
GHC-BUILD := $(LOCAL-TMP)/ghc-$(GHC-VERSION)
GHC-BIN := $(GHC-LOCAL)/bin
override PATH := $(GHC-BIN):$(PATH)
export PATH

ifeq ($(OS-NAME),windows)
GHC := $(GHC-BIN)/ghc.exe
else
GHC := $(GHC-BIN)/ghc
endif

SHELL-DEPS += $(GHC)


$(GHC): $(LOCAL-CACHE)/$(GHC-TAR) $(MAKES)/ghc.mk
	rm -rf $(GHC-LOCAL) $(GHC-BUILD)
	mkdir -p $(GHC-LOCAL) $(GHC-BUILD)
	tar -C $(GHC-BUILD) --strip-components=1 -xf $<
	cd $(GHC-BUILD) && ./configure --prefix=$(GHC-LOCAL)
	$(MAKE) -C $(GHC-BUILD) install
	rm -rf $(GHC-BUILD)
	@echo

$(LOCAL-CACHE)/$(GHC-TAR):
	@echo "* Installing 'GHC $(GHC-VERSION)' locally"
	curl+ $(GHC-DOWN) > $@

endif
