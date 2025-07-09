YQ-VERSION ?= 4.45.4

ifndef YQ-LOADED
YQ-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

OA-linux-arm64 := linux_arm64
OA-linux-int64 := linux_amd64
OA-macos-arm64 := darwin_arm64
OA-macos-int64 := darwin_amd64

YQ-NAME := yq_$(OA-$(OS-ARCH))
YQ-TARBALL := $(YQ-NAME).tar.gz
YQ-REPO-URL := https://github.com/mikefarah/yq
YQ-DOWNLOAD := $(YQ-REPO-URL)/releases/download/v$(YQ-VERSION)/$(YQ-TARBALL)

YQ := $(LOCAL-BIN)/yq

SHELL-DEPS += $(YQ)


$(YQ): $(LOCAL-CACHE)/$(YQ-TARBALL)
	tar -C $(LOCAL-CACHE) -xf $< -- ./$(YQ-NAME)
	[[ -e $(LOCAL-CACHE)/$(YQ-NAME) ]]
	mv $(LOCAL-CACHE)/$(YQ-NAME) $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(YQ-TARBALL):
	@echo "Installing 'yq' locally"
	curl+ $(YQ-DOWNLOAD) > $@

endif
