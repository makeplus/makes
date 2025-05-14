SHELL := bash
ROOT := $(shell pwd -P)

OS-TYPE := $(shell bash -c 'echo $$OSTYPE')

default::

clean::

realclean:: clean

distclean:: realclean


.PHONY: default clean realclean distclean
