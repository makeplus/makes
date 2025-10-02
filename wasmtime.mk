WASMTIME-VERSION ?= 37.0.1

ifndef WASMTIME-LOADED
WASMTIME-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-linux
OA-linux-int64 := x86_64-linux
OA-macos-arm64 := aarch64-macos
OA-macos-int64 := x86_64-macos

# https://github.com/bytecodealliance/wasmtime/releases/download/v36.0.2/wasmtime-v36.0.2-x86_64-linux.tar.xz
# https://github.com/bytecodealliance/wasmtime/releases/download/v36.0.2/wasmtime-v36.0.2-x86_64-linux.tar.xz

WASMTIME-NAME := wasmtime-v$(WASMTIME-VERSION)-$(OA-$(OS-ARCH))
WASMTIME-TAR := $(WASMTIME-NAME).tar.xz
WASMTIME-DOWN := https://github.com/bytecodealliance/wasmtime
WASMTIME-DOWN := $(WASMTIME-DOWN)/releases/download/v$(WASMTIME-VERSION)/$(WASMTIME-TAR)

WASMTIME := $(LOCAL-BIN)/wasmtime

SHELL-DEPS += $(WASMTIME)


$(WASMTIME): $(LOCAL-CACHE)/$(WASMTIME-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	[[ -e $(LOCAL-CACHE)/$(WASMTIME-NAME)/wasmtime ]]
	mv $(LOCAL-CACHE)/$(WASMTIME-NAME)/wasmtime $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(WASMTIME-TAR):
	@echo "* Installing 'wasmtime' locally"
	curl+ $(WASMTIME-DOWN) > $@

endif
