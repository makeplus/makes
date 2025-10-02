ifdef INIT-LOADED
$(error init.mk already loaded)
endif
INIT-LOADED := true

# Using bash to run commands gives us a stable foundation to build upon.
ifeq (/bin/sh,$(SHELL))
ifeq (,$(shell which bash))
  $(error Makes requires a 'bash' in your PATH)
endif
  SHELL := bash
endif

ROOT ?= $(shell pwd -P)

# Note: abspath here removes the trailing / added by dir
MAKES := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
MAKES-DIR := $(abspath $(dir $(MAKES)))

MAKEFILE := $(abspath $(firstword $(MAKEFILE_LIST)))
MAKEFILE-DIR := $(abspath $(dir $(MAKEFILE)))

export PATH := $(MAKES)/bin:$(PATH)
export LANG := en_US.UTF-8

# For commands dealing with space characters
null :=
space := $(null) #

ifdef MAKES-QUIET
Q ?= @
O ?= &>/dev/null
ECHO ?= :$(space)
else
ECHO ?= echo
endif


ifndef MAKES-NO-DEFAULT
default::
endif

ifndef NO-PHONY-TEST
.PHONY: test
endif

define include-local
$(if $(SHELL-LOADED),$(error shell.mk should be included last))
ifndef LOCAL-LOADED
  include $(MAKES)/local.mk
endif
endef

USER-UID := $(shell id -u)
USER-GID := $(shell id -g)

ifeq (0,$(USER-UID))
IS-ROOT := true
endif

OS-TYPE := $(shell bash -c 'echo $$OSTYPE')
ifneq (,$(findstring darwin,$(OS-TYPE)))
  OS-NAME := macos
  IS-MACOS := true
else ifneq (,$(findstring linux,$(OS-TYPE)))
  OS-NAME := linux
  IS-LINUX := true
else
  $(error Can't determine OS-TYPE)
endif

ARCH-TYPE := $(shell bash -c 'echo $$MACHTYPE')
ifneq (,$(or $(findstring arm64,$(ARCH-TYPE)), \
             $(findstring aarch64,$(ARCH-TYPE))))
  ARCH-NAME := arm64
  IS-ARM := true
else ifneq (,$(findstring x86_64,$(ARCH-TYPE)))
  ARCH-NAME := int64
  IS-INTEL := true
else
  $(error Can't determine ARCH-TYPE)
endif

OS-ARCH := $(OS-NAME)-$(ARCH-NAME)

include $(MAKES-INCLUDE:%=$(MAKES)/%)
