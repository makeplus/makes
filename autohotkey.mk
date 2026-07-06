AUTOHOTKEY-VERSION ?= 2.0.26
# https://github.com/AutoHotkey/AutoHotkey

ifndef AUTOHOTKEY-LOADED
AUTOHOTKEY-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

$(if $(filter windows-int64,$(OS-ARCH)),,$(error autohotkey.mk does not support $(OS-ARCH)))

AUTOHOTKEY-ZIP := AutoHotkey_$(AUTOHOTKEY-VERSION).zip
AUTOHOTKEY-DOWN := https://github.com/AutoHotkey/AutoHotkey/releases/download/v$(AUTOHOTKEY-VERSION)/$(AUTOHOTKEY-ZIP)
AUTOHOTKEY-LOCAL := $(LOCAL-ROOT)/autohotkey-$(AUTOHOTKEY-VERSION)
AUTOHOTKEY := $(AUTOHOTKEY-LOCAL)/AutoHotkey64.exe

SHELL-DEPS += $(AUTOHOTKEY)

override PATH := $(AUTOHOTKEY-LOCAL):$(PATH)
export PATH

$(AUTOHOTKEY): $(LOCAL-CACHE)/$(AUTOHOTKEY-ZIP)
	@$(ECHO) "* Installing 'autohotkey' locally"
	$Q rm -rf $(AUTOHOTKEY-LOCAL)
	$Q mkdir -p $(AUTOHOTKEY-LOCAL)
	$Q unzip -q -d $(AUTOHOTKEY-LOCAL) $<
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(AUTOHOTKEY-ZIP):
	@$(ECHO) "* Downloading 'autohotkey' archive"
	$Q curl+ $(AUTOHOTKEY-DOWN) > $@

endif
