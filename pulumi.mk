PULUMI-VERSION ?= 3.181.0

ifndef PULUMI-LOADED
PULUMI-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-x64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-x64

PULUMI-NAME := pulumi-v$(PULUMI-VERSION)-$(OA-$(OS-ARCH))
PULUMI-TAR := $(PULUMI-NAME).tar.gz
PULUMI-DOWN := https://github.com/pulumi/pulumi/releases/download
PULUMI-DOWN := $(PULUMI-DOWN)/v$(PULUMI-VERSION)/$(PULUMI-TAR)

PULUMI := $(LOCAL-BIN)/pulumi

SHELL-DEPS += $(PULUMI)


$(PULUMI): $(LOCAL-CACHE)/$(PULUMI-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	[[ -e $(LOCAL-CACHE)/pulumi/pulumi ]]
	mv $(LOCAL-CACHE)/pulumi/pulumi* $(LOCAL-BIN)/
	@touch $@
	@echo

$(LOCAL-CACHE)/$(PULUMI-TAR):
	@echo "Installing 'pulumi' locally"
	curl+ $(PULUMI-DOWN) > $@
	@touch $@

endif
