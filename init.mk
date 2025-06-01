# Using bash to run commands gives us a stable foundation to build upon.
SHELL := bash

MAKE-ROOT := $(shell pwd -P)
MAKES := $(MAKE-ROOT)/.makes

include $(MAKES)/env.mk


default::

bashrc::
	@echo export PATH=$$PATH

clean::

realclean:: clean

distclean:: realclean

export HELP
_makes-help:
	@echo "$$HELP"


.PHONY: default clean realclean distclean
