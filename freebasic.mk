FREEBASIC-VERSION ?= 1.10.1
# https://github.com/freebasic/fbc

ifndef FREEBASIC-LOADED
FREEBASIC-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := ubuntu-22.04-aarch64
OA-linux-int64 := linux-x86_64
OA-windows-int64 := win64

$(if $(OA-$(OS-ARCH)),,$(error freebasic.mk does not support $(OS-ARCH)))

ifeq ($(OS-NAME),windows)
FREEBASIC-ARCHIVE := FreeBASIC-$(FREEBASIC-VERSION)-$(OA-$(OS-ARCH)).zip
FREEBASIC := $(FREEBASIC-LOCAL)/fbc64.exe
else
FREEBASIC-ARCHIVE := FreeBASIC-$(FREEBASIC-VERSION)-$(OA-$(OS-ARCH)).tar.gz
FREEBASIC := $(FREEBASIC-LOCAL)/bin/fbc
endif
FREEBASIC-DOWN := https://sourceforge.net/projects/fbc/files/FreeBASIC-$(FREEBASIC-VERSION)/$(FREEBASIC-ARCHIVE)/download
FREEBASIC-LOCAL := $(LOCAL-ROOT)/freebasic-$(FREEBASIC-VERSION)

SHELL-DEPS += $(FREEBASIC)

override PATH := $(FREEBASIC-LOCAL)/bin:$(FREEBASIC-LOCAL):$(PATH)
export PATH

ifeq ($(OS-NAME),windows)
$(FREEBASIC): $(LOCAL-CACHE)/$(FREEBASIC-ARCHIVE)
	@$(ECHO) "* Installing 'freebasic' locally"
	$Q rm -rf $(FREEBASIC-LOCAL) $(LOCAL-TMP)/freebasic-$(FREEBASIC-VERSION)
	$Q mkdir -p $(LOCAL-TMP)/freebasic-$(FREEBASIC-VERSION)
	$Q unzip -q -d $(LOCAL-TMP)/freebasic-$(FREEBASIC-VERSION) $<
	$Q mv $$(find $(LOCAL-TMP)/freebasic-$(FREEBASIC-VERSION) -mindepth 1 -maxdepth 1 -type d | head -1) $(FREEBASIC-LOCAL)
	$Q touch $@
	@$(ECHO)
else
$(FREEBASIC): $(LOCAL-CACHE)/$(FREEBASIC-ARCHIVE)
	@$(ECHO) "* Installing 'freebasic' locally"
	$Q rm -rf $(FREEBASIC-LOCAL) $(LOCAL-TMP)/freebasic-$(FREEBASIC-VERSION)
	$Q mkdir -p $(LOCAL-TMP)/freebasic-$(FREEBASIC-VERSION)
	$Q tar -C $(LOCAL-TMP)/freebasic-$(FREEBASIC-VERSION) -xzf $<
	$Q mv $$(find $(LOCAL-TMP)/freebasic-$(FREEBASIC-VERSION) -mindepth 1 -maxdepth 1 -type d | head -1) $(FREEBASIC-LOCAL)
	$Q touch $@
	@$(ECHO)
endif

$(LOCAL-CACHE)/$(FREEBASIC-ARCHIVE):
	@$(ECHO) "* Downloading 'freebasic' archive"
	$Q curl+ $(FREEBASIC-DOWN) > $@

endif
