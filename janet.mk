JANET-VERSION ?= 1.41.2
# https://github.com/janet-lang/janet

ifndef JANET-LOADED
JANET-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-aarch64

JANET-DIR := janet-v$(JANET-VERSION)-$(OS-NAME)
JANET-TAR := janet-v$(JANET-VERSION)-$(OA-$(OS-ARCH)).tar.gz
JANET-DOWN := https://github.com/janet-lang/janet
JANET-DOWN := $(JANET-DOWN)/releases/download/v$(JANET-VERSION)/$(JANET-TAR)

JANET-LOCAL := $(LOCAL-ROOT)/janet-v$(JANET-VERSION)
JANET := $(JANET-LOCAL)/bin/janet
SHELL-DEPS += $(JANET)

override PATH := $(JANET-LOCAL)/bin:$(PATH)
export PATH


$(JANET): $(LOCAL-CACHE)/$(JANET-TAR)
	$Q tar -C $(LOCAL-CACHE) -xf $<
	$Q mv $(LOCAL-CACHE)/$(JANET-DIR) $(JANET-LOCAL)
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(JANET-TAR):
	@$(ECHO) "* Installing 'janet' locally"
	$Q curl+ $(JANET-DOWN) > $@

endif
