JANET-VERSION ?= 1.41.2
# https://github.com/janet-lang/janet

ifndef JANET-LOADED
JANET-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-aarch64
OA-windows-int64 := windows-x64

JANET-DIR := janet-v$(JANET-VERSION)-$(OS-NAME)
JANET-LOCAL := $(LOCAL-ROOT)/janet-v$(JANET-VERSION)
ifeq ($(OS-NAME),windows)
JANET-TAR := janet-$(JANET-VERSION)-$(OA-$(OS-ARCH))-installer.msi
JANET := $(JANET-LOCAL)/bin/janet.exe
else
JANET-TAR := janet-v$(JANET-VERSION)-$(OA-$(OS-ARCH)).tar.gz
JANET := $(JANET-LOCAL)/bin/janet
endif
JANET-DOWN := https://github.com/janet-lang/janet
JANET-DOWN := $(JANET-DOWN)/releases/download/v$(JANET-VERSION)/$(JANET-TAR)

SHELL-DEPS += $(JANET)

override PATH := $(JANET-LOCAL)/bin:$(PATH)
export PATH


$(JANET): $(LOCAL-CACHE)/$(JANET-TAR)
ifeq ($(OS-NAME),windows)
	$Q rm -rf $(JANET-LOCAL) $(LOCAL-TMP)/janet-$(JANET-VERSION)
	$Q mkdir -p $(JANET-LOCAL) $(LOCAL-TMP)/janet-$(JANET-VERSION)
	$Q msiexec /a "$$(cygpath -w $<)" /qn \
	  TARGETDIR="$$(cygpath -w $(LOCAL-TMP)/janet-$(JANET-VERSION))"
	$Q mkdir -p $(JANET-LOCAL)/bin
	$Q cp $$(find $(LOCAL-TMP)/janet-$(JANET-VERSION) -name janet.exe -type f | head -1) $@
else
	$Q tar -C $(LOCAL-CACHE) -xf $<
	$Q mv $(LOCAL-CACHE)/$(JANET-DIR) $(JANET-LOCAL)
endif
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(JANET-TAR):
	@$(ECHO) "* Installing 'janet' locally"
	$Q curl+ $(JANET-DOWN) > $@

endif
