ZPRINT-VERSION ?= 1.3.0
# https://github.com/kkinnear/zprint

ifndef ZPRINT-LOADED
ZPRINT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := XXX
OA-linux-int64 := zprintl
OA-macos-arm64 := zprintma
OA-macos-int64 := zprintm

ZPRINT-NAME := $(OA-$(OS-ARCH))-$(ZPRINT-VERSION)
ZPRINT-DOWN := https://github.com/kkinnear/zprint
ZPRINT-DOWN := $(ZPRINT-DOWN)/releases/download/$(ZPRINT-VERSION)/$(ZPRINT-NAME)

ZPRINT := $(LOCAL-BIN)/zprint

SHELL-DEPS += $(ZPRINT)


$(ZPRINT): $(LOCAL-CACHE)/$(ZPRINT-NAME)
	cp $< $@
	chmod +x $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(ZPRINT-NAME):
	@echo "* Installing 'zprint' locally"
	curl+ $(ZPRINT-DOWN) > $@

endif
