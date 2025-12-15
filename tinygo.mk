TINYGO-VERSION ?= 0.40.0

ifndef TINYGO-LOADED
TINYGO-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-amd64

TINYGO-DIR := tinygo-$(TINYGO-VERSION)
TINYGO-TAR := tinygo$(TINYGO-VERSION).$(OA-$(OS-ARCH)).tar.gz
TINYGO-DOWN := https://github.com/tinygo-org/tinygo/releases/download
TINYGO-DOWN := $(TINYGO-DOWN)/v$(TINYGO-VERSION)/$(TINYGO-TAR)

TINYGO-LOCAL := $(LOCAL-ROOT)/$(TINYGO-DIR)
TINYGO-BIN := $(TINYGO-LOCAL)/bin
override PATH := $(TINYGO-BIN):$(PATH)

TINYGO := $(TINYGO-BIN)/tinygo

SHELL-DEPS += $(TINYGO)


$(TINYGO): $(LOCAL-CACHE)/$(TINYGO-TAR)
	tar -C $(LOCAL-CACHE) -xzf $<
	mv $(LOCAL-CACHE)/tinygo $(TINYGO-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(TINYGO-TAR):
	@echo "* Installing 'tinygo' locally"
	curl+ $(TINYGO-DOWN) > $@

endif
