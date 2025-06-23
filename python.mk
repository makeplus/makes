$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

PYTHON := $(shell command -v python3)
PYTHON ?= $(shell command -v python)
ifndef PYTHON
  $(error Python doesn't seem to be installed)
endif

PYTHON-CACHE := __pycache__

PYTHON-VENV-DIR := $(MAKES-DIR)/.venv
PYTHON-VENV := $(PYTHON-VENV-DIR)/bin/activate
VENV := source $(PYTHON-VENV)


$(PYTHON-VENV): $(PYTHON-VENV-DIR)
	@touch $@

$(PYTHON-VENV-DIR):
	@echo 'Installing a Python virtualenv in $@'
	$(PYTHON) -m venv $@
	@echo
