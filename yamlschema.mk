YAMLSCHEMA-VERSION ?= 0.1.12
# https://github.com/yaml/yamlschema

ifndef YAMLSCHEMA-LOADED
YAMLSCHEMA-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-int64 := linux_amd64
OA-linux-arm64 := linux_arm64
OA-macos-arm64 := darwin_arm64
OA-windows-int64 := windows_amd64
OA-windows-arm64 := windows_arm64

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
YAMLSCHEMA-SUPPORT-ARC := \
  yamlschema-$(YAMLSCHEMA-VERSION)-source.tar.gz
YAMLSCHEMA-SUPPORT-DOWN := https://github.com/yaml/yamlschema/archive
YAMLSCHEMA-SUPPORT-DOWN := \
  $(YAMLSCHEMA-SUPPORT-DOWN)/refs/tags/v$(YAMLSCHEMA-VERSION).tar.gz
YAMLSCHEMA-SUPPORT-DIR := \
  $(LOCAL-TMP)/yamlschema-support-$(YAMLSCHEMA-VERSION)
YSD := $(YAMLSCHEMA-LOCAL)/bin/$(YAMLSCHEMA-EXE)
YAMLSCHEMA-COMP-BASH := \
  $(LOCAL-SHARE)/bash-completion/completions/ysd
YAMLSCHEMA-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_ysd
YAMLSCHEMA-COMP-FISH := \
  $(LOCAL-SHARE)/fish/vendor_completions.d/ysd.fish
YAMLSCHEMA-COMP := \
  $(YAMLSCHEMA-COMP-BASH) \
  $(YAMLSCHEMA-COMP-ZSH) \
  $(YAMLSCHEMA-COMP-FISH)
YAMLSCHEMA-MAN-NAMES := \
  man1/ysd.1 \
  man5/yamlschema-design.5 \
  man5/yamlschema-json-schema.5 \
  man5/yamlschema.5
YAMLSCHEMA-MAN := $(addprefix $(LOCAL-MAN)/,$(YAMLSCHEMA-MAN-NAMES))

SHELL-DEPS += $(YSD) $(YAMLSCHEMA-COMP) $(YAMLSCHEMA-MAN)

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

$(YAMLSCHEMA-COMP-BASH): $(YAMLSCHEMA-SUPPORT-DIR)
	$Q mkdir -p $(@D)
	$Q cp $</share/complete.bash $@

$(YAMLSCHEMA-COMP-ZSH): $(YAMLSCHEMA-SUPPORT-DIR)
	$Q mkdir -p $(@D)
	$Q cp $</share/complete.zsh $@

$(YAMLSCHEMA-COMP-FISH): $(YAMLSCHEMA-SUPPORT-DIR)
	$Q mkdir -p $(@D)
	$Q cp $</share/complete.fish $@

$(YAMLSCHEMA-MAN): $(YAMLSCHEMA-SUPPORT-DIR)
	$Q mkdir -p $(@D)
	$Q cp $</man/$(notdir $(@D))/$(@F) $@

$(YAMLSCHEMA-SUPPORT-DIR): \
  $(LOCAL-CACHE)/$(YAMLSCHEMA-SUPPORT-ARC)
	$Q rm -rf $@
	$Q mkdir -p $@
	$Q tar -C $@ --strip-components=1 -xzf $<
	$Q touch $@

$(LOCAL-CACHE)/$(YAMLSCHEMA-SUPPORT-ARC):
	$Q curl+ $(YAMLSCHEMA-SUPPORT-DOWN) > $@

endif
