SBCL-VERSION-linux-int64 ?= 2.6.6
SBCL-VERSION-macos-arm64 ?= 2.4.0
SBCL-VERSION-macos-int64 ?= 2.2.9
SBCL-VERSION-windows-int64 ?= 2.6.6
# https://www.sbcl.org/platform-table.html

ifndef SBCL-LOADED
SBCL-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-int64 := x86-64-linux
OA-macos-arm64 := arm64-darwin
OA-macos-int64 := x86-64-darwin
OA-windows-int64 := x86-64-windows

SBCL-VERSION := $(SBCL-VERSION-$(OS-ARCH))
ifeq ($(OS-NAME),windows)
SBCL-TAR := sbcl-$(SBCL-VERSION)-$(OA-$(OS-ARCH))-binary.msi
else
SBCL-TAR := sbcl-$(SBCL-VERSION)-$(OA-$(OS-ARCH))-binary.tar.bz2
endif
SBCL-DOWN := https://downloads.sourceforge.net/project/sbcl/sbcl/$(SBCL-VERSION)/$(SBCL-TAR)
SBCL-LOCAL := $(LOCAL-ROOT)/sbcl-$(SBCL-VERSION)
ifeq ($(OS-NAME),windows)
SBCL := $(SBCL-LOCAL)/sbcl.exe
else
SBCL := $(SBCL-LOCAL)/bin/sbcl
endif

SHELL-DEPS += $(SBCL)

ifeq ($(OS-NAME),windows)
override PATH := $(SBCL-LOCAL):$(PATH)
else
override PATH := $(SBCL-LOCAL)/bin:$(PATH)
endif
export PATH


$(SBCL): $(LOCAL-CACHE)/$(SBCL-TAR)
ifeq ($(OS-NAME),windows)
	$Q rm -rf $(SBCL-LOCAL) $(LOCAL-TMP)/sbcl-$(SBCL-VERSION)
	$Q mkdir -p $(SBCL-LOCAL) $(LOCAL-TMP)/sbcl-$(SBCL-VERSION)
	$Q msiexec /a "$$(cygpath -w $<)" /qn \
	  TARGETDIR="$$(cygpath -w $(LOCAL-TMP)/sbcl-$(SBCL-VERSION))"
	$Q sbcl_dir=$$(dirname "$$(find $(LOCAL-TMP)/sbcl-$(SBCL-VERSION) -name sbcl.exe -type f | head -1)") && \
	  cp -R "$$sbcl_dir"/* $(SBCL-LOCAL)/
else
	$Q rm -rf $(SBCL-LOCAL) $(LOCAL-CACHE)/sbcl-$(SBCL-VERSION)-$(OA-$(OS-ARCH))
	$Q tar -C $(LOCAL-CACHE) -xjf $<
	$Q cd $(LOCAL-CACHE)/sbcl-$(SBCL-VERSION)-$(OA-$(OS-ARCH)) && \
	  INSTALL_ROOT=$(SBCL-LOCAL) sh install.sh
endif
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(SBCL-TAR):
	@$(ECHO) "* Installing 'sbcl' locally"
	$Q curl+ $(SBCL-DOWN) > $@

endif
