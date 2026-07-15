ALIRE-VERSION ?= 2.1.1
# https://github.com/alire-project/alire

ifndef ALIRE-LOADED
ALIRE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-linux
OA-linux-int64 := x86_64-linux
OA-macos-arm64 := aarch64-macos
OA-macos-int64 := x86_64-macos
OA-windows-int64 := x86_64-windows

ifeq ($(OS-NAME),windows)
  ALR-EXE := alr.exe
else
  ALR-EXE := alr
endif

ALIRE-ZIP := alr-$(ALIRE-VERSION)-bin-$(OA-$(OS-ARCH)).zip
ALIRE-DOWN := https://github.com/alire-project/alire/releases/download
ALIRE-DOWN := $(ALIRE-DOWN)/v$(ALIRE-VERSION)/$(ALIRE-ZIP)

ALIRE-LOCAL := $(LOCAL-ROOT)/alire-$(ALIRE-VERSION)
ALIRE-BIN := $(ALIRE-LOCAL)/bin
ALR := $(ALIRE-BIN)/$(ALR-EXE)
ALIRE_SETTINGS_DIR ?= $(LOCAL-ROOT)/alire-settings

SHELL-DEPS += $(ALR)

override PATH := $(ALIRE-BIN):$(PATH)
export PATH
export ALIRE_SETTINGS_DIR


$(ALR): $(LOCAL-CACHE)/$(ALIRE-ZIP)
	$Q rm -rf $(ALIRE-LOCAL)
	$Q mkdir -p $(ALIRE-BIN)
	$Q unzip -q -j $< 'bin/$(ALR-EXE)' -d $(ALIRE-BIN)
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/$(ALIRE-ZIP):
	@$(ECHO) "* Installing 'alire' locally"
	$Q curl+ $(ALIRE-DOWN) > $@

endif
