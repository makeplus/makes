BB-VERSION ?= 1.12.204

ifndef BB-LOADED
BB-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-amd64-static
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-amd64

BB-NAME := babashka-$(BB-VERSION)-$(OA-$(OS-ARCH))
BB-TAR := $(BB-NAME).tar.gz
BB-DOWN := https://github.com/babashka/babashka
BB-DOWN := $(BB-DOWN)/releases/download/v$(BB-VERSION)/$(BB-TAR)

BB := $(LOCAL-BIN)/bb

SHELL-DEPS += $(BB)


$(BB): $(LOCAL-CACHE)/$(BB-TAR)
	tar -C $(LOCAL-CACHE) -xf $< -- bb
	[[ -e $(LOCAL-CACHE)/bb ]]
	mv $(LOCAL-CACHE)/bb $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(BB-TAR):
	@echo "Installing 'bb' locally"
	curl+ $(BB-DOWN) > $@

endif
