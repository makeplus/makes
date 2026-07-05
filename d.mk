LDC-VERSION ?= 1.42.0
# https://github.com/ldc-developers/ldc

ifndef LDC-LOADED
LDC-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x86_64
OA-macos-arm64 := osx-arm64
OA-macos-int64 := osx-x86_64
OA-windows-int64 := windows-x64

LDC-DIR := ldc2-$(LDC-VERSION)-$(OA-$(OS-ARCH))
ifeq ($(OS-NAME),windows)
# LDC only publishes 7z archives for Windows:
LDC-TAR := $(LDC-DIR).7z
else
LDC-TAR := $(LDC-DIR).tar.xz
endif
LDC-DOWN := https://github.com/ldc-developers/ldc/releases/download
LDC-DOWN := $(LDC-DOWN)/v$(LDC-VERSION)/$(LDC-TAR)

LDC-LOCAL := $(LOCAL-ROOT)/$(LDC-DIR)
LDC-BIN := $(LDC-LOCAL)/bin
override PATH := $(LDC-BIN):$(PATH)
export PATH

ifeq ($(OS-NAME),windows)
LDC := $(LDC-BIN)/ldc2.exe
else
LDC := $(LDC-BIN)/ldc2
endif

SHELL-DEPS += $(LDC)


$(LDC): $(LOCAL-CACHE)/$(LDC-TAR)
ifeq ($(OS-NAME),windows)
	7z x -y -o$(LOCAL-CACHE) $< > /dev/null
else
	tar -C $(LOCAL-CACHE) -xf $<
endif
	mv $(LOCAL-CACHE)/$(LDC-DIR) $(LDC-LOCAL)
	touch $@

$(LOCAL-CACHE)/$(LDC-TAR):
	@echo "* Installing 'ldc2' locally"
	curl+ $(LDC-DOWN) > $@

endif
