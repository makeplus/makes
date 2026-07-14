LEAN-VERSION ?= 4.32.0
# https://github.com/leanprover/lean4

ifndef LEAN-LOADED
LEAN-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux_aarch64
OA-linux-int64 := linux
OA-macos-arm64 := darwin_aarch64
OA-macos-int64 := darwin
OA-windows-int64 := windows

LEAN-DIR := lean-$(LEAN-VERSION)-$(OA-$(OS-ARCH))
LEAN-ZIP := $(LEAN-DIR).zip
LEAN-DOWN := https://github.com/leanprover/lean4/releases/download/v$(LEAN-VERSION)/$(LEAN-ZIP)
LEAN-LOCAL := $(LOCAL-ROOT)/lean-$(LEAN-VERSION)
LEAN := $(LEAN-LOCAL)/bin/lean

SHELL-DEPS += $(LEAN)

override PATH := $(LEAN-LOCAL)/bin:$(PATH)
export PATH


$(LEAN): $(LOCAL-CACHE)/$(LEAN-ZIP)
	$Q rm -rf $(LEAN-LOCAL) $(LOCAL-CACHE)/$(LEAN-DIR)
	$Q unzip -q $< -d $(LOCAL-CACHE)
	$Q mv $(LOCAL-CACHE)/$(LEAN-DIR) $(LEAN-LOCAL)
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(LEAN-ZIP):
	@$(ECHO) "* Installing 'lean' locally"
	$Q curl+ $(LEAN-DOWN) > $@

endif
