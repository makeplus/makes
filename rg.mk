RG-VERSION ?= 15.2.0
# https://github.com/BurntSushi/ripgrep

ifndef RG-LOADED
RG-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-unknown-linux-gnu
OA-linux-int64 := x86_64-unknown-linux-musl
OA-macos-arm64 := aarch64-apple-darwin
OA-macos-int64 := x86_64-apple-darwin

RG-NAME := ripgrep-$(RG-VERSION)-$(OA-$(OS-ARCH))
RG-TAR := $(RG-NAME).tar.gz
RG-DOWN := https://github.com/BurntSushi/ripgrep
RG-DOWN := $(RG-DOWN)/releases/download/$(RG-VERSION)/$(RG-TAR)

RG := $(LOCAL-BIN)/rg

SHELL-DEPS += $(RG)


$(RG): $(LOCAL-CACHE)/$(RG-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	[[ -e $(LOCAL-CACHE)/$(RG-NAME)/rg ]]
	mv $(LOCAL-CACHE)/$(RG-NAME)/rg $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(RG-TAR):
	@echo "* Installing 'rg' locally"
	curl+ $(RG-DOWN) > $@

endif
