LET-GO-VERSION ?= 1.11.0

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

LET-GO-LOCAL := $(LOCAL-ROOT)/let-go-$(LET-GO-VERSION)
LG := $(LET-GO-LOCAL)/bin/lg

SHELL-DEPS += $(LG)

override PATH := $(LET-GO-LOCAL)/bin:$(PATH)
export PATH


$(LG): $(LOCAL-CACHE)/$(LET-GO-TAR)
	$Q mkdir -p $(LET-GO-LOCAL)/bin
	$Q tar -C $(LOCAL-CACHE) -xf $<
	$Q [[ -e $(LOCAL-CACHE)/lg ]]
	$Q mv $(LOCAL-CACHE)/lg $(LET-GO-LOCAL)/bin/
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(LET-GO-TAR):
	@$(ECHO) "* Installing 'lg' (let-go) locally"
	$Q curl+ $(LET-GO-DOWN) > $@

endif
