CLJR-VERSION ?= 1.12.6
# https://github.com/clojure/clojure-clr

ifndef CLJR-LOADED
CLJR-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/dotnet.mk

CLJR-LOCAL := $(LOCAL-ROOT)/cljr-$(CLJR-VERSION)
CLJR-BIN := $(CLJR-LOCAL)/bin
ifeq ($(OS-NAME),windows)
CLJR-TOOL := Clojure.Main.exe
CLJR-EXE := cljr.exe
else
CLJR-TOOL := Clojure.Main
CLJR-EXE := cljr
endif
CLJR := $(CLJR-BIN)/$(CLJR-EXE)

override PATH := $(CLJR-BIN):$(PATH)
export PATH

SHELL-DEPS += $(CLJR)


$(CLJR): | $(DOTNET)
	@$(ECHO) "* Installing 'cljr' locally"
	$Q $(DOTNET) tool install \
	  --tool-path $(CLJR-BIN) \
	  --version $(CLJR-VERSION) Clojure.Main $O
	$Q cp $(CLJR-BIN)/$(CLJR-TOOL) $@
	$Q touch $@
	@$(ECHO)

endif
