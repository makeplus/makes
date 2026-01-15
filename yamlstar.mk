YAMLSTAR-VERSION ?= 0.1.0

ifndef YAMLSTAR-LOADED
YAMLSTAR-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-x64

YAMLSTAR-DIR := libyamlstar-$(YAMLSTAR-VERSION)-$(OA-$(OS-ARCH))
YAMLSTAR-TAR := $(YAMLSTAR-DIR).tar.xz
YAMLSTAR-DOWN := https://github.com/yaml/yamlstar
YAMLSTAR-DOWN := $(YAMLSTAR-DOWN)/releases/download/$(YAMLSTAR-VERSION)/$(YAMLSTAR-TAR)

LIBYAMLSTAR := $(LOCAL-LIB)/libyamlstar.$(SO).$(YAMLSTAR-VERSION)

export LD_LIBRARY_PATH := $(LOCAL-LIB):$(LD_LIBRARY_PATH)

SHELL-DEPS += $(LIBYAMLSTAR)


$(LIBYAMLSTAR): $(LOCAL-CACHE)/$(YAMLSTAR-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	$(MAKE) -C $(LOCAL-CACHE)/$(YAMLSTAR-DIR) install PREFIX=$(LOCAL-PREFIX)
	touch $@
	@echo

$(LOCAL-CACHE)/$(YAMLSTAR-TAR):
	@echo "* Installing 'libyamlstar' locally"
	curl+ $(YAMLSTAR-DOWN) > $@

endif
