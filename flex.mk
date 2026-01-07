FLEX-VERSION ?= 2.6.4-1
# https://github.com/xpack-dev-tools/flex-xpack

ifndef FLEX-LOADED
FLEX-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-x64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-x64

FLEX-TAR := xpack-flex-$(FLEX-VERSION)-$(OA-$(OS-ARCH)).tar.gz
FLEX-DOWN := https://github.com/xpack-dev-tools/flex-xpack/releases/download
FLEX-DOWN := $(FLEX-DOWN)/v$(FLEX-VERSION)/$(FLEX-TAR)

FLEX-LOCAL := $(LOCAL-ROOT)/flex-$(FLEX-VERSION)
FLEX-BIN := $(FLEX-LOCAL)/bin
override PATH := $(FLEX-BIN):$(PATH)

FLEX := $(FLEX-BIN)/flex

SHELL-DEPS += $(FLEX)


$(FLEX): $(LOCAL-CACHE)/$(FLEX-TAR)
	mkdir -p $(FLEX-LOCAL)
	tar -C $(FLEX-LOCAL) --strip-components=1 -xzf $<
	touch $@
	@echo

$(LOCAL-CACHE)/$(FLEX-TAR):
	@echo "* Installing 'flex' locally"
	curl+ $(FLEX-DOWN) > $@

endif
