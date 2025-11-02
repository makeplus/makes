SHELL := bash

TARGETS := $(wildcard *.mk)
TARGETS := $(TARGETS:%.mk=%)
TARGETS := $(filter-out \
             clean docker git help init local shell \
	     ,$(TARGETS))
TARGETS := $(TARGETS:%=%-shell)


default:

version-check:
	bin/check-versions

shell:
ifndef WITH
	@echo "WITH=... not specified for 'make shell'"
	@exit 1
endif
	$(MAKE) -f makefile.mk shell

$(TARGETS):
	$(MAKE) -f makefile.mk shell WITH=$(@:%-shell=%)
