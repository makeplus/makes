# Using bash to run commands gives us a stable foundation to build upon.
ifeq (/bin/sh,$(SHELL))
SHELL := bash
endif

ROOT ?= $(shell pwd -P)

MAKES := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
MAKEFILE := $(abspath $(firstword $(MAKEFILE_LIST)))
# Note: abspath here removes the trailing /
MAKEFILE-DIR := $(abspath $(dir $(MAKEFILE)))

include $(MAKES)/env.mk


ifeq (,$(findstring no-default ,$(MAKES-RULES) ))
default::
endif

ifneq (,$(findstring help , $(MAKES-RULES) ))
include $(MAKES)/help.mk
help::
	@eval 'echo -e "$$HELP"'
endif

include $(MAKES)/makes.mk

ifndef NO-PHONY-TEST
.PHONY: test
endif
