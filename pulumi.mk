PULUMI-VERSION ?= 3.181.0

ifndef PULUMI-LOADED
PULUMI-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

PULUMI-NAME := pulumi-v$(PULUMI-VERSION)-$(OA3-$(OS-ARCH))
PULUMI-TARBALL := $(PULUMI-NAME).tar.gz
PULUMI-RELEASES := https://github.com/pulumi/pulumi/releases/download
PULUMI-DOWNLOAD := $(PULUMI-RELEASES)/v$(PULUMI-VERSION)/$(PULUMI-TARBALL)

$(info https://github.com/pulumi/pulumi/releases/download/v3.181.0/pulumi-v3.181.0-darwin-arm64.tar.gz)
$(info $(PULUMI-DOWNLOAD))

PULUMI := $(LOCAL-BIN)/pulumi

SHELL-DEPS += $(PULUMI)


$(PULUMI): $(LOCAL-CACHE)/$(PULUMI-TARBALL)
	tar -C $(LOCAL-CACHE) -xf $<
	[[ -e $(LOCAL-CACHE)/pulumi/pulumi ]]
	mv $(LOCAL-CACHE)/pulumi/pulumi* $(LOCAL-BIN)/
	@touch $@
	@echo

$(LOCAL-CACHE)/$(PULUMI-TARBALL):
	@echo "Installing 'pulumi' locally"
	curl+ $(PULUMI-DOWNLOAD) > $@
	@touch $@

endif
