GCC-VERSION ?= 14.2.0-1
# https://github.com/xpack-dev-tools/gcc-xpack

ifndef GCC-LOADED
GCC-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-x64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-x64
OA-windows-arm64 := win32-arm64
OA-windows-int64 := win32-x64

ifeq ($(OS-NAME),windows)
GCC-ARCHIVE := xpack-gcc-$(GCC-VERSION)-$(OA-$(OS-ARCH)).zip
else
GCC-ARCHIVE := xpack-gcc-$(GCC-VERSION)-$(OA-$(OS-ARCH)).tar.gz
endif
GCC-TAR := $(GCC-ARCHIVE)
GCC-DOWN := https://github.com/xpack-dev-tools/gcc-xpack/releases/download
GCC-DOWN := $(GCC-DOWN)/v$(GCC-VERSION)/$(GCC-TAR)

GCC-LOCAL := $(LOCAL-ROOT)/gcc-$(GCC-VERSION)
GCC-BIN := $(GCC-LOCAL)/bin
override PATH := $(GCC-BIN):$(PATH)

GCC := $(GCC-BIN)/gcc
GPP := $(GCC-BIN)/g++
GFORTRAN := $(GCC-BIN)/gfortran

SHELL-DEPS += $(GCC)


ifeq ($(OS-NAME),windows)
$(GCC) $(GPP) $(GFORTRAN): $(LOCAL-CACHE)/$(GCC-ARCHIVE)
	cd $(LOCAL-ROOT) && unzip -q cache/$(GCC-ARCHIVE)
	mv $(LOCAL-ROOT)/xpack-gcc-$(GCC-VERSION) $(GCC-LOCAL)
	touch $(GCC) $(GPP) $(GFORTRAN)
	@echo
else
$(GCC) $(GPP) $(GFORTRAN): $(LOCAL-CACHE)/$(GCC-ARCHIVE)
	mkdir -p $(GCC-LOCAL)
	tar -C $(GCC-LOCAL) --strip-components=1 -xzf $<
	touch $(GCC) $(GPP) $(GFORTRAN)
	@echo
endif

$(LOCAL-CACHE)/$(GCC-TAR):
	@echo "* Installing 'gcc' locally (via xPack GCC)"
	curl+ $(GCC-DOWN) > $@

endif
