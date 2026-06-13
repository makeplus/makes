BUN-VERSION ?= 1.3.14
# https://github.com/oven-sh/bun

ifndef BUN-LOADED
BUN-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x64
OA-macos-arm64 := darwin-aarch64
OA-macos-int64 := darwin-x64

BUN-NAME := bun-$(OA-$(OS-ARCH))
BUN-ZIP := $(BUN-NAME).zip
BUN-DOWN := \
  https://github.com/oven-sh/bun/releases/download/bun-v$(BUN-VERSION)/$(BUN-ZIP)
BUN-LOCAL := $(LOCAL-ROOT)/bun-v$(BUN-VERSION)
BUN := $(BUN-LOCAL)/bin/bun
SHELL-DEPS += $(BUN)

override PATH := $(BUN-LOCAL)/bin:$(PATH)
export PATH

$(BUN): $(LOCAL-CACHE)/$(BUN-ZIP)
	unzip -q -o $< -d $(LOCAL-CACHE)
	mkdir -p $(BUN-LOCAL)/bin
	mv $(LOCAL-CACHE)/$(BUN-NAME)/bun $(BUN-LOCAL)/bin/
	rm -fr $(LOCAL-CACHE)/$(BUN-NAME)
	touch $@
	@echo

$(LOCAL-CACHE)/$(BUN-ZIP):
	@echo "* Installing 'bun' locally"
	curl+ $(BUN-DOWN) > $@

endif
