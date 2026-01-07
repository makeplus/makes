GCC-VERSION ?= 14.2.0-2
# https://github.com/xpack-dev-tools/gcc-xpack

ifndef GCC-LOADED
GCC-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-x64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-x64

GCC-TAR := xpack-gcc-$(GCC-VERSION)-$(OA-$(OS-ARCH)).tar.gz
GCC-DOWN := https://github.com/xpack-dev-tools/gcc-xpack/releases/download
GCC-DOWN := $(GCC-DOWN)/v$(GCC-VERSION)/$(GCC-TAR)

GCC-LOCAL := $(LOCAL-ROOT)/gcc-$(GCC-VERSION)
GCC-BIN := $(GCC-LOCAL)/bin
override PATH := $(GCC-BIN):$(PATH)

GCC := $(GCC-BIN)/gcc
GPP := $(GCC-BIN)/g++
GFORTRAN := $(GCC-BIN)/gfortran

SHELL-DEPS += $(GCC)


$(GCC): $(LOCAL-CACHE)/$(GCC-TAR)
	mkdir -p $(GCC-LOCAL)
	tar -C $(GCC-LOCAL) --strip-components=1 -xzf $<
	touch $@
	@echo

$(LOCAL-CACHE)/$(GCC-TAR):
	@echo "* Installing 'gcc' locally (via xPack GCC)"
	curl+ $(GCC-DOWN) > $@

endif
