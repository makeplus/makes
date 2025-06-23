ifndef PULUMI-LOADED
PULUMI-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

PULUMI-VERSION ?= 3.178.0
PULUMI-NAME := pulumi-v$(PULUMI-VERSION)-linux-x64
PULUMI-TARBALL := $(PULUMI-NAME).tar.gz
PULUMI-REPO-URL := https://get.pulumi.com/releases/sdk/
PULUMI-DOWNLOAD := $(PULUMI-REPO-URL)/$(PULUMI-TARBALL)

PULUMI := $(LOCAL-BIN)/pulumi


$(PULUMI): $(LOCAL-CACHE)/$(PULUMI-TARBALL)
	tar -C $(LOCAL-CACHE) -xf $<
	[[ -e $(LOCAL-CACHE)/pulumi/pulumi ]]
	mv $(LOCAL-CACHE)/pulumi/pulumi* $(LOCAL-BIN)/
	@touch $@
	@echo

$(LOCAL-CACHE)/$(PULUMI-TARBALL):
	@echo "Installing 'pulumi' locally"
	curl -Ls $(PULUMI-DOWNLOAD) > $@
	@touch $@

endif
