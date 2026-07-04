FUTHARK-VERSION ?= 0.26.4
# https://github.com/diku-dk/futhark

ifndef FUTHARK-LOADED
FUTHARK-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-int64 := linux-x86_64

FUTHARK-DIR := futhark-$(FUTHARK-VERSION)-$(OA-$(OS-ARCH))
FUTHARK-TAR := $(FUTHARK-DIR).tar.xz
FUTHARK-DOWN := https://github.com/diku-dk/futhark/releases/download/v$(FUTHARK-VERSION)/$(FUTHARK-TAR)
FUTHARK-LOCAL := $(LOCAL-ROOT)/futhark-$(FUTHARK-VERSION)
FUTHARK := $(FUTHARK-LOCAL)/bin/futhark

SHELL-DEPS += $(FUTHARK)

override PATH := $(FUTHARK-LOCAL)/bin:$(PATH)
export PATH


$(FUTHARK): $(LOCAL-CACHE)/$(FUTHARK-TAR)
	$Q rm -rf $(FUTHARK-LOCAL) $(LOCAL-TMP)/futhark-$(FUTHARK-VERSION)
	$Q mkdir -p $(LOCAL-TMP)/futhark-$(FUTHARK-VERSION)
	$Q tar -C $(LOCAL-TMP)/futhark-$(FUTHARK-VERSION) -xJf $<
	$Q mv $(LOCAL-TMP)/futhark-$(FUTHARK-VERSION)/$(FUTHARK-DIR) $(FUTHARK-LOCAL)
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(FUTHARK-TAR):
	@$(ECHO) "* Installing 'futhark' locally"
	$Q curl+ $(FUTHARK-DOWN) > $@

endif
