# Using bash to run commands gives us a stable foundation to build upon.
SHELL := bash

MAKES-INIT := true
MAKE-ROOT := $(shell pwd -P)
MAKES := $(MAKE-ROOT)/.makes


default::

clean::

realclean:: clean

distclean:: realclean

export HELP
_makes-help:
	@echo "$$HELP"


.PHONY: default clean realclean distclean
