NIM-VERSION ?= 2.2.10
# https://github.com/nim-lang/Nim

ifndef NIM-LOADED
NIM-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux_arm64
OA-linux-int64 := linux_x64
OA-macos-arm64 := macosx_arm64
OA-macos-int64 := macosx_x64

NIM-DIR := nim-$(NIM-VERSION)
ifeq ($(OS-NAME),windows)
# Windows builds are only published for x64, named without an OS part:
NIM-TAR := $(NIM-DIR)_x64.zip
else
NIM-TAR := $(NIM-DIR)-$(OA-$(OS-ARCH)).tar.xz
endif
NIM-DOWN := https://nim-lang.org/download
NIM-DOWN := $(NIM-DOWN)/$(NIM-TAR)

NIM-LOCAL := $(LOCAL-ROOT)/$(NIM-DIR)
NIM-BIN := $(NIM-LOCAL)/bin
override PATH := $(NIM-BIN):$(PATH)
export PATH

ifeq ($(OS-NAME),windows)
NIM := $(NIM-BIN)/nim.exe
else
NIM := $(NIM-BIN)/nim
endif

SHELL-DEPS += $(NIM)

$(NIM): $(LOCAL-CACHE)/$(NIM-TAR)
ifeq ($(OS-NAME),windows)
	unzip -q -d $(LOCAL-CACHE) $<
else
	tar -C $(LOCAL-CACHE) -xJf $<
endif
	rm -rf $(NIM-LOCAL)
	mv $(LOCAL-CACHE)/nim-$(NIM-VERSION) $(NIM-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(NIM-TAR):
	@echo "* Installing 'nim' locally"
	curl+ $(NIM-DOWN) > $@

endif
