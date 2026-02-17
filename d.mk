LDC-VERSION ?= 1.41.0
# https://github.com/ldc-developers/ldc

ifndef LDC-LOADED
LDC-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x86_64
OA-macos-arm64 := osx-arm64
OA-macos-int64 := osx-x86_64

LDC-DIR := ldc2-$(LDC-VERSION)-$(OA-$(OS-ARCH))
LDC-TAR := $(LDC-DIR).tar.xz
LDC-DOWN := https://github.com/ldc-developers/ldc/releases/download
LDC-DOWN := $(LDC-DOWN)/v$(LDC-VERSION)/$(LDC-TAR)

LDC-LOCAL := $(LOCAL-ROOT)/$(LDC-DIR)
LDC-BIN := $(LDC-LOCAL)/bin
override PATH := $(LDC-BIN):$(PATH)

LDC := $(LDC-BIN)/ldc2

SHELL-DEPS += $(LDC)


$(LDC): $(LOCAL-CACHE)/$(LDC-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	mv $(LOCAL-CACHE)/$(LDC-DIR) $(LDC-LOCAL)
	touch $@

$(LOCAL-CACHE)/$(LDC-TAR):
	@echo "* Installing 'ldc2' locally"
	curl+ $(LDC-DOWN) > $@

endif
