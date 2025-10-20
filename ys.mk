YS-VERSION ?= 0.2.7

ifndef YS-LOADED
YS-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-x64

YS-DIR := ys-$(YS-VERSION)-$(OA-$(OS-ARCH))
YS-TAR := $(YS-DIR).tar.xz
YS-DOWN := https://github.com/yaml/yamlscript
YS-DOWN := $(YS-DOWN)/releases/download/$(YS-VERSION)/$(YS-TAR)

YS := $(LOCAL-BIN)/ys-$(YS-VERSION)

SHELL-DEPS += $(YS)


$(YS): $(LOCAL-CACHE)/$(YS-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	[[ -e $(LOCAL-CACHE)/$(YS-DIR)/ys-$(YS-VERSION) ]]
	mv $(LOCAL-CACHE)/$(YS-DIR)/ys* $(LOCAL-BIN)
	touch $@
	@echo

$(LOCAL-CACHE)/$(YS-TAR):
	@echo "* Installing 'ys' locally"
	curl+ $(YS-DOWN) > $@

endif
