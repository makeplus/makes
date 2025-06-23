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

include $(MAKES)/env.mk


ifndef MAKES-NO-RULES
default::
endif

include $(MAKES)/makes.mk

ifndef NO-PHONY-TEST
.PHONY: test
endif

define include-local
ifndef LOCAL-ROOT
include $(MAKES)/local.mk
endif
endef
