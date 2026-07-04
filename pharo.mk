PHARO-VERSION ?= 3.4.4
# https://github.com/pharo-project/pharo-launcher

ifndef PHARO-LOADED
PHARO-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-int64 := linux-$(PHARO-VERSION)-x64
OA-macos-arm64 := mac-$(PHARO-VERSION)-arm64
OA-macos-int64 := mac-$(PHARO-VERSION)-x64
OA-windows-int64 := windows-$(PHARO-VERSION)

ifeq ($(OS-NAME),windows)
  PHARO-ZIP := PharoLauncher-$(OA-$(OS-ARCH)).zip
  PHARO-EXE := PharoLauncher.exe
else ifeq ($(OS-NAME),linux)
  PHARO-ZIP := PharoLauncher-$(OA-$(OS-ARCH)).zip
  PHARO-EXE := pharo-launcher
else
  PHARO-ZIP := PharoLauncher-$(OA-$(OS-ARCH)).zip
  PHARO-EXE := PharoLauncher
endif

PHARO-DOWN := https://github.com/pharo-project/pharo-launcher/releases/download/$(PHARO-VERSION)/$(PHARO-ZIP)
PHARO-LOCAL := $(LOCAL-ROOT)/pharo-$(PHARO-VERSION)
PHARO := $(PHARO-LOCAL)/$(PHARO-EXE)

SHELL-DEPS += $(PHARO)

override PATH := $(PHARO-LOCAL):$(PATH)
export PATH


$(PHARO): $(LOCAL-CACHE)/$(PHARO-ZIP)
	$Q rm -rf $(PHARO-LOCAL) $(LOCAL-TMP)/pharo-$(PHARO-VERSION)
	$Q mkdir -p $(LOCAL-TMP)/pharo-$(PHARO-VERSION)
	$Q unzip -q $< -d $(LOCAL-TMP)/pharo-$(PHARO-VERSION)
	$Q find $(LOCAL-TMP)/pharo-$(PHARO-VERSION) -name '*.tar' -type f -exec tar -C $(LOCAL-TMP)/pharo-$(PHARO-VERSION) -xf {} \;
	$Q exe=$$(find $(LOCAL-TMP)/pharo-$(PHARO-VERSION) -name $(PHARO-EXE) -type f | head -1); \
	  [[ -n "$$exe" ]]; \
	  mv "$${exe%/$(PHARO-EXE)}" $(PHARO-LOCAL)
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/$(PHARO-ZIP):
	@$(ECHO) "* Installing 'pharo launcher' locally"
	$Q curl+ $(PHARO-DOWN) > $@

endif
