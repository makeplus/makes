SHELL := bash

MAKEFILE-SHELL-URL := https://github.com/makeplus/makesfiles/raw/main/shell.mk
MAKEFILE-TEST-URL := https://github.com/makeplus/makesfiles/raw/main/test.mk

SHELL-MK := <(curl -sL $(MAKEFILE-SHELL-URL))
ifneq (,$(wildcard ../makesfiles/shell.mk))
SHELL-MK := ../makesfiles/shell.mk
endif

TEST-MK := <(curl -sL $(MAKEFILE-TEST-URL))
ifneq (,$(wildcard ../makesfiles/test.mk))
TEST-MK := ../makesfiles/test.mk
endif

TARGETS := $(wildcard *.mk)
TARGETS := $(TARGETS:%.mk=%)
TARGETS := $(filter-out \
             clean docker git help init local shell \
	     ,$(TARGETS))
SHELL-TARGETS := $(TARGETS:%=%-shell)


default:

shell:
	$(MAKE) -f $(SHELL-MK) shell \
	  MAKES-INCLUDE='$m'

version-check:
	bin/check-versions

$(SHELL-TARGETS):
	$(MAKE) -f $(TEST-MK) shell \
	  MAKES-FILE=$(@:%-shell=%)
