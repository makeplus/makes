PYTHON-VERSION ?= 3.14.3
# https://www.github.com/python/cpython/tags

ifndef PYTHON-LOADED
PYTHON-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/uv.mk

OA-linux-arm64 := linux-aarch64-none
OA-linux-int64 := linux-x86_64-gnu
OA-macos-arm64 := macos-aarch64-none
OA-macos-int64 := macos-x86_64-gnu
OA-windows-arm64 := windows-aarch64-none
OA-windows-int64 := windows-x86_64-none

PYTHON-NAME := cpython-$(PYTHON-VERSION)-$(OA-$(OS-ARCH))
PYTHON-TAR := $(PYTHON-NAME).tar.gz
ifeq ($(OS-NAME),windows)
PYTHON-BIN := $(LOCAL-ROOT)/$(PYTHON-NAME)
PYTHON := $(PYTHON-BIN)/python.exe
else
PYTHON-BIN := $(LOCAL-ROOT)/$(PYTHON-NAME)/bin
PYTHON := $(PYTHON-BIN)/python
endif

PYTHON-VENV-SETUP ?= true

export UV_PYTHON_INSTALL_DIR := $(LOCAL-ROOT)
override PATH := $(PYTHON-BIN):$(PATH)

PYTHON-CACHE := __pycache__
PYTHON-VENV ?= $(LOCAL-ROOT)/python-venv
ifeq ($(OS-NAME),windows)
VENV := source $(PYTHON-VENV)/Scripts/activate
export VIRTUAL_ENV := $(PYTHON-VENV)
override PATH := $(PYTHON-VENV)/Scripts:$(PATH)
else
VENV := source $(PYTHON-VENV)/bin/activate
export VIRTUAL_ENV := $(PYTHON-VENV)
override PATH := $(PYTHON-VENV)/bin:$(PATH)
endif

SHELL-DEPS += $(PYTHON) $(PYTHON-VENV)


$(PYTHON): $(UV)
	uv python install $(PYTHON-NAME)

$(PYTHON-VENV): $(PYTHON)
	@echo '+++ Installing a Python virtualenv in $@'
	$(PYTHON) -m venv $@
	$(if $(wildcard requirements.txt),pip install -r requirements.txt,true)
	$(PYTHON-VENV-SETUP)
	@echo

endif
