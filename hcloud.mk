HCLOUD-VERSION ?= 1.61.0
# https://github.com/hetznercloud/cli

ifndef HCLOUD-LOADED
HCLOUD-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

#------------------------------------------------------------------------------
# Configuration Variables
#------------------------------------------------------------------------------

HCLOUD-SERVER-NAME ?=
HCLOUD-SERVER-TYPE ?= cx22
HCLOUD-SERVER-IMAGE ?= ubuntu-24.04
HCLOUD-SERVER-LOCATION ?=
HCLOUD-SSH-KEY ?=
HCLOUD-CREATE-OPTIONS ?=

#------------------------------------------------------------------------------
# OS/Architecture Mappings
#------------------------------------------------------------------------------

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-amd64

#------------------------------------------------------------------------------
# Download Configuration
#------------------------------------------------------------------------------

HCLOUD-TAR := hcloud-$(OA-$(OS-ARCH)).tar.gz
HCLOUD-DOWN := https://github.com/hetznercloud/cli/releases/download
HCLOUD-DOWN := $(HCLOUD-DOWN)/v$(HCLOUD-VERSION)/$(HCLOUD-TAR)

#------------------------------------------------------------------------------
# Local Paths
#------------------------------------------------------------------------------

HCLOUD := $(LOCAL-BIN)/hcloud

SHELL-DEPS += $(HCLOUD)

#------------------------------------------------------------------------------
# Binary Installation Targets
#------------------------------------------------------------------------------

$(HCLOUD): $(LOCAL-CACHE)/$(HCLOUD-TAR)
	tar -C $(LOCAL-BIN) -xf $< hcloud
	[[ -e $@ ]]
	touch $@
	@echo

$(LOCAL-CACHE)/$(HCLOUD-TAR):
	@echo "* Installing 'hcloud' locally"
	curl+ $(HCLOUD-DOWN) > $@

#------------------------------------------------------------------------------
# Convenience Targets
#------------------------------------------------------------------------------

.PHONY: hetzner-login hetzner-context hetzner-list hetzner-create \
  hetzner-delete hetzner-ssh hetzner-status hetzner-start hetzner-stop \
  hetzner-reboot

hetzner-login: $(HCLOUD)
	$(HCLOUD) context create

hetzner-context: $(HCLOUD)
	$(HCLOUD) context active

hetzner-list: $(HCLOUD)
	$(HCLOUD) server list

hetzner-create: $(HCLOUD)
	$(HCLOUD) server create \
	  --name $(HCLOUD-SERVER-NAME) \
	  --type $(HCLOUD-SERVER-TYPE) \
	  --image $(HCLOUD-SERVER-IMAGE) \
	  $(if $(HCLOUD-SERVER-LOCATION),--location $(HCLOUD-SERVER-LOCATION),) \
	  $(if $(HCLOUD-SSH-KEY),--ssh-key $(HCLOUD-SSH-KEY),) \
	  $(HCLOUD-CREATE-OPTIONS)

hetzner-delete: $(HCLOUD)
	$(HCLOUD) server delete $(HCLOUD-SERVER-NAME)

hetzner-ssh: $(HCLOUD)
	$(HCLOUD) server ssh $(HCLOUD-SERVER-NAME)

hetzner-status: $(HCLOUD)
	$(HCLOUD) server describe $(HCLOUD-SERVER-NAME)

hetzner-start: $(HCLOUD)
	$(HCLOUD) server poweron $(HCLOUD-SERVER-NAME)

hetzner-stop: $(HCLOUD)
	$(HCLOUD) server shutdown $(HCLOUD-SERVER-NAME)

hetzner-reboot: $(HCLOUD)
	$(HCLOUD) server reboot $(HCLOUD-SERVER-NAME)

endif
