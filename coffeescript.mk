COFFEESCRIPT-VERSION ?= 2.7.0
# https://www.npmjs.com/package/coffeescript

ifndef COFFEESCRIPT-LOADED
COFFEESCRIPT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/node.mk

ifeq ($(OS-NAME),windows)
  COFFEE-EXE := coffee.cmd
else
  COFFEE-EXE := coffee
endif

COFFEESCRIPT-LOCAL := $(LOCAL-ROOT)/coffeescript-$(COFFEESCRIPT-VERSION)
COFFEE := $(COFFEESCRIPT-LOCAL)/node_modules/.bin/$(COFFEE-EXE)

SHELL-DEPS += $(COFFEE)

override PATH := $(COFFEESCRIPT-LOCAL)/node_modules/.bin:$(PATH)
export PATH
export NPM_CONFIG_CACHE := $(LOCAL-CACHE)/npm


$(COFFEE): $(NODE)
	$Q npm install --prefix $(COFFEESCRIPT-LOCAL) coffeescript@$(COFFEESCRIPT-VERSION)
	$Q touch $@
	@$(ECHO)

endif
