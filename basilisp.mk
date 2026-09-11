BASILISP-VERSION ?= 0.5.1
# https://github.com/basilisp-lang/basilisp

ifndef BASILISP-LOADED
BASILISP-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/uv.mk

# Python 3.12 has binary wheels for both immutables and pyrsistent.
BASILISP-PYTHON-VERSION ?= 3.12
BASILISP-LOCAL := $(LOCAL-ROOT)/basilisp-$(BASILISP-VERSION)
BASILISP-BIN := $(BASILISP-LOCAL)/bin
ifeq ($(OS-NAME),windows)
BASILISP := $(BASILISP-BIN)/basilisp.exe
else
BASILISP := $(BASILISP-BIN)/basilisp
endif

override PATH := $(BASILISP-BIN):$(PATH)
export PATH
export XDG_DATA_HOME ?= $(LOCAL-SHARE)

SHELL-DEPS += $(BASILISP)


$(BASILISP): $(UV)
	@$(ECHO) "* Installing 'basilisp' locally"
	$Q UV_CACHE_DIR=$(LOCAL-CACHE)/uv \
	  UV_TOOL_DIR=$(BASILISP-LOCAL)/tools \
	  UV_TOOL_BIN_DIR=$(BASILISP-BIN) \
	  UV_PYTHON_INSTALL_DIR=$(LOCAL-ROOT) \
	  $(UV) tool install --managed-python \
	    --python $(BASILISP-PYTHON-VERSION) basilisp==$(BASILISP-VERSION) $O
	$Q touch $@
	@$(ECHO)

endif
