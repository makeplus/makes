FACTOR-VERSION ?= 0.101
# https://github.com/factor/factor

ifndef FACTOR-LOADED
FACTOR-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-int64 := linux-x86-64
OA-macos-int64 := macos-x86-64
OA-windows-int64 := windows-x86-64

$(if $(OA-$(OS-ARCH)),,$(error factor.mk does not support $(OS-ARCH)))

FACTOR-NAME := factor-$(OA-$(OS-ARCH))-$(FACTOR-VERSION)
ifeq ($(OS-NAME),macos)
FACTOR-ARCHIVE := $(FACTOR-NAME).dmg
else ifeq ($(OS-NAME),windows)
FACTOR-ARCHIVE := $(FACTOR-NAME).zip
else
FACTOR-ARCHIVE := $(FACTOR-NAME).tar.gz
endif
FACTOR-DOWN := https://github.com/factor/factor/releases/download
FACTOR-DOWN := $(FACTOR-DOWN)/$(FACTOR-VERSION)/$(FACTOR-ARCHIVE)

FACTOR-LOCAL := $(LOCAL-ROOT)/factor-$(FACTOR-VERSION)
ifeq ($(OS-NAME),windows)
FACTOR := $(FACTOR-LOCAL)/factor.com
else
FACTOR := $(FACTOR-LOCAL)/factor
endif

override PATH := $(FACTOR-LOCAL):$(PATH)
export PATH

SHELL-DEPS += $(FACTOR)


ifeq ($(OS-NAME),macos)
$(FACTOR): $(LOCAL-CACHE)/$(FACTOR-ARCHIVE)
	@echo "* Installing 'factor' locally"
	mkdir -p $(FACTOR-LOCAL)
	mkdir -p $(LOCAL-TMP)/factor-$(FACTOR-VERSION)
	hdiutil attach $< -mountpoint $(LOCAL-TMP)/factor-$(FACTOR-VERSION)
	cp -R $(LOCAL-TMP)/factor-$(FACTOR-VERSION)/Factor.app/Contents/Resources/* $(FACTOR-LOCAL)/
	hdiutil detach $(LOCAL-TMP)/factor-$(FACTOR-VERSION)
	touch $@
	@echo
else ifeq ($(OS-NAME),windows)
$(FACTOR): $(LOCAL-CACHE)/$(FACTOR-ARCHIVE)
	@echo "* Installing 'factor' locally"
	cd $(LOCAL-CACHE) && unzip -q $(FACTOR-ARCHIVE)
	mv $(LOCAL-CACHE)/factor $(FACTOR-LOCAL)
	touch $@
	@echo
else
$(FACTOR): $(LOCAL-CACHE)/$(FACTOR-ARCHIVE)
	@echo "* Installing 'factor' locally"
	tar -C $(LOCAL-CACHE) -xzf $<
	mv $(LOCAL-CACHE)/factor $(FACTOR-LOCAL)
	touch $@
	@echo
endif

$(LOCAL-CACHE)/$(FACTOR-ARCHIVE):
	@echo "* Downloading 'factor' archive"
	curl+ $(FACTOR-DOWN) > $@

endif
