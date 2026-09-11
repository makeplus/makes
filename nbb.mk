NBB-VERSION ?= 1.5.212
# https://www.npmjs.com/package/nbb

ifndef NBB-LOADED
NBB-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))

include $(MAKES)/node.mk

NBB-LOCAL := $(LOCAL-ROOT)/nbb-$(NBB-VERSION)
NBB-BIN := $(NBB-LOCAL)/node_modules/.bin
override PATH := $(NBB-BIN):$(PATH)
export PATH
export NPM_CONFIG_CACHE := $(LOCAL-CACHE)/npm

ifeq ($(OS-NAME),windows)
NBB := $(NBB-BIN)/nbb.cmd
else
NBB := $(NBB-BIN)/nbb
endif

SHELL-DEPS += $(NBB)


$(NBB): $(NODE)
	@$(ECHO) "* Installing 'nbb' locally"
	$Q npm install --prefix $(NBB-LOCAL) \
	  --no-audit --no-fund nbb@$(NBB-VERSION) $O
	$Q touch $@
	@$(ECHO)

endif
