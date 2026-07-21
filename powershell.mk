POWERSHELL-VERSION ?= 7.6.4
# https://github.com/PowerShell/PowerShell

ifndef POWERSHELL-LOADED
POWERSHELL-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-x64
OA-macos-arm64 := osx-arm64
OA-macos-int64 := osx-x64
OA-windows-arm64 := win-arm64
OA-windows-int64 := win-x64

ifeq (windows,$(OS-NAME))
  POWERSHELL-ARC := PowerShell-$(POWERSHELL-VERSION)-$(OA-$(OS-ARCH)).zip
  POWERSHELL-EXE := pwsh.exe
else
  POWERSHELL-ARC := powershell-$(POWERSHELL-VERSION)-$(OA-$(OS-ARCH)).tar.gz
  POWERSHELL-EXE := pwsh
endif

POWERSHELL-DOWN := https://github.com/PowerShell/PowerShell/releases/download/v$(POWERSHELL-VERSION)/$(POWERSHELL-ARC)
POWERSHELL-LOCAL := $(LOCAL-ROOT)/powershell-$(POWERSHELL-VERSION)
PWSH := $(POWERSHELL-LOCAL)/$(POWERSHELL-EXE)

SHELL-DEPS += $(PWSH)

override PATH := $(POWERSHELL-LOCAL):$(PATH)
export PATH


$(PWSH): $(LOCAL-CACHE)/$(POWERSHELL-ARC)
	$Q rm -rf $(POWERSHELL-LOCAL)
	$Q mkdir -p $(POWERSHELL-LOCAL)
ifeq (windows,$(OS-NAME))
	$Q unzip -q $< -d $(POWERSHELL-LOCAL)
else
	$Q tar -C $(POWERSHELL-LOCAL) -xzf $<
endif
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/$(POWERSHELL-ARC):
	@$(ECHO) "* Installing 'powershell' locally"
	$Q curl+ $(POWERSHELL-DOWN) > $@

endif
