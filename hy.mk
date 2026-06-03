HY-VERSION ?= 1.2.0
# https://github.com/hylang/hy

ifndef HY-LOADED
HY-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/uv.mk

HY-LOCAL := $(LOCAL-ROOT)/hy-$(HY-VERSION)
HY := $(HY-LOCAL)/bin/hy

export UV_TOOL_DIR := $(HY-LOCAL)/tools
export UV_TOOL_BIN_DIR := $(HY-LOCAL)/bin
export UV_PYTHON_INSTALL_DIR := $(LOCAL-ROOT)

override PATH := $(HY-LOCAL)/bin:$(PATH)
export PATH

SHELL-DEPS += $(HY)


$(HY): $(UV)
	@$(ECHO) "* Installing 'hy' locally"
	$Q uv tool install hy==$(HY-VERSION) $O
	$Q touch $@
	@$(ECHO)

endif
