SQUINT-VERSION ?= 0.14.208
# https://www.npmjs.com/package/squint-cljs

ifndef SQUINT-LOADED
SQUINT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))

include $(MAKES)/node.mk

SQUINT-LOCAL := $(LOCAL-ROOT)/squint-$(SQUINT-VERSION)
SQUINT-BIN := $(SQUINT-LOCAL)/node_modules/.bin
override PATH := $(SQUINT-BIN):$(PATH)
export PATH
export NPM_CONFIG_CACHE := $(LOCAL-CACHE)/npm

ifeq ($(OS-NAME),windows)
SQUINT := $(SQUINT-BIN)/squint.cmd
else
SQUINT := $(SQUINT-BIN)/squint
endif

SHELL-DEPS += $(SQUINT)


$(SQUINT): $(NODE)
	@$(ECHO) "* Installing 'squint' locally"
	$Q npm install --prefix $(SQUINT-LOCAL) \
	  --no-audit --no-fund squint-cljs@$(SQUINT-VERSION) $O
	$Q touch $@
	@$(ECHO)

endif
