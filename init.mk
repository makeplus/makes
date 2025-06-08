# Using bash to run commands gives us a stable foundation to build upon.
ifeq (/bin/sh,$(SHELL))
SHELL := bash
endif

# Deprecate MAKE-ROOT
MAKE-ROOT := $(shell pwd -P)
ROOT ?= $(shell pwd -P)

MAKES := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
MAKEFILE := $(abspath $(firstword $(MAKEFILE_LIST)))
# Note: abspath here removes the trailing /
MAKEFILE-DIR := $(abspath $(dir $(MAKEFILE)))

include $(MAKES)/env.mk
include $(MAKES)/help.mk


default::

help::
	@eval 'echo -e "$$HELP"'

clean::

realclean:: clean

distclean:: realclean


include $(MAKES)/makes.mk


.PHONY: default clean realclean distclean

ifndef NO-PHONY-TEST
.PHONY: test
endif
