CRYSTAL-VERSION ?= 1.16.3

ifndef CRYSTAL-LOADED
CRYSTAL-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

OA-linux-arm64 := XXX
OA-linux-int64 := linux-x86_64-bundled
OA-macos-arm64 := darwin-universal
OA-macos-int64 := darwin-universal

CRYSTAL-DIR := crystal-$(CRYSTAL-VERSION)-1
CRYSTAL-TARBALL := $(CRYSTAL-DIR)-$(OA-$(OS-ARCH)).tar.gz
CRYSTAL-DOWNLOAD := https://github.com/crystal-lang/crystal/releases/download
CRYSTAL-DOWNLOAD := $(CRYSTAL-DOWNLOAD)/$(CRYSTAL-VERSION)/$(CRYSTAL-TARBALL)

CRYSTAL-LOCAL := $(LOCAL-ROOT)/$(CRYSTAL-DIR)
CRYSTAL-BIN := $(CRYSTAL-LOCAL)/bin
CRYSTAL := $(CRYSTAL-BIN)/crystal

SHELL-DEPS += $(CRYSTAL)

override PATH := $(CRYSTAL-BIN):$(PATH)
export PATH


$(CRYSTAL): $(LOCAL-CACHE)/$(CRYSTAL-TARBALL)
	tar -C $(LOCAL-CACHE) -xzf $<
	mv $(LOCAL-CACHE)/$(CRYSTAL-DIR) $(CRYSTAL-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(CRYSTAL-TARBALL):
	@echo "Installing 'crystal' locally"
	curl+ $(CRYSTAL-DOWNLOAD) > $@

endif
