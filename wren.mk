WREN-VERSION ?= 0.4.0
# https://github.com/wren-lang/wren-cli

ifndef WREN-LOADED
WREN-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux
OA-linux-int64 := linux
OA-macos-arm64 := mac
OA-macos-int64 := mac
OA-windows-arm64 := windows
OA-windows-int64 := windows

ifeq (windows,$(OS-NAME))
  WREN-EXE := wren_cli.exe
else
  WREN-EXE := wren_cli
endif

WREN-ZIP := wren-cli-$(OA-$(OS-ARCH))-$(WREN-VERSION).zip
WREN-DOWN := https://github.com/wren-lang/wren-cli/releases/download/$(WREN-VERSION)/$(WREN-ZIP)
WREN-LOCAL := $(LOCAL-ROOT)/wren-$(WREN-VERSION)
WREN := $(WREN-LOCAL)/bin/$(WREN-EXE)

SHELL-DEPS += $(WREN)

override PATH := $(WREN-LOCAL)/bin:$(PATH)
export PATH


$(WREN): $(LOCAL-CACHE)/$(WREN-ZIP)
	$Q rm -rf $(LOCAL-TMP)/wren-$(WREN-VERSION)
	$Q mkdir -p $(WREN-LOCAL)/bin $(LOCAL-TMP)/wren-$(WREN-VERSION)
	$Q unzip -q $< -d $(LOCAL-TMP)/wren-$(WREN-VERSION)
	$Q cp $$(find $(LOCAL-TMP)/wren-$(WREN-VERSION) -name $(WREN-EXE) -type f | head -1) $@
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/$(WREN-ZIP):
	@$(ECHO) "* Installing 'wren' locally"
	$Q curl+ $(WREN-DOWN) > $@

endif
