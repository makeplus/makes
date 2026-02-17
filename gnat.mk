GNAT-VERSION ?= 15.2.0-1
# https://github.com/alire-project/GNAT-FSF-builds

ifndef GNAT-LOADED
GNAT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-linux
OA-linux-int64 := x86_64-linux
OA-macos-arm64 := aarch64-darwin
OA-macos-int64 := x86_64-darwin

GNAT-DIR := gnat-$(OA-$(OS-ARCH))-$(GNAT-VERSION)
GNAT-TAR := $(GNAT-DIR).tar.gz
GNAT-DOWN := https://github.com/alire-project/GNAT-FSF-builds/releases/download
GNAT-DOWN := $(GNAT-DOWN)/gnat-$(GNAT-VERSION)/$(GNAT-TAR)

GNAT-LOCAL := $(LOCAL-ROOT)/$(GNAT-DIR)
GNAT-BIN := $(GNAT-LOCAL)/bin
override PATH := $(GNAT-BIN):$(PATH)

GNATMAKE := $(GNAT-BIN)/gnatmake

SHELL-DEPS += $(GNATMAKE)

$(GNATMAKE): $(LOCAL-CACHE)/$(GNAT-TAR)
	tar -C $(LOCAL-CACHE) -xzf $<
	mv $(LOCAL-CACHE)/$(GNAT-DIR) $(GNAT-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(GNAT-TAR):
	@echo "* Installing 'gnat' locally"
	curl+ $(GNAT-DOWN) > $@

endif
