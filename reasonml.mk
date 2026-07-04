REASONML-VERSION ?= 3.3.4
# https://www.npmjs.com/package/reason

ifndef REASONML-LOADED
REASONML-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/node.mk

REASONML-LOCAL := $(LOCAL-ROOT)/reasonml-$(REASONML-VERSION)
REFMT := $(REASONML-LOCAL)/bin/refmt

SHELL-DEPS += $(REFMT)

override PATH := $(REASONML-LOCAL)/bin:$(PATH)
export PATH
export NPM_CONFIG_CACHE := $(LOCAL-CACHE)/npm


$(REFMT): $(NODE)
	$Q npm install --prefix $(REASONML-LOCAL) reason@$(REASONML-VERSION)
	$Q mkdir -p $(REASONML-LOCAL)/bin
	$Q printf '#!/usr/bin/env bash\nexec %s %s "$$@"\n' '$(NODE)' '$(REASONML-LOCAL)/node_modules/reason/refmt.js' > $@
	$Q chmod +x $@
	$Q touch $@
	@$(ECHO)

endif
