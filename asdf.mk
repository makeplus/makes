ASDF-VERSION ?= 0.18.0
# https://github.com/asdf-vm/asdf

ifndef ASDF-LOADED
ASDF-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-amd64

ASDF-TAR := asdf-v$(ASDF-VERSION)-$(OA-$(OS-ARCH)).tar.gz
ASDF-DOWN := https://github.com/asdf-vm/asdf/releases/download/v$(ASDF-VERSION)/$(ASDF-TAR)
ASDF-LOCAL := $(LOCAL-ROOT)/asdf-v$(ASDF-VERSION)
ASDF := $(ASDF-LOCAL)/asdf
override PATH := $(ASDF-LOCAL):$(PATH)
export ASDF_DATA_DIR := $(LOCAL-ROOT)/asdf

SHELL-DEPS += $(ASDF)


$(ASDF): $(LOCAL-CACHE)/$(ASDF-TAR)
	mkdir -p $(ASDF-LOCAL)
	tar -C $(ASDF-LOCAL) -xzf $<
	touch $@
	@echo

$(LOCAL-CACHE)/$(ASDF-TAR):
	@echo "* Installing 'asdf' locally"
	curl+ $(ASDF-DOWN) > $@

endif
