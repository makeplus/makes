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
export PATH

# xPack-built programs need the runtime libraries, not only the compiler.
# Export only the selected native ABI directory, never the lib32 directory.
ifeq ($(OS-NAME),linux)
GCC-LIB := $(GCC-LOCAL)/$(if $(filter int64,$(ARCH-NAME)),lib64,lib)
override LD_LIBRARY_PATH := $(GCC-LIB)$(if $(LD_LIBRARY_PATH),:$(LD_LIBRARY_PATH))
export LD_LIBRARY_PATH
else ifeq ($(OS-NAME),macos)
GCC-LIB := $(GCC-LOCAL)/lib
override DYLD_LIBRARY_PATH := $(GCC-LIB)$(if $(DYLD_LIBRARY_PATH),:$(DYLD_LIBRARY_PATH))
export DYLD_LIBRARY_PATH
endif

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
