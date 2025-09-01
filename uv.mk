UV-VERSION ?= 0.8.14

ifndef UV-LOADED
UV-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-unknown-linux-gnu
OA-linux-int64 := x86_64-unknown-linux-gnu
OA-macos-arm64 := aarch64-apple-darwin
OA-macos-int64 := x86_64-apple-darwin

UV-DIR := uv-$(OA-$(OS-ARCH))
UV-TAR := $(UV-DIR).tar.gz
UV-DOWN := https://github.com/astral-sh/uv/releases/download
UV-DOWN := $(UV-DOWN)/$(UV-VERSION)/$(UV-TAR)

UV := $(LOCAL-BIN)/uv

SHELL-DEPS += $(UV)


$(UV): $(LOCAL-CACHE)/$(UV-TAR)
	tar -C $(LOCAL-CACHE) -xzf $<
	cp $(LOCAL-CACHE)/$(UV-DIR)/uv* $(LOCAL-BIN)/
	touch $@
	@echo

$(LOCAL-CACHE)/$(UV-TAR):
	@echo "Installing 'uv' locally"
	curl+ $(UV-DOWN) > $@

endif
