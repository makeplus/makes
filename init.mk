# Using bash to run commands gives us a stable foundation to build upon.
ifeq (/bin/sh,$(SHELL))
SHELL := bash
endif

MAKE-ROOT := $(shell pwd -P)

MAKES := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
MAKEFILE := $(abspath $(firstword $(MAKEFILE_LIST)))
# Note: abspath here removes the trailing /
MAKEFILE-DIR := $(abspath $(dir $(MAKEFILE)))

include $(MAKES)/env.mk
include $(MAKES)/help.mk


default::

bashrc::
	@echo export PATH=$$PATH

clean::

realclean:: clean

distclean:: realclean

help::
	@eval 'echo -e "$$HELP"'


.PHONY: default clean realclean distclean
