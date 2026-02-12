LIBYS-VERSION ?= 0.2.9

ifndef LIBYS-LOADED
LIBYS-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-x64

LIBYS-DIR := libys-$(LIBYS-VERSION)-$(OA-$(OS-ARCH))
LIBYS-TAR := $(LIBYS-DIR).tar.xz
LIBYS-DOWN := https://github.com/yaml/yamlscript
LIBYS-DOWN := $(LIBYS-DOWN)/releases/download/$(LIBYS-VERSION)/$(LIBYS-TAR)

LIBYS := $(LOCAL-LIB)/libys.$(SO).$(LIBYS-VERSION)

export LD_LIBRARY_PATH := $(LOCAL-LIB):$(LD_LIBRARY_PATH)

SHELL-DEPS += $(LIBYS)


$(LIBYS): $(LOCAL-CACHE)/$(LIBYS-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	$(MAKE) -C $(LOCAL-CACHE)/$(LIBYS-DIR) install PREFIX=$(LOCAL-PREFIX)
	touch $@
	@echo

$(LOCAL-CACHE)/$(LIBYS-TAR):
	@echo "* Installing 'libys' locally"
	curl+ $(LIBYS-DOWN) > $@

endif
