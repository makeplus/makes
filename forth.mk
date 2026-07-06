FORTH-VERSION ?= 0.7.3
# https://github.com/forthy42/gforth

ifndef FORTH-LOADED
FORTH-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

$(if $(filter macos-int64,$(OS-ARCH)),,$(error forth.mk does not support $(OS-ARCH)))

FORTH-TAR := gforth-$(FORTH-VERSION).bin.x86_64-apple-darwin10.8.0.tar.gz
FORTH-DOWN := https://www.complang.tuwien.ac.at/forth/gforth/$(FORTH-TAR)
FORTH-LOCAL := $(LOCAL-ROOT)/forth-$(FORTH-VERSION)
FORTH := $(FORTH-LOCAL)/gforth

SHELL-DEPS += $(FORTH)

override PATH := $(FORTH-LOCAL):$(PATH)
export PATH

$(FORTH): $(LOCAL-CACHE)/$(FORTH-TAR)
	@$(ECHO) "* Installing 'forth' locally"
	$Q rm -rf $(FORTH-LOCAL) $(LOCAL-TMP)/forth-$(FORTH-VERSION)
	$Q mkdir -p $(LOCAL-TMP)/forth-$(FORTH-VERSION)
	$Q tar -C $(LOCAL-TMP)/forth-$(FORTH-VERSION) -xzf $<
	$Q mv $$(find $(LOCAL-TMP)/forth-$(FORTH-VERSION) -mindepth 1 -maxdepth 1 -type d | head -1) $(FORTH-LOCAL)
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(FORTH-TAR):
	@$(ECHO) "* Downloading 'forth' archive"
	$Q curl+ $(FORTH-DOWN) > $@

endif
