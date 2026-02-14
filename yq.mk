YQ-VERSION ?= 4.52.4

ifndef YQ-LOADED
YQ-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux_arm64
OA-linux-int64 := linux_amd64
OA-macos-arm64 := darwin_arm64
OA-macos-int64 := darwin_amd64

YQ-NAME := yq_$(OA-$(OS-ARCH))
YQ-TAR := $(YQ-NAME).tar.gz
YQ-DOWN := https://github.com/mikefarah/yq
YQ-DOWN := $(YQ-DOWN)/releases/download/v$(YQ-VERSION)/$(YQ-TAR)

YQ := $(LOCAL-BIN)/yq

SHELL-DEPS += $(YQ)


$(YQ): $(LOCAL-CACHE)/$(YQ-TAR)
	tar -C $(LOCAL-CACHE) -xf $< -- ./$(YQ-NAME)
	[[ -e $(LOCAL-CACHE)/$(YQ-NAME) ]]
	mv $(LOCAL-CACHE)/$(YQ-NAME) $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(YQ-TAR):
	@echo "* Installing 'yq' locally"
	curl+ $(YQ-DOWN) > $@

endif
