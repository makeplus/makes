ifndef MAKES
$(error Please 'include .makes/init.mk')
endif
ifndef LOCAL-ROOT
include $(MAKES)/local.mk
endif

PYTHON := $(shell command -v python3)
PYTHON ?= $(shell command -v python)
ifndef PYTHON
  $(error Python doesn't seem to be installed)
endif

PYTHON-VENV := $(ROOT)/.venv
VENV := source $(PYTHON-VENV)/bin/activate

distclean::
	$(RM) -r $(PYTHON-VENV)


$(PYTHON-VENV):
	$(PYTHON) -m venv $@
	$(VENV) && pip install mkdocs-material
