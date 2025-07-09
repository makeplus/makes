SHELL := bash

MAKEFILE-URL := https://github.com/makeplus/makesfiles/raw/main/shell.mk

TARGETS := $(wildcard *.mk)
TARGETS := $(TARGETS:%.mk=%)

default:

shell:
	$(MAKE) -f <(curl -sL $(MAKEFILE-URL)) shell MAKES-INCLUDE='$m'

$(TARGETS):
	$(MAKE) -f <(curl -sL $(MAKEFILE-URL)) shell MAKES-INCLUDE=$@.mk
