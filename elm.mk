ELM-VERSION ?= 0.19.2
# https://github.com/elm/compiler

ifndef ELM-LOADED
ELM-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-int64 := linux-64-bit
OA-macos-arm64 := mac-64-bit-ARM
OA-macos-int64 := mac-64-bit
OA-windows-int64 := windows-64-bit

ifeq (windows,$(OS-NAME))
  ELM-EXE := elm.exe
else
  ELM-EXE := elm
endif

ELM-GZ := binary-for-$(OA-$(OS-ARCH)).gz
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
