ZIG-VERSION ?= 0.15.2
# https://github.com/ziglang/zig

ifndef ZIG-LOADED
ZIG-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-linux
OA-linux-int64 := x86_64-linux
OA-macos-arm64 := aarch64-macos
OA-macos-int64 := x86_64-macos
OA-windows-arm64 := aarch64-windows
OA-windows-int64 := x86_64-windows

ZIG-DIR := zig-$(OA-$(OS-ARCH))-$(ZIG-VERSION)
ifeq ($(OS-NAME),windows)
ZIG-TAR := $(ZIG-DIR).zip
else
ZIG-TAR := $(ZIG-DIR).tar.xz
endif
ZIG-DOWN := https://ziglang.org/download/$(ZIG-VERSION)/$(ZIG-TAR)

ZIG-LOCAL := $(LOCAL-ROOT)/$(ZIG-DIR)
ZIG-BIN := $(ZIG-LOCAL)
override PATH := $(ZIG-BIN):$(PATH)
export PATH

ifeq ($(OS-NAME),windows)
ZIG := $(ZIG-BIN)/zig.exe
else
ZIG := $(ZIG-BIN)/zig
endif

SHELL-DEPS += $(ZIG)


ifeq ($(OS-NAME),windows)
$(ZIG): $(LOCAL-CACHE)/$(ZIG-TAR)
	unzip -q -d $(LOCAL-CACHE) $<
	mv $(LOCAL-CACHE)/$(ZIG-DIR) $(ZIG-LOCAL)
	touch $@
	@echo
else
$(ZIG): $(LOCAL-CACHE)/$(ZIG-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	mv $(LOCAL-CACHE)/$(ZIG-DIR) $(ZIG-LOCAL)
	touch $@
	@echo
endif

$(LOCAL-CACHE)/$(ZIG-TAR):
	@echo "* Installing 'zig' locally"
	curl+ $(ZIG-DOWN) > $@

endif
