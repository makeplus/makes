CLJR-VERSION ?= 1.13.0-alpha6
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
export DOTNET_CLI_HOME ?= $(LOCAL-CACHE)/dotnet-home
export NUGET_PACKAGES ?= $(LOCAL-CACHE)/nuget-packages

SHELL-DEPS += $(CLJR)


$(CLJR): $(DOTNET)
	@$(ECHO) "* Installing 'cljr' locally"
	$Q $(DOTNET) tool install \
	  --tool-path $(CLJR-BIN) \
	  --version $(CLJR-VERSION) Clojure.Main $O
	$Q mv $(CLJR-BIN)/$(CLJR-TOOL) $@
	$Q touch $@
	@$(ECHO)

endif
