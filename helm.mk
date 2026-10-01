HELM-VERSION ?= 4.3.0
# https://github.com/helm/helm

ifndef HELM-LOADED
HELM-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

#------------------------------------------------------------------------------
# OS/Architecture Mappings
#------------------------------------------------------------------------------

# helm uses standard linux/darwin with amd64/arm64
OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-amd64

#------------------------------------------------------------------------------
# Download Configuration
#------------------------------------------------------------------------------

HELM-TAR := helm-v$(HELM-VERSION)-$(OA-$(OS-ARCH)).tar.gz
HELM-DOWN := https://get.helm.sh/$(HELM-TAR)

#------------------------------------------------------------------------------
# Local Paths
#------------------------------------------------------------------------------

HELM := $(LOCAL-BIN)/helm
HELM-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/helm
HELM-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_helm
HELM-COMP-FISH := $(LOCAL-SHARE)/fish/vendor_completions.d/helm.fish
HELM-COMP := \
  $(HELM-COMP-BASH) \
  $(HELM-COMP-ZSH) \
  $(HELM-COMP-FISH)
HELM-MAN := $(LOCAL-MAN)/man1/helm.1
HELM-SUPPORT-TMP := $(LOCAL-TMP)/helm-support-$(HELM-VERSION)

#------------------------------------------------------------------------------
# Shell Dependencies
#------------------------------------------------------------------------------

SHELL-DEPS += $(HELM) $(HELM-COMP) $(HELM-MAN)

#------------------------------------------------------------------------------
# Binary Installation Target
#------------------------------------------------------------------------------

$(HELM): $(LOCAL-CACHE)/$(HELM-TAR)
	tar -C $(LOCAL-CACHE) -xzf $<
	cp $(LOCAL-CACHE)/$(OA-$(OS-ARCH))/helm $@
	rm -rf $(LOCAL-CACHE)/$(OA-$(OS-ARCH))
	chmod +x $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(HELM-TAR):
	@echo "* Installing 'helm' locally"
	curl+ $(HELM-DOWN) > $@

$(HELM-COMP-BASH): $(HELM)
	$Q mkdir -p $(@D) $(HELM-SUPPORT-TMP)/{cache,config,data}
	$Q HELM_CACHE_HOME=$(HELM-SUPPORT-TMP)/cache \
	  HELM_CONFIG_HOME=$(HELM-SUPPORT-TMP)/config \
	  HELM_DATA_HOME=$(HELM-SUPPORT-TMP)/data \
	  $(HELM) completion bash > $@

$(HELM-COMP-ZSH): $(HELM)
	$Q mkdir -p $(@D) $(HELM-SUPPORT-TMP)/{cache,config,data}
	$Q HELM_CACHE_HOME=$(HELM-SUPPORT-TMP)/cache \
	  HELM_CONFIG_HOME=$(HELM-SUPPORT-TMP)/config \
	  HELM_DATA_HOME=$(HELM-SUPPORT-TMP)/data \
	  $(HELM) completion zsh > $@

$(HELM-COMP-FISH): $(HELM)
	$Q mkdir -p $(@D) $(HELM-SUPPORT-TMP)/{cache,config,data}
	$Q HELM_CACHE_HOME=$(HELM-SUPPORT-TMP)/cache \
	  HELM_CONFIG_HOME=$(HELM-SUPPORT-TMP)/config \
	  HELM_DATA_HOME=$(HELM-SUPPORT-TMP)/data \
	  $(HELM) completion fish > $@

$(HELM-MAN): $(HELM)
	$Q mkdir -p $(@D) $(HELM-SUPPORT-TMP)/{cache,config,data}
	$Q HELM_CACHE_HOME=$(HELM-SUPPORT-TMP)/cache \
	  HELM_CONFIG_HOME=$(HELM-SUPPORT-TMP)/config \
	  HELM_DATA_HOME=$(HELM-SUPPORT-TMP)/data \
	  $(HELM) docs --type man --dir $(@D)

endif
