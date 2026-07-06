HAXE-VERSION ?= 4.3.7
# https://github.com/HaxeFoundation/haxe

ifndef HAXE-LOADED
HAXE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux64
OA-macos-arm64 := osx
OA-macos-int64 := osx
OA-windows-int64 := win64

$(if $(OA-$(OS-ARCH)),,$(error haxe.mk does not support $(OS-ARCH)))

ifeq ($(OS-NAME),windows)
HAXE-ARCHIVE := haxe-$(HAXE-VERSION)-$(OA-$(OS-ARCH)).zip
HAXE := $(HAXE-LOCAL)/haxe.exe
else
HAXE-ARCHIVE := haxe-$(HAXE-VERSION)-$(OA-$(OS-ARCH)).tar.gz
HAXE := $(HAXE-LOCAL)/haxe
endif
HAXE-DOWN := https://github.com/HaxeFoundation/haxe/releases/download/$(HAXE-VERSION)/$(HAXE-ARCHIVE)
HAXE-LOCAL := $(LOCAL-ROOT)/haxe-$(HAXE-VERSION)

SHELL-DEPS += $(HAXE)

override PATH := $(HAXE-LOCAL):$(PATH)
export PATH

ifeq ($(OS-NAME),windows)
$(HAXE): $(LOCAL-CACHE)/$(HAXE-ARCHIVE)
	@$(ECHO) "* Installing 'haxe' locally"
	$Q rm -rf $(HAXE-LOCAL) $(LOCAL-TMP)/haxe-$(HAXE-VERSION)
	$Q mkdir -p $(LOCAL-TMP)/haxe-$(HAXE-VERSION)
	$Q unzip -q -d $(LOCAL-TMP)/haxe-$(HAXE-VERSION) $<
	$Q mv $$(find $(LOCAL-TMP)/haxe-$(HAXE-VERSION) -mindepth 1 -maxdepth 1 -type d | head -1) $(HAXE-LOCAL)
	$Q touch $@
	@$(ECHO)
else
$(HAXE): $(LOCAL-CACHE)/$(HAXE-ARCHIVE)
	@$(ECHO) "* Installing 'haxe' locally"
	$Q rm -rf $(HAXE-LOCAL) $(LOCAL-TMP)/haxe-$(HAXE-VERSION)
	$Q mkdir -p $(LOCAL-TMP)/haxe-$(HAXE-VERSION)
	$Q tar -C $(LOCAL-TMP)/haxe-$(HAXE-VERSION) -xzf $<
	$Q mv $$(find $(LOCAL-TMP)/haxe-$(HAXE-VERSION) -mindepth 1 -maxdepth 1 -type d | head -1) $(HAXE-LOCAL)
	$Q touch $@
	@$(ECHO)
endif

$(LOCAL-CACHE)/$(HAXE-ARCHIVE):
	@$(ECHO) "* Downloading 'haxe' archive"
	$Q curl+ $(HAXE-DOWN) > $@

endif
