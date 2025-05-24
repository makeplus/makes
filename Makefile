#-------------------------------------------------------------------------------
# This is an example Makefile using makes.
#-------------------------------------------------------------------------------

$(shell [ -d .makes ] || \
  (git clone -q https://github.com/makeplus/makes .makes))
include .makes/init.mk
include $(MAKES)/rust.mk

define HELP
Available targets:
  install      - Install to $$PREFIX/bin/
  test         - Run tests
  clean        - Clean build artifacts
  help         - Show this help message
endef


default:: help

help: _makes-help

install: build

build test: $(CARGO)
	cargo $@
