DART-VERSION ?= 3.6.2
# https://dart.dev

ifndef DART-LOADED
DART-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-arm64
OA-macos-int64 := macos-x64

DART-ZIP := dartsdk-$(OA-$(OS-ARCH))-release.zip
DART-DOWN := https://storage.googleapis.com/dart-archive/channels/stable/release
DART-DOWN := $(DART-DOWN)/$(DART-VERSION)/sdk/$(DART-ZIP)

DART-LOCAL := $(LOCAL-ROOT)/dart-$(DART-VERSION)
DART-BIN := $(DART-LOCAL)/bin
override PATH := $(DART-BIN):$(PATH)

DART := $(DART-BIN)/dart

SHELL-DEPS += $(DART)

$(DART): $(LOCAL-CACHE)/$(DART-ZIP)
	cd $(LOCAL-CACHE) && unzip -qo $(DART-ZIP)
	rm -rf $(DART-LOCAL)
	mv $(LOCAL-CACHE)/dart-sdk $(DART-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(DART-ZIP):
	@echo "* Installing 'dart' locally"
	curl+ $(DART-DOWN) > $@

endif
