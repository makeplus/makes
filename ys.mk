YS-VERSION ?= 0.1.97

ifndef YS-LOADED
YS-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-x64

YS-DIR := ys-$(YS-VERSION)-$(OA-$(OS-ARCH))
YS-TARBALL := $(YS-DIR).tar.xz
YS-REPO-URL := https://github.com/yaml/yamlscript
YS-DOWNLOAD := $(YS-REPO-URL)/releases/download/$(YS-VERSION)/$(YS-TARBALL)

YS := $(LOCAL-BIN)/ys-$(YS-VERSION)

SHELL-DEPS += $(YS)


$(YS): $(LOCAL-CACHE)/$(YS-TARBALL)
	tar -C $(LOCAL-CACHE) -xf $<
	[[ -e $(LOCAL-CACHE)/$(YS-DIR)/ys-$(YS-VERSION) ]]
	mv $(LOCAL-CACHE)/$(YS-DIR)/ys* $(LOCAL-BIN)
	touch $@
	@echo

$(LOCAL-CACHE)/$(YS-TARBALL):
	@echo "Installing 'ys' locally"
	curl+ $(YS-DOWNLOAD) > $@

endif
