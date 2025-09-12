NODE-VERSION ?= 24.8.0
# https://github.com/nodejs/node

ifndef NODE-LOADED
NODE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-x64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-x64

NODE-NAME := node-v$(NODE-VERSION)-$(OA-$(OS-ARCH))
NODE-TAR := $(NODE-NAME).tar.xz
NODE-DOWN := https://nodejs.org/dist/v$(NODE-VERSION)/$(NODE-TAR)
NODE-LOCAL := $(LOCAL-ROOT)/node-v$(NODE-VERSION)
NODE-BIN := $(NODE-LOCAL)/bin
override PATH := $(NODE-BIN):$(PATH)

NODE := $(NODE-BIN)/node

SHELL-DEPS += $(NODE)

$(NODE): $(LOCAL-CACHE)/$(NODE-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	mv $(LOCAL-CACHE)/$(NODE-NAME) $(NODE-LOCAL)
	touch $(NODE)
	@echo

$(LOCAL-CACHE)/$(NODE-TAR):
	@echo "Installing 'node' and 'npm' locally"
	curl+ $(NODE-DOWN) > $@

endif
