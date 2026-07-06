J-VERSION ?= 9.7.1
# https://github.com/jsoftware/jsource

ifndef J-LOADED
J-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-int64 := linux
OA-macos-arm64 := mac
OA-macos-int64 := mac
OA-windows-int64 := win

$(if $(OA-$(OS-ARCH)),,$(error j.mk does not support $(OS-ARCH)))

ifeq ($(OS-NAME),windows)
J-ARCHIVE := j$(J-VERSION)_$(OA-$(OS-ARCH)).zip
J := $(J-LOCAL)/bin/jconsole.exe
else ifeq ($(OS-NAME),macos)
J-ARCHIVE := j$(J-VERSION)_$(OA-$(OS-ARCH)).zip
J := $(J-LOCAL)/bin/jconsole
else
J-ARCHIVE := j$(J-VERSION)_$(OA-$(OS-ARCH)).tar.gz
J := $(J-LOCAL)/bin/jconsole
endif
J-DOWN := https://www.jsoftware.com/download/j9.7/install/$(J-ARCHIVE)
J-LOCAL := $(LOCAL-ROOT)/j-$(J-VERSION)

SHELL-DEPS += $(J)

override PATH := $(J-LOCAL)/bin:$(PATH)
export PATH

ifeq ($(filter windows macos,$(OS-NAME)),$(OS-NAME))
$(J): $(LOCAL-CACHE)/$(J-ARCHIVE)
	@$(ECHO) "* Installing 'j' locally"
	$Q rm -rf $(J-LOCAL) $(LOCAL-TMP)/j-$(J-VERSION)
	$Q mkdir -p $(LOCAL-TMP)/j-$(J-VERSION)
	$Q unzip -q -d $(LOCAL-TMP)/j-$(J-VERSION) $<
	$Q mv $$(find $(LOCAL-TMP)/j-$(J-VERSION) -mindepth 1 -maxdepth 1 -type d | head -1) $(J-LOCAL)
	$Q touch $@
	@$(ECHO)
else
$(J): $(LOCAL-CACHE)/$(J-ARCHIVE)
	@$(ECHO) "* Installing 'j' locally"
	$Q rm -rf $(J-LOCAL) $(LOCAL-TMP)/j-$(J-VERSION)
	$Q mkdir -p $(LOCAL-TMP)/j-$(J-VERSION)
	$Q tar -C $(LOCAL-TMP)/j-$(J-VERSION) -xzf $<
	$Q mv $$(find $(LOCAL-TMP)/j-$(J-VERSION) -mindepth 1 -maxdepth 1 -type d | head -1) $(J-LOCAL)
	$Q touch $@
	@$(ECHO)
endif

$(LOCAL-CACHE)/$(J-ARCHIVE):
	@$(ECHO) "* Downloading 'j' archive"
	$Q curl+ $(J-DOWN) > $@

endif
