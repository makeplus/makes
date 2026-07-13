TREALLA-VERSION ?= 2.103.13
# https://github.com/trealla-prolog/trealla

ifndef PROLOG-LOADED
PROLOG-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-arm64
OA-windows-int64 := windows-x64

ifeq ($(OS-NAME),windows)
  TPL-EXE := tpl.exe
else
  TPL-EXE := tpl
endif

TPL-ZIP := tpl-$(OA-$(OS-ARCH)).zip
TPL-DOWN := https://github.com/trealla-prolog/trealla/releases/download/v$(TREALLA-VERSION)/$(TPL-ZIP)
TPL-LOCAL := $(LOCAL-ROOT)/trealla-$(TREALLA-VERSION)
TPL := $(TPL-LOCAL)/bin/$(TPL-EXE)

SHELL-DEPS += $(TPL)

override PATH := $(TPL-LOCAL)/bin:$(PATH)
export PATH


$(TPL): $(LOCAL-CACHE)/$(TPL-ZIP)
	$Q rm -rf $(LOCAL-TMP)/trealla-$(TREALLA-VERSION)
	$Q mkdir -p $(TPL-LOCAL)/bin $(LOCAL-TMP)/trealla-$(TREALLA-VERSION)
	$Q unzip -q $< -d $(LOCAL-TMP)/trealla-$(TREALLA-VERSION)
	$Q cp $$(find $(LOCAL-TMP)/trealla-$(TREALLA-VERSION) -name $(TPL-EXE) -type f | head -1) $@
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/$(TPL-ZIP):
	@$(ECHO) "* Installing 'trealla prolog' locally"
	$Q curl+ $(TPL-DOWN) > $@

endif
