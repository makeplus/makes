UIUA-VERSION ?= 0.18.1
# https://github.com/uiua-lang/uiua

ifndef UIUA-LOADED
UIUA-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-int64 := x86_64-unknown-linux-gnu
OA-macos-arm64 := aarch64-apple-darwin
OA-macos-int64 := x86_64-apple-darwin
OA-windows-arm64 := aarch64-pc-windows-msvc
OA-windows-int64 := x86_64-pc-windows-msvc

ifeq (windows,$(OS-NAME))
  UIUA-EXE := uiua.exe
else
  UIUA-EXE := uiua
endif

UIUA-ZIP := uiua-bin-$(OA-$(OS-ARCH)).zip
UIUA-DOWN := https://github.com/uiua-lang/uiua/releases/download/$(UIUA-VERSION)/$(UIUA-ZIP)
UIUA-LOCAL := $(LOCAL-ROOT)/uiua-$(UIUA-VERSION)
UIUA := $(UIUA-LOCAL)/bin/$(UIUA-EXE)

SHELL-DEPS += $(UIUA)

override PATH := $(UIUA-LOCAL)/bin:$(PATH)
export PATH


$(UIUA): $(LOCAL-CACHE)/$(UIUA-ZIP)
	$Q rm -rf $(LOCAL-TMP)/uiua-$(UIUA-VERSION)
	$Q mkdir -p $(UIUA-LOCAL)/bin $(LOCAL-TMP)/uiua-$(UIUA-VERSION)
	$Q unzip -q $< -d $(LOCAL-TMP)/uiua-$(UIUA-VERSION)
	$Q cp $$(find $(LOCAL-TMP)/uiua-$(UIUA-VERSION) -name $(UIUA-EXE) -type f | head -1) $@
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/$(UIUA-ZIP):
	@$(ECHO) "* Installing 'uiua' locally"
	$Q curl+ $(UIUA-DOWN) > $@

endif
