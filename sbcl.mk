SBCL-VERSION-linux-int64 ?= 2.6.6
SBCL-VERSION-macos-arm64 ?= 2.4.0
SBCL-VERSION-macos-int64 ?= 2.2.9
# https://www.sbcl.org/platform-table.html

ifndef SBCL-LOADED
SBCL-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-int64 := x86-64-linux
OA-macos-arm64 := arm64-darwin
OA-macos-int64 := x86-64-darwin

SBCL-VERSION := $(SBCL-VERSION-$(OS-ARCH))
SBCL-TAR := sbcl-$(SBCL-VERSION)-$(OA-$(OS-ARCH))-binary.tar.bz2
SBCL-DOWN := https://downloads.sourceforge.net/project/sbcl/sbcl/$(SBCL-VERSION)/$(SBCL-TAR)
SBCL-LOCAL := $(LOCAL-ROOT)/sbcl-$(SBCL-VERSION)
SBCL := $(SBCL-LOCAL)/bin/sbcl

SHELL-DEPS += $(SBCL)

override PATH := $(SBCL-LOCAL)/bin:$(PATH)
export PATH


$(SBCL): $(LOCAL-CACHE)/$(SBCL-TAR)
	$Q rm -rf $(SBCL-LOCAL) $(LOCAL-CACHE)/sbcl-$(SBCL-VERSION)-$(OA-$(OS-ARCH))
	$Q tar -C $(LOCAL-CACHE) -xjf $<
	$Q cd $(LOCAL-CACHE)/sbcl-$(SBCL-VERSION)-$(OA-$(OS-ARCH)) && \
	  INSTALL_ROOT=$(SBCL-LOCAL) sh install.sh
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(SBCL-TAR):
	@$(ECHO) "* Installing 'sbcl' locally"
	$Q curl+ $(SBCL-DOWN) > $@

endif
