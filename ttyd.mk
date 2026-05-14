TTYD-VERSION ?= 1.7.7
# https://github.com/tsl0922/ttyd

ifndef TTYD-LOADED
TTYD-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64
OA-linux-int64 := x86_64

ifeq (,$(OA-$(OS-ARCH)))
$(error 'ttyd' has no prebuilt binary for $(OS-ARCH); see https://github.com/tsl0922/ttyd)
endif

TTYD-BIN := ttyd.$(OA-$(OS-ARCH))
TTYD-DOWN := https://github.com/tsl0922/ttyd
TTYD-DOWN := $(TTYD-DOWN)/releases/download/$(TTYD-VERSION)/$(TTYD-BIN)

TTYD := $(LOCAL-BIN)/ttyd

SHELL-DEPS += $(TTYD)


$(TTYD): $(LOCAL-CACHE)/$(TTYD-BIN)
	$Q cp $< $@
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/$(TTYD-BIN):
	@$(ECHO) "* Installing 'ttyd' locally"
	$Q curl+ $(TTYD-DOWN) > $@

endif
