PYRET-VERSION ?= 0.1.19
# https://www.npmjs.com/package/pyret-npm

ifndef PYRET-LOADED
PYRET-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/node.mk

ifeq ($(OS-NAME),windows)
  PYRET-EXE := pyret.cmd
else
  PYRET-EXE := pyret
endif

PYRET-LOCAL := $(LOCAL-ROOT)/pyret-$(PYRET-VERSION)
PYRET := $(PYRET-LOCAL)/node_modules/.bin/$(PYRET-EXE)

SHELL-DEPS += $(PYRET)

override PATH := $(PYRET-LOCAL)/node_modules/.bin:$(PATH)
export PATH
export NPM_CONFIG_CACHE := $(LOCAL-CACHE)/npm


$(PYRET): $(NODE)
	$Q npm install --prefix $(PYRET-LOCAL) pyret-npm@$(PYRET-VERSION)
	$Q touch $@
	@$(ECHO)

endif
