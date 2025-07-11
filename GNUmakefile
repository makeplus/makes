SHELL := bash

MAKEFILE-SHELL-URL := https://github.com/makeplus/makesfiles/raw/main/shell.mk
MAKEFILE-TEST-URL := https://github.com/makeplus/makesfiles/raw/main/test.mk

TARGETS := $(wildcard *.mk)
TARGETS := $(TARGETS:%.mk=%)
TARGETS := $(filter-out \
             clean docker git help init local shell \
	     ,$(TARGETS))
SHELL-TARGETS := $(TARGETS:%=%-shell)

default:

shell:
	$(MAKE) -f <(curl -sL $(MAKEFILE-SHELL-URL)) shell \
	  MAKES-INCLUDE='$m'

$(SHELL-TARGETS):
	$(MAKE) -f <(curl -sL $(MAKEFILE-TEST-URL)) shell \
	  MAKES-FILE=$(@:%-shell=%)
