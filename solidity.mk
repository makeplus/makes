SOLIDITY-VERSION ?= 0.8.35
# https://github.com/argotorg/solidity

ifndef SOLIDITY-LOADED
SOLIDITY-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := solc-static-linux-arm
OA-linux-int64 := solc-static-linux
OA-macos-arm64 := solc-macos
OA-macos-int64 := solc-macos
OA-windows-int64 := solc-windows.exe

$(if $(OA-$(OS-ARCH)),,$(error solidity.mk does not support $(OS-ARCH)))

SOLIDITY-BIN := $(OA-$(OS-ARCH))
SOLIDITY-DOWN := https://github.com/argotorg/solidity/releases/download/v$(SOLIDITY-VERSION)/$(SOLIDITY-BIN)
SOLIDITY-LOCAL := $(LOCAL-ROOT)/solidity-$(SOLIDITY-VERSION)
ifeq ($(OS-NAME),windows)
SOLIDITY := $(SOLIDITY-LOCAL)/solc.exe
else
SOLIDITY := $(SOLIDITY-LOCAL)/solc
endif

SHELL-DEPS += $(SOLIDITY)

override PATH := $(SOLIDITY-LOCAL):$(PATH)
export PATH

$(SOLIDITY): $(LOCAL-CACHE)/solidity-$(SOLIDITY-VERSION)-$(SOLIDITY-BIN)
	@$(ECHO) "* Installing 'solidity' locally"
	$Q rm -rf $(SOLIDITY-LOCAL)
	$Q mkdir -p $(SOLIDITY-LOCAL)
	$Q cp $< $@
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/solidity-$(SOLIDITY-VERSION)-$(SOLIDITY-BIN):
	@$(ECHO) "* Downloading 'solidity' binary"
	$Q curl+ $(SOLIDITY-DOWN) > $@

endif
