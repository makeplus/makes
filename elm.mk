ELM-VERSION ?= 0.19.2
# https://github.com/elm/compiler

ifndef ELM-LOADED
ELM-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

ifneq (,$(filter 0.19.0 0.19.1,$(ELM-VERSION)))
ELM-PLATFORM-linux-int64 := linux-64-bit
ELM-PLATFORM-macos-arm64 := mac-64-bit-ARM
ELM-PLATFORM-macos-int64 := mac-64-bit
ELM-PLATFORM-windows-int64 := windows-64-bit
ELM-GZ := binary-for-$(ELM-PLATFORM-$(OS-ARCH)).gz
else
ELM-PLATFORM-linux-int64 := linux-x64
ELM-PLATFORM-linux-arm64 := linux-arm
ELM-PLATFORM-macos-arm64 := mac-arm
ELM-PLATFORM-macos-int64 := mac-x64
ELM-PLATFORM-windows-int64 := windows-x64
ELM-GZ := elm-$(ELM-VERSION)-$(ELM-PLATFORM-$(OS-ARCH)).gz
endif

$(if $(ELM-PLATFORM-$(OS-ARCH)),,$(error elm.mk does not support $(OS-ARCH)))

ifeq (windows,$(OS-NAME))
  ELM-EXE := elm.exe
else
  ELM-EXE := elm
endif

ELM-DOWN := https://github.com/elm/compiler/releases/download/$(ELM-VERSION)/$(ELM-GZ)
ELM-LOCAL := $(LOCAL-ROOT)/elm-$(ELM-VERSION)
ELM := $(ELM-LOCAL)/bin/$(ELM-EXE)

SHELL-DEPS += $(ELM)

override PATH := $(ELM-LOCAL)/bin:$(PATH)
export PATH


$(ELM): $(LOCAL-CACHE)/elm-$(ELM-VERSION)-$(ELM-GZ)
	$Q mkdir -p $(ELM-LOCAL)/bin
	$Q gzip -dc $< > $@
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/elm-$(ELM-VERSION)-$(ELM-GZ):
	@$(ECHO) "* Installing 'elm' locally"
	$Q curl+ $(ELM-DOWN) > $@

endif
