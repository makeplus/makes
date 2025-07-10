SHELL := bash

MAKEFILE-SHELL-URL := https://github.com/makeplus/makesfiles/raw/main/shell.mk
MAKEFILE-TEST-URL := https://github.com/makeplus/makesfiles/raw/main/test.mk

TARGETS := $(wildcard *.mk)
TARGETS := $(TARGETS:%.mk=%)
TARGETS := $(filter-out shell,$(TARGETS))

default:

shell:
	$(MAKE) -f <(curl -sL $(MAKEFILE-SHELL-URL)) shell MAKES-INCLUDE='$m'

$(TARGETS):
	$(MAKE) -f <(curl -sL $(MAKEFILE-TEST-URL)) shell MAKES-FILE=$@
