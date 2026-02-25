GH-VERSION ?= 2.87.2
# https://github.com/cli/cli

ifndef GH-LOADED
GH-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux_arm64
OA-linux-int64 := linux_amd64
OA-macos-arm64 := macOS_arm64
OA-macos-int64 := macOS_amd64

ifeq ($(OS-NAME),linux)
GH-EXT := tar.gz
else
GH-EXT := zip
endif

GH-ARCHIVE := gh_$(GH-VERSION)_$(OA-$(OS-ARCH)).$(GH-EXT)
GH-DIR := $(GH-ARCHIVE:.$(GH-EXT)=)
GH-DOWN := https://github.com/cli/cli/releases/download/v$(GH-VERSION)/$(GH-ARCHIVE)

GH-LOCAL := $(LOCAL-ROOT)/gh-$(GH-VERSION)
GH-BIN := $(GH-LOCAL)/bin
override PATH := $(GH-BIN):$(PATH)

GH := $(GH-BIN)/gh

GH-TOKEN-FILE ?= $(HOME)/.github-api-token

GH-CMD = $(GH)
ifneq (,$(wildcard $(GH-TOKEN-FILE)))
export GITHUB_TOKEN_FILE := $(GH-TOKEN-FILE)
override GH-CMD := GITHUB_TOKEN=$$(< $$GITHUB_TOKEN_FILE) $(GH)
endif

SHELL-DEPS += $(GH)


ifeq ($(OS-NAME),linux)
$(GH): $(LOCAL-CACHE)/$(GH-ARCHIVE)
	$Q mkdir -p $(GH-LOCAL)
	$Q tar -C $(GH-LOCAL) --strip-components=1 -xzf $<
	$Q touch $@
	@$(ECHO)
else
$(GH): $(LOCAL-CACHE)/$(GH-ARCHIVE)
	$Q cd $(LOCAL-CACHE) && unzip -q $< -d gh-$(GH-VERSION)-tmp
	$Q mv $(LOCAL-CACHE)/gh-$(GH-VERSION)-tmp/$(GH-DIR) $(GH-LOCAL)
	$Q rm -rf $(LOCAL-CACHE)/gh-$(GH-VERSION)-tmp
	$Q touch $@
	@$(ECHO)
endif

$(LOCAL-CACHE)/$(GH-ARCHIVE):
	@$(ECHO) "Installing 'gh' locally"
	$Q curl+ $(GH-DOWN) > $@

endif
