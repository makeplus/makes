YAMLSCHEMA-VERSION ?= 0.1.5
# https://github.com/yaml/yamlschema

ifndef YAMLSCHEMA-LOADED
YAMLSCHEMA-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-int64 := linux_amd64
OA-macos-arm64 := darwin_arm64
OA-windows-int64 := windows_amd64

ifeq (,$(OA-$(OS-ARCH)))
$(error 'YAMLSchema' has no prebuilt binary for $(OS-ARCH); \
  see https://github.com/yaml/yamlschema)
endif

ifeq (windows,$(OS-NAME))
YAMLSCHEMA-ARC-EXT := zip
YAMLSCHEMA-EXE := ysd.exe
else
YAMLSCHEMA-ARC-EXT := tar.gz
YAMLSCHEMA-EXE := ysd
endif

YAMLSCHEMA-DIR := ysd-$(YAMLSCHEMA-VERSION)-$(OA-$(OS-ARCH))
YAMLSCHEMA-ARC := $(YAMLSCHEMA-DIR).$(YAMLSCHEMA-ARC-EXT)
YAMLSCHEMA-DOWN := https://github.com/yaml/yamlschema
YAMLSCHEMA-DOWN := $(YAMLSCHEMA-DOWN)/releases/download
YAMLSCHEMA-DOWN := \
  $(YAMLSCHEMA-DOWN)/v$(YAMLSCHEMA-VERSION)/$(YAMLSCHEMA-ARC)

YAMLSCHEMA-LOCAL := $(LOCAL-ROOT)/yamlschema-$(YAMLSCHEMA-VERSION)
YAMLSCHEMA-TMP := $(LOCAL-TMP)/yamlschema-$(YAMLSCHEMA-VERSION)
YAMLSCHEMA-SOURCE := $(YAMLSCHEMA-TMP)/$(YAMLSCHEMA-DIR)
YSD := $(YAMLSCHEMA-LOCAL)/bin/$(YAMLSCHEMA-EXE)

SHELL-DEPS += $(YSD)

override PATH := $(YAMLSCHEMA-LOCAL)/bin:$(PATH)
export PATH


$(YSD): $(LOCAL-CACHE)/$(YAMLSCHEMA-ARC)
	$Q rm -rf $(YAMLSCHEMA-TMP)
	$Q mkdir -p $(YAMLSCHEMA-LOCAL)/bin $(YAMLSCHEMA-TMP)
	$Q case '$(YAMLSCHEMA-ARC)' in \
	  *.zip) unzip -q $< -d $(YAMLSCHEMA-TMP) ;; \
	  *) tar -C $(YAMLSCHEMA-TMP) -xzf $< ;; \
	esac
	$Q cp $(YAMLSCHEMA-SOURCE)/$(YAMLSCHEMA-EXE) $@
	$Q chmod +x $@
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(YAMLSCHEMA-ARC):
	@$(ECHO) "* Installing 'YAMLSchema' locally"
	$Q curl+ $(YAMLSCHEMA-DOWN) > $@

endif
