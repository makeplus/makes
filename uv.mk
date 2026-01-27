UV-VERSION ?= 0.9.27

ifndef UV-LOADED
UV-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-unknown-linux-gnu
OA-linux-int64 := x86_64-unknown-linux-gnu
OA-macos-arm64 := aarch64-apple-darwin
OA-macos-int64 := x86_64-apple-darwin
OA-windows-arm64 := aarch64-pc-windows-msvc
OA-windows-int64 := x86_64-pc-windows-msvc

UV-DIR := uv-$(OA-$(OS-ARCH))
ifeq ($(OS-NAME),windows)
UV-TAR := $(UV-DIR).zip
else
UV-TAR := $(UV-DIR).tar.gz
endif
UV-DOWN := https://github.com/astral-sh/uv/releases/download
UV-DOWN := $(UV-DOWN)/$(UV-VERSION)/$(UV-TAR)

UV := $(LOCAL-BIN)/uv

SHELL-DEPS += $(UV)


ifeq ($(OS-NAME),windows)
$(UV): $(LOCAL-CACHE)/$(UV-TAR)
	cd $(LOCAL-CACHE) && unzip -q $(UV-TAR)
	cp $(LOCAL-CACHE)/uv.exe $(LOCAL-BIN)/
	touch $@
	@echo
else
$(UV): $(LOCAL-CACHE)/$(UV-TAR)
	tar -C $(LOCAL-CACHE) -xzf $<
	cp $(LOCAL-CACHE)/$(UV-DIR)/uv* $(LOCAL-BIN)/
	touch $@
	@echo
endif

$(LOCAL-CACHE)/$(UV-TAR):
	@echo "* Installing 'uv' locally"
	curl+ $(UV-DOWN) > $@

endif
