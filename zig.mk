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

ZIG-DIR := zig-$(OA-$(OS-ARCH))-$(ZIG-VERSION)
ZIG-TAR := $(ZIG-DIR).tar.xz
ZIG-DOWN := https://ziglang.org/download/$(ZIG-VERSION)/$(ZIG-TAR)

ZIG-LOCAL := $(LOCAL-ROOT)/$(ZIG-DIR)
ZIG-BIN := $(ZIG-LOCAL)
override PATH := $(ZIG-BIN):$(PATH)

ZIG := $(ZIG-BIN)/zig

SHELL-DEPS += $(ZIG)


$(ZIG): $(LOCAL-CACHE)/$(ZIG-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	mv $(LOCAL-CACHE)/$(ZIG-DIR) $(ZIG-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(ZIG-TAR):
	@echo "* Installing 'zig' locally"
	curl+ $(ZIG-DOWN) > $@

endif
