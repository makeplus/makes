LIBYAMLSTAR-VERSION ?= 0.1.19
# https://github.com/yaml/yamlstar

ifndef LIBYAMLSTAR-LOADED
LIBYAMLSTAR-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-arm64
OA-macos-int64 := macos-x64
OA-windows-arm64 := windows-arm64
OA-windows-int64 := windows-x64

ifeq (,$(OA-$(OS-ARCH)))
$(error 'libyamlstar' has no prebuilt library for $(OS-ARCH); \
  see https://github.com/yaml/yamlstar)
endif

ifeq (windows,$(OS-NAME))
LIBYAMLSTAR-ARC-EXT := zip
LIBYAMLSTAR-FILE := libyamlstar.dll
else
LIBYAMLSTAR-ARC-EXT := tar.xz
ifeq (macos,$(OS-NAME))
LIBYAMLSTAR-FILE := libyamlstar.dylib
else
LIBYAMLSTAR-FILE := libyamlstar.so
endif
endif

LIBYAMLSTAR-DIR := libyamlstar-$(LIBYAMLSTAR-VERSION)-$(OA-$(OS-ARCH))
LIBYAMLSTAR-ARC := $(LIBYAMLSTAR-DIR).$(LIBYAMLSTAR-ARC-EXT)
LIBYAMLSTAR-TAR := $(LIBYAMLSTAR-ARC)
LIBYAMLSTAR-DOWN := https://github.com/yaml/yamlstar/releases/download
LIBYAMLSTAR-DOWN := $(LIBYAMLSTAR-DOWN)/$(LIBYAMLSTAR-VERSION)
LIBYAMLSTAR-DOWN := $(LIBYAMLSTAR-DOWN)/$(LIBYAMLSTAR-ARC)

LIBYAMLSTAR-TMP := $(LOCAL-TMP)/libyamlstar-$(LIBYAMLSTAR-VERSION)
LIBYAMLSTAR := $(LOCAL-LIB)/$(LIBYAMLSTAR-FILE)
LIBYAMLSTAR-INSTALL := $(LOCAL-LIB)/.libyamlstar-$(LIBYAMLSTAR-VERSION)
LIBYAMLSTAR-INSTALL := $(LIBYAMLSTAR-INSTALL)-$(OS-ARCH)

SHELL-DEPS += $(LIBYAMLSTAR-INSTALL)

ifeq (windows,$(OS-NAME))
override PATH := $(LOCAL-LIB):$(PATH)
export PATH
else ifeq (macos,$(OS-NAME))
override DYLD_LIBRARY_PATH := $(LOCAL-LIB):$(DYLD_LIBRARY_PATH)
export DYLD_LIBRARY_PATH
else
override LD_LIBRARY_PATH := $(LOCAL-LIB):$(LD_LIBRARY_PATH)
export LD_LIBRARY_PATH
endif


$(LIBYAMLSTAR-INSTALL): $(LOCAL-CACHE)/$(LIBYAMLSTAR-ARC)
	$Q rm -rf $(LIBYAMLSTAR-TMP)
	$Q mkdir -p $(LIBYAMLSTAR-TMP)
	$Q case '$(LIBYAMLSTAR-ARC)' in \
	  *.zip) unzip -q $< -d $(LIBYAMLSTAR-TMP) ;; \
	  *) tar -C $(LIBYAMLSTAR-TMP) -xf $< ;; \
	esac
	$Q $(MAKE) -C $(LIBYAMLSTAR-TMP)/$(LIBYAMLSTAR-DIR) \
	  install PREFIX=$(LOCAL-PREFIX)
	$Q [[ -e $(LIBYAMLSTAR) ]]
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(LIBYAMLSTAR-ARC):
	@$(ECHO) "* Installing 'libyamlstar' locally"
	$Q curl+ $(LIBYAMLSTAR-DOWN) > $@

endif
