TYPOS-VERSION ?= 1.43.5
# https://github.com/crate-ci/typos

ifndef TYPOS-LOADED
TYPOS-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-unknown-linux-musl
OA-linux-int64 := x86_64-unknown-linux-musl
OA-macos-arm64 := aarch64-apple-darwin
OA-macos-int64 := x86_64-apple-darwin

TYPOS-TAR := typos-v$(TYPOS-VERSION)-$(OA-$(OS-ARCH)).tar.gz
TYPOS-DOWN := https://github.com/crate-ci/typos/releases/download
TYPOS-DOWN := $(TYPOS-DOWN)/v$(TYPOS-VERSION)/$(TYPOS-TAR)

TYPOS := $(LOCAL-BIN)/typos

SHELL-DEPS += $(TYPOS)


$(TYPOS): $(LOCAL-CACHE)/$(TYPOS-TAR)
	tar -C $(LOCAL-BIN) -xf $< ./typos
	mv $(LOCAL-BIN)/./typos $(LOCAL-BIN)/typos || true
	[[ -e $@ ]]
	touch $@
	@echo

$(LOCAL-CACHE)/$(TYPOS-TAR):
	@echo "* Installing 'typos' locally"
	curl+ $(TYPOS-DOWN) > $@

endif
