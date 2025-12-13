SHELLCHECK-VERSION ?= 0.11.0
# https://github.com/koalaman/shellcheck

ifndef SHELLCHECK-LOADED
SHELLCHECK-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux.aarch64
OA-linux-int64 := linux.x86_64
OA-macos-arm64 := darwin.aarch64
OA-macos-int64 := darwin.x86_64

SHELLCHECK-NAME := shellcheck-v$(SHELLCHECK-VERSION).$(OA-$(OS-ARCH))
SHELLCHECK-TAR := $(SHELLCHECK-NAME).tar.xz
SHELLCHECK-DOWN := https://github.com/koalaman/shellcheck
SHELLCHECK-DOWN := $(SHELLCHECK-DOWN)/releases/download/v$(SHELLCHECK-VERSION)/$(SHELLCHECK-TAR)

SHELLCHECK-DIR := shellcheck-v$(SHELLCHECK-VERSION)
SHELLCHECK := $(LOCAL-BIN)/shellcheck

SHELL-DEPS += $(SHELLCHECK)


$(SHELLCHECK): $(LOCAL-CACHE)/$(SHELLCHECK-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	[[ -e $(LOCAL-CACHE)/$(SHELLCHECK-DIR)/shellcheck ]]
	mv $(LOCAL-CACHE)/$(SHELLCHECK-DIR)/shellcheck $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(SHELLCHECK-TAR):
	@echo "* Installing 'shellcheck' locally"
	curl+ $(SHELLCHECK-DOWN) > $@

endif
