ifdef INIT-LOADED
$(error init.mk already loaded)
endif
INIT-LOADED := true

# Using bash to run commands gives us a stable foundation to build upon.
ifeq (/bin/sh,$(SHELL))
ifeq (,$(shell which bash))
$(error Makes requires a 'bash' in your PATH)
endif
SHELL := bash
endif

ROOT ?= $(shell pwd -P)

# Note: abspath here removes the trailing / added by dir
MAKES := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
MAKES-DIR := $(abspath $(dir $(MAKES)))

MAKEFILE := $(abspath $(firstword $(MAKEFILE_LIST)))
MAKEFILE-DIR := $(abspath $(dir $(MAKEFILE)))


ifndef MAKES-NO-RULES
default::

include $(MAKES)/makes.mk
endif


ifndef NO-PHONY-TEST
.PHONY: test
endif

define include-local
ifndef LOCAL-ROOT
include $(MAKES)/local.mk
endif
endef

OS-TYPE := $(shell bash -c 'echo $$OSTYPE')
ARCH-TYPE := $(shell bash -c 'echo $$MACHTYPE')
OS-NAME := $(shell cut -f1 -d- <<<'$(OS-TYPE)')
ARCH-NAME := $(shell cut -f1 -d- <<<'$(ARCH-TYPE)')
OS-ARCH := $(OS-NAME)_$(ARCH-NAME)

USER-UID := $(shell id -u)
USER-GID := $(shell id -g)

ifeq (0,$(USER-UID))
IS-ROOT := true
endif
