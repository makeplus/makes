VLANG-VERSION ?= 0.5.1
# https://github.com/vlang/v

ifndef VLANG-LOADED
VLANG-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux
OA-linux-int64 := linux
OA-macos-arm64 := macos
OA-macos-int64 := macos
OA-windows-int64 := windows

VLANG-ZIP := v_$(OA-$(OS-ARCH)).zip
VLANG-DOWN := https://github.com/vlang/v/releases/download
VLANG-DOWN := $(VLANG-DOWN)/$(VLANG-VERSION)/$(VLANG-ZIP)

VLANG-LOCAL := $(LOCAL-ROOT)/vlang-$(VLANG-VERSION)
VLANG-BIN := $(VLANG-LOCAL)
override PATH := $(VLANG-BIN):$(PATH)
export PATH

ifeq ($(OS-NAME),windows)
VLANG := $(VLANG-BIN)/v.exe
else
VLANG := $(VLANG-BIN)/v
endif

SHELL-DEPS += $(VLANG)

$(VLANG): $(LOCAL-CACHE)/$(VLANG-ZIP)
	cd $(LOCAL-CACHE) && unzip -qo $(VLANG-ZIP)
	rm -rf $(VLANG-LOCAL)
	mv $(LOCAL-CACHE)/v $(VLANG-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(VLANG-ZIP):
	@echo "* Installing 'v' locally"
	curl+ $(VLANG-DOWN) > $@

endif
