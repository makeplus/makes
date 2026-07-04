OCAML-VERSION ?= 5.5.0
# https://github.com/ocaml/opam

OPAM-VERSION ?= 2.5.1

ifndef OCAML-LOADED
OCAML-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := arm64-linux
OA-linux-int64 := x86_64-linux
OA-macos-arm64 := arm64-macos
OA-macos-int64 := x86_64-macos
OA-windows-int64 := x86_64-windows

ifeq (windows,$(OS-NAME))
  OPAM-EXE := opam.exe
  OPAM-BIN := opam-$(OPAM-VERSION)-$(OA-$(OS-ARCH)).exe
else
  OPAM-EXE := opam
  OPAM-BIN := opam-$(OPAM-VERSION)-$(OA-$(OS-ARCH))
endif

OPAM-DOWN := https://github.com/ocaml/opam/releases/download/$(OPAM-VERSION)/$(OPAM-BIN)
OCAML-LOCAL := $(LOCAL-ROOT)/ocaml-$(OCAML-VERSION)
OPAMROOT := $(OCAML-LOCAL)/opamroot
OPAM := $(OCAML-LOCAL)/bin/$(OPAM-EXE)
OCAML := $(OPAMROOT)/default/bin/ocaml

SHELL-DEPS += $(OCAML)

override PATH := $(OPAMROOT)/default/bin:$(OCAML-LOCAL)/bin:$(PATH)
export PATH
export OPAMROOT


$(OCAML): $(OPAM)
	$Q rm -rf $(OPAMROOT)
	$Q OPAMROOT=$(OPAMROOT) $(OPAM) init --bare --disable-sandboxing -y
	$Q OPAMROOT=$(OPAMROOT) $(OPAM) switch create default ocaml-base-compiler.$(OCAML-VERSION) -y
	$Q touch $@
	@$(ECHO)

$(OPAM): $(LOCAL-CACHE)/$(OPAM-BIN)
	$Q rm -rf $(OCAML-LOCAL)
	$Q mkdir -p $(OCAML-LOCAL)/bin
	$Q cp $< $@
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/$(OPAM-BIN):
	@$(ECHO) "* Installing 'ocaml' locally"
	$Q curl+ $(OPAM-DOWN) > $@

endif
