PYTHON-VERSION := 3.13.7

ifndef PYTHON-LOADED
PYTHON-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/uv.mk

OA-linux-arm64 := linux-aarch64-none
OA-linux-int64 := linux-x86_64-gnu
OA-macos-arm64 := macos-aarch64-none
OA-macos-int64 := macos-x86_64-gnu

PYTHON-NAME := cpython-$(PYTHON-VERSION)-$(OA-$(OS-ARCH))
PYTHON-TAR := $(PYTHON-NAME).tar.gz
PYTHON-BIN := $(LOCAL-ROOT)/$(PYTHON-NAME)/bin
PYTHON := $(PYTHON-BIN)/python

export UV_PYTHON_INSTALL_DIR := $(LOCAL-ROOT)
override PATH := $(PYTHON-BIN):$(PATH)

PYTHON-VENV-SETUP ?= true
PYTHON-CACHE := __pycache__
PYTHON-VENV ?= $(LOCAL-ROOT)/python-venv
VENV := source $(PYTHON-VENV)/bin/activate
export VIRTUAL_ENV := $(PYTHON-VENV)
override PATH := $(PYTHON-VENV)/bin:$(PATH)

SHELL-DEPS += $(PYTHON) $(PYTHON-VENV)


$(PYTHON): $(UV)
	uv python install $(PYTHON-NAME)

$(PYTHON-VENV): $(PYTHON)
	@echo '+++ Installing a Python virtualenv in $@'
	$(PYTHON) -m venv $@
	$(PYTHON-VENV-SETUP)
	@echo

endif
