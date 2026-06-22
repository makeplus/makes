CLANG-VERSION ?= 22.1.8
# https://github.com/llvm/llvm-project
#
# NOTE: LLVM's prebuilt asset naming changed in 19.x and is inconsistent across
# platforms — Linux x86_64 and macOS use a new "LLVM-VERSION-OS-ARCH" scheme,
# while aarch64-linux still uses the old "clang+llvm-VERSION-triple" scheme.
# If a future LLVM release shifts naming again, override CLANG-TAR directly.
#
# Heads up on size: ~500MB compressed, ~3GB extracted.

ifndef CLANG-LOADED
CLANG-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

CLANG-TAR-linux-arm64 := clang+llvm-$(CLANG-VERSION)-aarch64-linux-gnu.tar.xz
CLANG-TAR-linux-int64 := LLVM-$(CLANG-VERSION)-Linux-X64.tar.xz
CLANG-TAR-macos-arm64 := LLVM-$(CLANG-VERSION)-macOS-ARM64.tar.xz
CLANG-TAR-macos-int64 := LLVM-$(CLANG-VERSION)-macOS-X64.tar.xz

CLANG-TAR ?= $(CLANG-TAR-$(OS-ARCH))
CLANG-DOWN := https://github.com/llvm/llvm-project/releases/download
CLANG-DOWN := $(CLANG-DOWN)/llvmorg-$(CLANG-VERSION)/$(CLANG-TAR)

CLANG-LOCAL := $(LOCAL-ROOT)/clang-$(CLANG-VERSION)
CLANG-BIN := $(CLANG-LOCAL)/bin
override PATH := $(CLANG-BIN):$(PATH)
export PATH

CLANG := $(CLANG-BIN)/clang
CLANGPP := $(CLANG-BIN)/clang++
LLD := $(CLANG-BIN)/lld
LLVM-CONFIG := $(CLANG-BIN)/llvm-config

SHELL-DEPS += $(CLANG)


$(CLANG) $(CLANGPP) $(LLD) $(LLVM-CONFIG): $(LOCAL-CACHE)/$(CLANG-TAR)
	mkdir -p $(CLANG-LOCAL)
	tar -C $(CLANG-LOCAL) --strip-components=1 -xJf $<
	touch $(CLANG) $(CLANGPP) $(LLD) $(LLVM-CONFIG)
	@echo

$(LOCAL-CACHE)/$(CLANG-TAR):
	@echo "* Installing 'clang' locally (~500MB download, ~3GB extracted)"
	curl+ $(CLANG-DOWN) > $@

endif
