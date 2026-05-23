JOKER-VERSION ?= 1.7.2
# https://github.com/candid82/joker

ifndef JOKER-LOADED
JOKER-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := mac-arm64
OA-macos-int64 := mac-amd64

JOKER-ZIP := joker-$(OA-$(OS-ARCH)).zip
JOKER-DOWN := https://github.com/candid82/joker
JOKER-DOWN := $(JOKER-DOWN)/releases/download/v$(JOKER-VERSION)/$(JOKER-ZIP)

JOKER := $(LOCAL-BIN)/joker

SHELL-DEPS += $(JOKER)


$(JOKER): $(LOCAL-CACHE)/$(JOKER-ZIP)
	$Q unzip -q -d $(LOCAL-CACHE) $<
	$Q [[ -e $(LOCAL-CACHE)/joker ]]
	$Q mv $(LOCAL-CACHE)/joker $(LOCAL-BIN)/
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(JOKER-ZIP):
	@$(ECHO) "* Installing 'joker' locally"
	$Q curl+ $(JOKER-DOWN) > $@

endif
