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



ifndef MAKES-NO-RULES
default::

include $(MAKES)/makes.mk
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
$(error 123)
  ARCH-NAME := arm64
  IS-ARM := true
else ifneq (,$(findstring x86_64,$(ARCH-TYPE)))
  ARCH-NAME := int64
  IS-INTEL := true
else
  $(error Can't determine ARCH-TYPE)
endif

OS-ARCH := $(OS-NAME)-$(ARCH-NAME)

OA1-linux-arm64 := linux-aarch64
OA1-linux-int64 := linux-x64
OA1-macos-arm64 := macos-aarch64
OA1-macos-int64 := macos-x64

OA2-linux-arm64 := linux-arm64
OA2-linux-int64 := linux-amd64
OA2-macos-arm64 := darwin-arm64
OA2-macos-int64 := darwin-amd64

OA2_linux-arm64 := linux_arm64
OA2_linux-int64 := linux_amd64
OA2_macos-arm64 := darwin_arm64
OA2_macos-int64 := darwin_amd64

OA3-linux-arm64 := linux-arm64
OA3-linux-int64 := linux-x64
OA3-macos-arm64 := darwin-arm64
OA3-macos-int64 := darwin-x64

include $(MAKES-INCLUDE:%=$(MAKES)/%)
