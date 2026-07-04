TYPESCRIPT-VERSION ?= 6.0.3
# https://github.com/microsoft/TypeScript

ifndef TYPESCRIPT-LOADED
TYPESCRIPT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))

include $(MAKES)/node.mk

TYPESCRIPT-LOCAL := $(LOCAL-ROOT)/typescript-$(TYPESCRIPT-VERSION)
TYPESCRIPT-BIN := $(TYPESCRIPT-LOCAL)/node_modules/.bin
override PATH := $(TYPESCRIPT-BIN):$(PATH)
export PATH

ifeq ($(OS-NAME),windows)
TSC := $(TYPESCRIPT-BIN)/tsc.cmd
else
TSC := $(TYPESCRIPT-BIN)/tsc
endif
TYPESCRIPT := $(TSC)

SHELL-DEPS += $(TSC)


$(TSC): $(NODE)
	@echo "* Installing 'typescript' locally"
	npm install --prefix $(TYPESCRIPT-LOCAL) typescript@$(TYPESCRIPT-VERSION)
	@echo

endif
