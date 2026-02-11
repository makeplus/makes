GLOAT-VERSION ?= main

ifndef GLOAT-LOADED
GLOAT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

include $(MAKES)/gh.mk

GLOAT-COMMIT ?= gloat
GLOAT-REPO ?= https://github.com/ingydotnet/gloat
GLOAT-DIR ?= $(LOCAL-CACHE)/gloat-$(GLOAT-VERSION)

GLOAT-GITHUB-TOKEN-FILE ?= $(HOME)/.github-api-token
GLOAT-CONFIG ?= .makes/gloat.config
GLOAT-CONFIG-SRC := $(MAKES-DIR)/share/gloat.config

GH-CMD = $(GH)
ifneq (,$(wildcard $(GLOAT-GITHUB-TOKEN-FILE)))
export GITHUB_TOKEN_FILE := $(GLOAT-GITHUB-TOKEN-FILE)
override GH-CMD := GITHUB_TOKEN=$$(< $$GITHUB_TOKEN_FILE) $(GH)
endif

ifneq (,$(wildcard $(GLOAT-CONFIG)))
override GLOAT-PLATFORMS := $(shell git config -f $(GLOAT-CONFIG) --get-all gloat.platforms.name)
endif

override GLOAT-REPO := $(if $(findstring https://,$(GLOAT-REPO)) \
  ,$(GLOAT-REPO),https://github.com/$(GLOAT-REPO))

GLOAT-BIN := $(GLOAT-DIR)/bin
override PATH := $(GLOAT-BIN):$(PATH)

GLOAT-PLATFORMS ?= \
  linux/amd64 \
  linux/arm64 \
  darwin/amd64 \
  darwin/arm64 \
  windows/amd64 \

GLOAT-EXTRA-PLATFORMS ?=

GLOAT-PLATFORMS += $(GLOAT-EXTRA-PLATFORMS)

GLOAT-DIST ?= dist

SHELL-DEPS += $(GLOAT-DIR)

# Auto-detect FILE if there's exactly one .ys or .clj file
ifndef FILE
_GLOAT_YS_FILES := $(wildcard *.ys)
_GLOAT_CLJ_FILES := $(wildcard *.clj)
_GLOAT_SOURCE_FILES := $(_GLOAT_YS_FILES) $(_GLOAT_CLJ_FILES)
ifeq ($(words $(_GLOAT_SOURCE_FILES)),1)
FILE := $(_GLOAT_SOURCE_FILES)
endif
endif

gloat-github-release-dist:
	@$(if $(FILE),,$(error FILE is required for gloat-github-release-dist))
	$(MAKE) gloat-bin FILE=$(FILE)

gloat-github-release: $(GLOAT-DIR) $(GH)
	@$(if $(FILE),,$(error FILE is required for gloat-github-release))
	@$(if $(VERSION),,$(error VERSION is required for gloat-github-release))
	@echo "Verifying GitHub repository and authentication..."
	@$(GH-CMD) repo view >/dev/null || { echo "Error: Not in a GitHub repository or gh not authenticated. Run 'gh auth login' first."; exit 1; }
	$(MAKE) gloat-github-release-dist FILE=$(FILE)
	$(GH-CMD) release create v$(VERSION) --title "v$(VERSION)" --generate-notes $(GLOAT-DIST)/*

gloat-config: $(GLOAT-CONFIG)

$(GLOAT-DIR):
	$Q git clone$(if $Q, -q) $(GLOAT-REPO) $@
	$Q git -C $@ checkout$(if $Q, -q) $(GLOAT-VERSION)

$(GLOAT-CONFIG):
	mkdir -p $(dir $(GLOAT-CONFIG))
	cp $(GLOAT-CONFIG-SRC) $@

ifdef FILE
GLOAT-BIN-NAME := $(or $(GLOAT-NAME),$(basename $(notdir $(FILE))))

# Generate all platform rules
$(foreach platform,$(GLOAT-PLATFORMS),$(eval $(call gloat-platform-rule,$(platform))))

gloat-bin: $(GLOAT-DIST-FILES)

endif

endif

# Template to generate a rule for one platform
define gloat-platform-rule
$(eval _os := $(word 1,$(subst /, ,$(1))))
$(eval _arch := $(word 2,$(subst /, ,$(1))))
$(eval _ext := $(if $(filter windows,$(_os)),.exe,))
$(eval _target := $(GLOAT-DIST)/$(GLOAT-BIN-NAME)-$(_os)-$(_arch)$(_ext))

$(_target): $(GLOAT-DIR)
	$$Q mkdir -p $(GLOAT-DIST)
	$$Q $(GLOAT-BIN)/gloat $(FILE) -o $$@ -p $(1)
	$$(if $$Q,,@echo "Built $$@")

GLOAT-DIST-FILES += $(_target)
endef
