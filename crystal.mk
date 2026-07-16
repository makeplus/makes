CRYSTAL-VERSION ?= 1.21.0

ifndef CRYSTAL-LOADED
CRYSTAL-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := XXX
OA-linux-int64 := linux-x86_64-bundled
OA-macos-arm64 := darwin-universal
OA-macos-int64 := darwin-universal
OA-windows-arm64 := windows-aarch64-gnu-unsupported
OA-windows-int64 := windows-x86_64-gnu-unsupported

CRYSTAL-DIR := crystal-$(CRYSTAL-VERSION)-1
ifeq ($(OS-NAME),windows)
CRYSTAL-TAR := crystal-$(CRYSTAL-VERSION)-$(OA-$(OS-ARCH)).zip
else
CRYSTAL-TAR := $(CRYSTAL-DIR)-$(OA-$(OS-ARCH)).tar.gz
endif
CRYSTAL-DOWN := https://github.com/crystal-lang/crystal/releases/download
CRYSTAL-DOWN := $(CRYSTAL-DOWN)/$(CRYSTAL-VERSION)/$(CRYSTAL-TAR)

CRYSTAL-LOCAL := $(LOCAL-ROOT)/$(CRYSTAL-DIR)
CRYSTAL-BIN := $(CRYSTAL-LOCAL)/bin
override PATH := $(CRYSTAL-BIN):$(PATH)
export PATH

ifeq ($(OS-NAME),windows)
CRYSTAL := $(CRYSTAL-BIN)/crystal.exe
else
CRYSTAL := $(CRYSTAL-BIN)/crystal
endif

SHELL-DEPS += $(CRYSTAL)


ifeq ($(OS-NAME),windows)
$(CRYSTAL): $(LOCAL-CACHE)/$(CRYSTAL-TAR)
	mkdir -p $(CRYSTAL-LOCAL)
	cd $(CRYSTAL-LOCAL) && unzip -q $(LOCAL-CACHE)/$(CRYSTAL-TAR)
	touch $@
	@echo
else
$(CRYSTAL): $(LOCAL-CACHE)/$(CRYSTAL-TAR)
	tar -C $(LOCAL-CACHE) -xzf $<
	mv $(LOCAL-CACHE)/$(CRYSTAL-DIR) $(CRYSTAL-LOCAL)
	touch $@
	@echo
endif

$(LOCAL-CACHE)/$(CRYSTAL-TAR):
	@echo "* Installing 'crystal' locally"
	curl+ $(CRYSTAL-DOWN) > $@

endif
