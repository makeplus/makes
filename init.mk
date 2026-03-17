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

export PATH := $(MAKES)/util:$(PATH)
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
  SO := dylib
else ifneq (,$(findstring linux,$(OS-TYPE)))
  OS-NAME := linux
  IS-LINUX := true
  SO := so
else ifneq (,$(or $(findstring msys,$(OS-TYPE)),$(findstring cygwin,$(OS-TYPE))))
  OS-NAME := windows
  IS-WINDOWS := true
  SO := dll
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

ifdef MAKES_TEE
MAKES-TEE ?= $(MAKES_TEE)
endif
ifdef MAKES_SCRIPT
MAKES-SCRIPT ?= $(MAKES_SCRIPT)
endif

ifdef MAKES-TEE
MAKES-LOG-MODE := tee
MAKES-LOG-VAL := $(MAKES-TEE)
else ifdef MAKES-SCRIPT
MAKES-LOG-MODE := script
MAKES-LOG-VAL := $(MAKES-SCRIPT)
endif

ifdef MAKES-LOG-MODE
ifeq (1,$(MAKES-LOG-VAL))
MAKES-LOG-FILE := ./make-out.txt
else
MAKES-LOG-FILE := $(MAKES-LOG-VAL)
endif
MAKES-LOG-OVERRIDES := $(filter-out \
  MAKES-TEE=% MAKES_TEE=% MAKES-SCRIPT=% MAKES_SCRIPT=%,\
  $(MAKEOVERRIDES))
$(MAKECMDGOALS): _makes-log
	@:
_makes-log:
	@exec $(MAKES)/util/make-log \
	  $(MAKES-LOG-MODE) $(MAKES-LOG-FILE) $(MAKE) $(MAKEFILE) \
	  $(MAKES-LOG-OVERRIDES) -- $(MAKECMDGOALS)
.PHONY: _makes-log $(MAKECMDGOALS)
endif

include $(MAKES-INCLUDE:%=$(MAKES)/%)

ifndef MAKES-NO-DELETE
.DELETE_ON_ERROR:
endif
