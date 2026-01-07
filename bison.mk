BISON-VERSION ?= 3.8.2-1
# https://github.com/xpack-dev-tools/bison-xpack

ifndef BISON-LOADED
BISON-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-x64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-x64

BISON-TAR := xpack-bison-$(BISON-VERSION)-$(OA-$(OS-ARCH)).tar.gz
BISON-DOWN := https://github.com/xpack-dev-tools/bison-xpack/releases/download
BISON-DOWN := $(BISON-DOWN)/v$(BISON-VERSION)/$(BISON-TAR)

BISON-LOCAL := $(LOCAL-ROOT)/bison-$(BISON-VERSION)
BISON-BIN := $(BISON-LOCAL)/bin
override PATH := $(BISON-BIN):$(PATH)

BISON := $(BISON-BIN)/bison

SHELL-DEPS += $(BISON)


$(BISON): $(LOCAL-CACHE)/$(BISON-TAR)
	mkdir -p $(BISON-LOCAL)
	tar -C $(BISON-LOCAL) --strip-components=1 -xzf $<
	touch $@
	@echo

$(LOCAL-CACHE)/$(BISON-TAR):
	@echo "* Installing 'bison' locally"
	curl+ $(BISON-DOWN) > $@

endif
