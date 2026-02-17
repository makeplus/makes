NIM-VERSION ?= 2.2.6
# https://github.com/nim-lang/Nim

ifndef NIM-LOADED
NIM-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux_arm64
OA-linux-int64 := linux_x64
OA-macos-arm64 := macos_arm64
OA-macos-int64 := macos_x64

NIM-DIR := nim-$(NIM-VERSION)
NIM-TAR := $(NIM-DIR)-$(OA-$(OS-ARCH)).tar.xz
NIM-DOWN := https://nim-lang.org/download
NIM-DOWN := $(NIM-DOWN)/$(NIM-TAR)

NIM-LOCAL := $(LOCAL-ROOT)/$(NIM-DIR)
NIM-BIN := $(NIM-LOCAL)/bin
override PATH := $(NIM-BIN):$(PATH)

NIM := $(NIM-BIN)/nim

SHELL-DEPS += $(NIM)

$(NIM): $(LOCAL-CACHE)/$(NIM-TAR)
	tar -C $(LOCAL-CACHE) -xJf $<
	rm -rf $(NIM-LOCAL)
	mv $(LOCAL-CACHE)/nim-$(NIM-VERSION) $(NIM-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(NIM-TAR):
	@echo "* Installing 'nim' locally"
	curl+ $(NIM-DOWN) > $@

endif
