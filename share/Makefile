#-------------------------------------------------------------------------------
# This is an example Makefile using makes.
#-------------------------------------------------------------------------------

M := .git/.makes
$(shell [ -d $M ] || (git clone -q https://github.com/makeplus/makes $M))
include .makes/init.mk
include $(MAKES)/go.mk
include $(MAKES)/python.mk
include $(MAKES)/rust.mk
include $(MAKES)/ys.mk


default:: help

help: _makes-help

install: build

# Go:
build test: $(CARGO)
	cargo $@
