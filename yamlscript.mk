YAMLSCRIPT-VERSION ?= 0.2.28

ifndef YAMLSCRIPT-LOADED
ifndef YS-LOADED
YAMLSCRIPT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-x64
OA-windows-int64 := windows-x64

YAMLSCRIPT-DIR := ys-$(YAMLSCRIPT-VERSION)-$(OA-$(OS-ARCH))
ifeq ($(OS-NAME),windows)
YAMLSCRIPT-TAR := $(YAMLSCRIPT-DIR).zip
YS := $(LOCAL-BIN)/ys-$(YAMLSCRIPT-VERSION).exe
else
YAMLSCRIPT-TAR := $(YAMLSCRIPT-DIR).tar.xz
YS := $(LOCAL-BIN)/ys-$(YAMLSCRIPT-VERSION)
endif
YAMLSCRIPT-DOWN := https://github.com/yaml/yamlscript
YAMLSCRIPT-DOWN := $(YAMLSCRIPT-DOWN)/releases/download/$(YAMLSCRIPT-VERSION)/$(YAMLSCRIPT-TAR)

SHELL-DEPS += $(YS)


$(YS): $(LOCAL-CACHE)/$(YAMLSCRIPT-TAR)
ifeq ($(OS-NAME),windows)
	unzip -q -d $(LOCAL-CACHE) $<
	[[ -e $(LOCAL-CACHE)/$(YAMLSCRIPT-DIR)/ys-$(YAMLSCRIPT-VERSION).exe ]]
	mv $(LOCAL-CACHE)/$(YAMLSCRIPT-DIR)/ys* $(LOCAL-BIN)
else
	tar -C $(LOCAL-CACHE) -xf $<
	[[ -e $(LOCAL-CACHE)/$(YAMLSCRIPT-DIR)/ys-$(YAMLSCRIPT-VERSION) ]]
	mv $(LOCAL-CACHE)/$(YAMLSCRIPT-DIR)/ys* $(LOCAL-BIN)
endif
	touch $@
	@echo

$(LOCAL-CACHE)/$(YAMLSCRIPT-TAR):
	@echo "* Installing 'ys' locally"
	curl+ $(YAMLSCRIPT-DOWN) > $@

endif
endif
