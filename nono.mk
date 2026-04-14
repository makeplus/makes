NONO-VERSION ?= 0.34.0
# https://github.com/always-further/nono

ifndef NONO-LOADED
NONO-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

ifdef IS-MACOS
include $(MAKES)/system.mk
$(eval $(call system-require,nono))

else
# Linux: download prebuilt binary

OA-linux-arm64 := aarch64-unknown-linux-gnu
OA-linux-int64 := x86_64-unknown-linux-gnu

NONO-TAR := nono-v$(NONO-VERSION)-$(OA-$(OS-ARCH)).tar.gz
NONO-DOWN := https://github.com/always-further/nono/releases/download
NONO-DOWN := $(NONO-DOWN)/v$(NONO-VERSION)/$(NONO-TAR)

NONO := $(LOCAL-BIN)/nono

SHELL-DEPS += $(NONO)


$(NONO): $(LOCAL-CACHE)/$(NONO-TAR)
	tar -C $(LOCAL-BIN) -xf $< nono
	[[ -e $@ ]]
	@touch $@
	@echo

$(LOCAL-CACHE)/$(NONO-TAR):
	@echo "* Installing 'nono' locally"
	curl+ $(NONO-DOWN) > $@

endif

endif
