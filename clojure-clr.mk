CLOJURE-CLR-VERSION ?= 1.12.6
# https://github.com/clojure/clojure-clr

ifndef CLOJURE-CLR-LOADED
CLOJURE-CLR-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/dotnet.mk

CLOJURE-CLR-LOCAL := $(LOCAL-ROOT)/clojure-clr-$(CLOJURE-CLR-VERSION)
CLOJURE-CLR-BIN := $(CLOJURE-CLR-LOCAL)/bin
ifeq ($(OS-NAME),windows)
CLOJURE-CLR-TOOL := Clojure.Main.exe
CLOJURE-CLR-EXE := cljr.exe
else
CLOJURE-CLR-TOOL := Clojure.Main
CLOJURE-CLR-EXE := cljr
endif
CLOJURE-CLR := $(CLOJURE-CLR-BIN)/$(CLOJURE-CLR-EXE)

override PATH := $(CLOJURE-CLR-BIN):$(PATH)
export PATH
export DOTNET_CLI_HOME ?= $(LOCAL-CACHE)/dotnet-home
export NUGET_PACKAGES ?= $(LOCAL-CACHE)/nuget-packages

SHELL-DEPS += $(CLOJURE-CLR)


$(CLOJURE-CLR): $(DOTNET)
	@$(ECHO) "* Installing 'clojure-clr' locally"
	$Q $(DOTNET) tool install \
	  --tool-path $(CLOJURE-CLR-BIN) \
	  --version $(CLOJURE-CLR-VERSION) Clojure.Main $O
	$Q mv $(CLOJURE-CLR-BIN)/$(CLOJURE-CLR-TOOL) $@
	$Q touch $@
	@$(ECHO)

endif
