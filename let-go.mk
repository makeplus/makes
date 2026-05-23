LET-GO-VERSION ?= 2.0.2

ifndef LET-GO-LOADED
LET-GO-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux_arm64
OA-linux-int64 := linux_amd64
OA-macos-arm64 := darwin_arm64
OA-macos-int64 := darwin_amd64

LET-GO-DIR := let-go_$(LET-GO-VERSION)_$(OA-$(OS-ARCH))
LET-GO-TAR := $(LET-GO-DIR).tar.gz
LET-GO-DOWN := https://github.com/nooga/let-go
LET-GO-DOWN := $(LET-GO-DOWN)/releases/download/v$(LET-GO-VERSION)/$(LET-GO-TAR)

LG := $(LOCAL-BIN)/lg

SHELL-DEPS += $(LG)


$(LG): $(LOCAL-CACHE)/$(LET-GO-TAR)
	$Q tar -C $(LOCAL-CACHE) -xf $<
	$Q [[ -e $(LOCAL-CACHE)/lg ]]
	$Q mv $(LOCAL-CACHE)/lg $(LOCAL-BIN)/
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(LET-GO-TAR):
	@$(ECHO) "* Installing 'lg' (let-go) locally"
	$Q curl+ $(LET-GO-DOWN) > $@

endif
