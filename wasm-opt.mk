WASM-OPT-VERSION ?= version_126

ifndef WASM-OPT-LOADED
WASM-OPT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-linux
OA-linux-int64 := x86_64-linux
OA-macos-arm64 := arm64-macos
OA-macos-int64 := x86_64-macos

# https://github.com/WebAssembly/binaryen/releases/download/version_126/binaryen-version_126-x86_64-linux.tar.gz

WASM-OPT-TAR := binaryen-$(WASM-OPT-VERSION)-$(OA-$(OS-ARCH)).tar.gz
WASM-OPT-DIR := binaryen-$(WASM-OPT-VERSION)
WASM-OPT-DOWN := https://github.com/WebAssembly/binaryen
WASM-OPT-DOWN := $(WASM-OPT-DOWN)/releases/download/$(WASM-OPT-VERSION)/$(WASM-OPT-TAR)

WASM-OPT := $(LOCAL-BIN)/wasm-opt

SHELL-DEPS += $(WASM-OPT)


$(WASM-OPT): $(LOCAL-CACHE)/$(WASM-OPT-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	[[ -e $(LOCAL-CACHE)/$(WASM-OPT-DIR)/bin/wasm-opt ]]
	mv $(LOCAL-CACHE)/$(WASM-OPT-DIR)/bin/wasm-opt $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(WASM-OPT-TAR):
	@echo "* Installing 'wasm-opt' locally"
	curl+ $(WASM-OPT-DOWN) > $@

endif
