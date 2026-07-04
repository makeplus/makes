RED-VERSION ?= 0.6.6
# https://www.red-lang.org/p/download.html

ifndef RED-LOADED
RED-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-int64 := linux
OA-macos-int64 := mac
OA-windows-int64 := win

ifeq ($(OS-NAME),windows)
  RED-NAME := red-view.exe
else ifeq ($(OS-NAME),macos)
  RED-NAME := red-view.zip
else
  RED-NAME := red-view
endif

RED-DOWN := https://static.red-lang.org/dl/$(OA-$(OS-ARCH))/$(RED-NAME)
RED-LOCAL := $(LOCAL-ROOT)/red-$(RED-VERSION)
RED := $(RED-LOCAL)/bin/red

SHELL-DEPS += $(RED)

override PATH := $(RED-LOCAL)/bin:$(PATH)
export PATH


$(RED): $(LOCAL-CACHE)/$(RED-NAME)
	$Q mkdir -p $(RED-LOCAL)/bin
ifeq ($(OS-NAME),macos)
	$Q unzip -q -j $< red-view -d $(RED-LOCAL)/bin
	$Q mv $(RED-LOCAL)/bin/red-view $@
else
	$Q cp $< $@
endif
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/$(RED-NAME):
	@$(ECHO) "* Installing 'red' locally"
	$Q curl+ $(RED-DOWN) > $@

endif
