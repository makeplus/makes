LIBYAMLSTAR-VERSION ?= 0.1.2

ifndef LIBYAMLSTAR-LOADED
LIBYAMLSTAR-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-x64

LIBYAMLSTAR-DIR := libyamlstar-$(LIBYAMLSTAR-VERSION)-$(OA-$(OS-ARCH))
LIBYAMLSTAR-TAR := $(LIBYAMLSTAR-DIR).tar.xz
LIBYAMLSTAR-DOWN := https://github.com/yaml/yamlstar
LIBYAMLSTAR-DOWN := $(LIBYAMLSTAR-DOWN)/releases/download/$(LIBYAMLSTAR-VERSION)/$(LIBYAMLSTAR-TAR)

LIBYAMLSTAR := $(LOCAL-LIB)/libyamlstar.$(SO).$(LIBYAMLSTAR-VERSION)

export LD_LIBRARY_PATH := $(LOCAL-LIB):$(LD_LIBRARY_PATH)

SHELL-DEPS += $(LIBYAMLSTAR)


$(LIBYAMLSTAR): $(LOCAL-CACHE)/$(LIBYAMLSTAR-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	$(MAKE) -C $(LOCAL-CACHE)/$(LIBYAMLSTAR-DIR) install PREFIX=$(LOCAL-PREFIX)
	touch $@
	@echo

$(LOCAL-CACHE)/$(LIBYAMLSTAR-TAR):
	@echo "* Installing 'libyamlstar' locally"
	curl+ $(LIBYAMLSTAR-DOWN) > $@

endif
