NODE-VERSION ?= 25.5.0
# https://github.com/nodejs/node

ifndef NODE-LOADED
NODE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-x64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-x64
OA-windows-arm64 := win-arm64
OA-windows-int64 := win-x64

NODE-NAME := node-v$(NODE-VERSION)-$(OA-$(OS-ARCH))
ifeq ($(OS-NAME),windows)
NODE-TAR := $(NODE-NAME).zip
else
NODE-TAR := $(NODE-NAME).tar.xz
endif
NODE-DOWN := https://nodejs.org/dist/v$(NODE-VERSION)/$(NODE-TAR)
NODE-LOCAL := $(LOCAL-ROOT)/node-v$(NODE-VERSION)
ifeq ($(OS-NAME),windows)
NODE-BIN := $(NODE-LOCAL)
NODE := $(NODE-BIN)/node.exe
else
NODE-BIN := $(NODE-LOCAL)/bin
NODE := $(NODE-BIN)/node
endif
override PATH := $(NODE-BIN):$(PATH)

SHELL-DEPS += $(NODE)

ifeq ($(OS-NAME),windows)
$(NODE): $(LOCAL-CACHE)/$(NODE-TAR)
	cd $(LOCAL-CACHE) && unzip -q $(NODE-TAR)
	mv $(LOCAL-CACHE)/$(NODE-NAME) $(NODE-LOCAL)
	touch $(NODE)
	@echo
else
$(NODE): $(LOCAL-CACHE)/$(NODE-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	mv $(LOCAL-CACHE)/$(NODE-NAME) $(NODE-LOCAL)
	touch $(NODE)
	@echo
endif

$(LOCAL-CACHE)/$(NODE-TAR):
	@echo "* Installing 'node' and 'npm' locally"
	curl+ $(NODE-DOWN) > $@

endif
