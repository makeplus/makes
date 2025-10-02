YAMLSCRIPT-VERSION ?= 0.2.4

ifndef YAMLSCRIPT-LOADED
YAMLSCRIPT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-x64

YAMLSCRIPT-DIR := ys-$(YAMLSCRIPT-VERSION)-$(OA-$(OS-ARCH))
YAMLSCRIPT-TAR := $(YAMLSCRIPT-DIR).tar.xz
YAMLSCRIPT-DOWN := https://github.com/yaml/yamlscript
YAMLSCRIPT-DOWN := $(YAMLSCRIPT-DOWN)/releases/download/$(YAMLSCRIPT-VERSION)/$(YAMLSCRIPT-TAR)

YS := $(LOCAL-BIN)/ys-$(YAMLSCRIPT-VERSION)

SHELL-DEPS += $(YS)


$(YS): $(LOCAL-CACHE)/$(YAMLSCRIPT-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	[[ -e $(LOCAL-CACHE)/$(YAMLSCRIPT-DIR)/ys-$(YAMLSCRIPT-VERSION) ]]
	mv $(LOCAL-CACHE)/$(YAMLSCRIPT-DIR)/ys* $(LOCAL-BIN)
	touch $@
	@echo

$(LOCAL-CACHE)/$(YAMLSCRIPT-TAR):
	@echo "* Installing 'ys' locally"
	curl+ $(YAMLSCRIPT-DOWN) > $@

endif
