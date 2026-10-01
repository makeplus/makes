FUTHARK-VERSION ?= 0.27.1
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
FUTHARK-MAN := $(LOCAL-MAN)/man1/futhark.1.gz

SHELL-DEPS += $(FUTHARK) $(FUTHARK-MAN)

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

$(FUTHARK-MAN): $(FUTHARK)
	$Q mkdir -p $(@D)
	$Q cp $(FUTHARK-LOCAL)/share/man/man1/* $(@D)/

endif
