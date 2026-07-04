MOONSCRIPT-VERSION ?= 0.5.0-1
# https://luarocks.org/modules/leafo/moonscript

ifndef MOONSCRIPT-LOADED
MOONSCRIPT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/luarocks.mk

MOONSCRIPT-LOCAL := $(LOCAL-ROOT)/moonscript-$(MOONSCRIPT-VERSION)
MOON := $(MOONSCRIPT-LOCAL)/bin/moon

SHELL-DEPS += $(MOON)

override PATH := $(MOONSCRIPT-LOCAL)/bin:$(PATH)
export PATH


$(MOON): $(LUAROCKS)
	$Q $(LUAROCKS) install --tree $(MOONSCRIPT-LOCAL) moonscript $(MOONSCRIPT-VERSION)
	$Q touch $@
	@$(ECHO)

endif
