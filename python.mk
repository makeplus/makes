ifndef PYTHON-LOADED
PYTHON-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

PYTHON := $(shell command -v python3)
PYTHON ?= $(shell command -v python)
ifndef PYTHON
  $(error Python doesn't seem to be installed)
endif

PYTHON-VENV-SETUP ?= true
PYTHON-CACHE := __pycache__
PYTHON-VENV ?= $(LOCAL-ROOT)/python-venv
VENV := source $(PYTHON-VENV)/bin/activate
export VIRTUAL_ENV := $(PYTHON-VENV)
override PATH := $(PYTHON-VENV)/bin:$(PATH)

SHELL-DEPS += $(PYTHON-VENV)


$(PYTHON-VENV):
	@echo '+++ Installing a Python virtualenv in $@'
	$(PYTHON) -m venv $@
	$(PYTHON-VENV-SETUP)
	@echo

endif
