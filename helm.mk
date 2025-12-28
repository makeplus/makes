HELM-VERSION ?= 4.0.4
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

#------------------------------------------------------------------------------
# Shell Dependencies
#------------------------------------------------------------------------------

SHELL-DEPS += $(HELM)

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

endif
