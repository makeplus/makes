CRYSTAL-VERSION ?= 1.17.1

ifndef CRYSTAL-LOADED
CRYSTAL-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := XXX
OA-linux-int64 := linux-x86_64-bundled
OA-macos-arm64 := darwin-universal
OA-macos-int64 := darwin-universal

CRYSTAL-DIR := crystal-$(CRYSTAL-VERSION)-1
CRYSTAL-TAR := $(CRYSTAL-DIR)-$(OA-$(OS-ARCH)).tar.gz
CRYSTAL-DOWN := https://github.com/crystal-lang/crystal/releases/download
CRYSTAL-DOWN := $(CRYSTAL-DOWN)/$(CRYSTAL-VERSION)/$(CRYSTAL-TAR)

CRYSTAL-LOCAL := $(LOCAL-ROOT)/$(CRYSTAL-DIR)
CRYSTAL-BIN := $(CRYSTAL-LOCAL)/bin
override PATH := $(CRYSTAL-BIN):$(PATH)

CRYSTAL := $(CRYSTAL-BIN)/crystal

SHELL-DEPS += $(CRYSTAL)


$(CRYSTAL): $(LOCAL-CACHE)/$(CRYSTAL-TAR)
	tar -C $(LOCAL-CACHE) -xzf $<
	mv $(LOCAL-CACHE)/$(CRYSTAL-DIR) $(CRYSTAL-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(CRYSTAL-TAR):
	@echo "Installing 'crystal' locally"
	curl+ $(CRYSTAL-DOWN) > $@

endif
