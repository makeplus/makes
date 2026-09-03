YAMLSTAR-VERSION ?= 0.1.19
# https://github.com/yaml/yamlstar

ifndef YAMLSTAR-LOADED
YAMLSTAR-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-arm64
OA-macos-int64 := macos-x64
OA-windows-arm64 := windows-arm64
OA-windows-int64 := windows-x64

ifeq (,$(OA-$(OS-ARCH)))
$(error 'yamlstar' has no prebuilt binary for $(OS-ARCH); \
  see https://github.com/yaml/yamlstar)
endif

ifeq (windows,$(OS-NAME))
YAMLSTAR-ARC-EXT := zip
YAMLSTAR-EXE := yaml.exe
else
YAMLSTAR-ARC-EXT := tar.xz
YAMLSTAR-EXE := yaml
endif

YAMLSTAR-DIR := yamlstar-$(YAMLSTAR-VERSION)-$(OA-$(OS-ARCH))
YAMLSTAR-ARC := $(YAMLSTAR-DIR).$(YAMLSTAR-ARC-EXT)
YAMLSTAR-DOWN := https://github.com/yaml/yamlstar/releases/download
YAMLSTAR-DOWN := $(YAMLSTAR-DOWN)/$(YAMLSTAR-VERSION)/$(YAMLSTAR-ARC)

YAMLSTAR-LOCAL := $(LOCAL-ROOT)/yamlstar-$(YAMLSTAR-VERSION)
YAMLSTAR-TMP := $(LOCAL-TMP)/yamlstar-$(YAMLSTAR-VERSION)
YAMLSTAR := $(YAMLSTAR-LOCAL)/bin/$(YAMLSTAR-EXE)

SHELL-DEPS += $(YAMLSTAR)

override PATH := $(YAMLSTAR-LOCAL)/bin:$(PATH)
export PATH


$(YAMLSTAR): $(LOCAL-CACHE)/$(YAMLSTAR-ARC)
	$Q rm -rf $(YAMLSTAR-TMP)
	$Q mkdir -p $(YAMLSTAR-LOCAL)/bin $(YAMLSTAR-TMP)
	$Q case '$(YAMLSTAR-ARC)' in \
	  *.zip) unzip -q $< -d $(YAMLSTAR-TMP) ;; \
	  *) tar -C $(YAMLSTAR-TMP) -xf $< ;; \
	esac
	$Q cp $(YAMLSTAR-TMP)/$(YAMLSTAR-DIR)/$(YAMLSTAR-EXE) $@
	$Q chmod +x $@
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(YAMLSTAR-ARC):
	@$(ECHO) "* Installing 'yamlstar' locally"
	$Q curl+ $(YAMLSTAR-DOWN) > $@

endif
