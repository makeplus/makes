MOONBIT-VERSION ?= latest
# https://github.com/moonbitlang/moonbit-compiler

ifndef MOONBIT-LOADED
MOONBIT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x86_64
OA-macos-arm64 := darwin-aarch64
OA-windows-int64 := windows-x86_64

ifeq (windows,$(OS-NAME))
  MOONBIT-EXT := zip
  MOONBIT-EXE := moon.exe
  MOONBIT-TCC := tcc.exe
else
  MOONBIT-EXT := tar.gz
  MOONBIT-EXE := moon
  MOONBIT-TCC := tcc
endif

MOONBIT-ARC := moonbit-$(OA-$(OS-ARCH)).$(MOONBIT-EXT)
MOONBIT-CORE := core-$(MOONBIT-VERSION).tar.gz
MOONBIT-DOWN := https://cli.moonbitlang.com/binaries/$(MOONBIT-VERSION)/$(MOONBIT-ARC)
MOONBIT-CORE-DOWN := https://cli.moonbitlang.com/cores/$(MOONBIT-CORE)
MOONBIT-LOCAL := $(LOCAL-ROOT)/moonbit-$(MOONBIT-VERSION)
MOON := $(MOONBIT-LOCAL)/bin/$(MOONBIT-EXE)

SHELL-DEPS += $(MOON)

override PATH := $(MOONBIT-LOCAL)/bin:$(PATH)
export PATH
export MOON_HOME := $(MOONBIT-LOCAL)


$(MOON): $(LOCAL-CACHE)/$(MOONBIT-ARC) $(LOCAL-CACHE)/$(MOONBIT-CORE)
	$Q rm -rf $(MOONBIT-LOCAL)
	$Q mkdir -p $(MOONBIT-LOCAL)
ifeq (windows,$(OS-NAME))
	$Q unzip -q $< -d $(MOONBIT-LOCAL)
else
	$Q tar -C $(MOONBIT-LOCAL) -xzf $<
endif
	$Q chmod +x $(MOONBIT-LOCAL)/bin/*
	$Q chmod +x $(MOONBIT-LOCAL)/bin/internal/$(MOONBIT-TCC)
	$Q tar -C $(MOONBIT-LOCAL)/lib -xzf $(LOCAL-CACHE)/$(MOONBIT-CORE)
	$Q PATH=$(MOONBIT-LOCAL)/bin:$(PATH) $(MOON) -C $(MOONBIT-LOCAL)/lib/core bundle --warn-list -a --all
	$Q PATH=$(MOONBIT-LOCAL)/bin:$(PATH) $(MOON) -C $(MOONBIT-LOCAL)/lib/core bundle --warn-list -a --target wasm-gc --quiet
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(MOONBIT-ARC):
	@$(ECHO) "* Installing 'moonbit' locally"
	$Q $(if $(OA-$(OS-ARCH)),,$(error MoonBit is not available for $(OS-ARCH)))
	$Q curl+ $(MOONBIT-DOWN) > $@

$(LOCAL-CACHE)/$(MOONBIT-CORE):
	$Q curl+ $(MOONBIT-CORE-DOWN) > $@

moonbit-test: $(MOON)
	@sh -c '$(CMD)'

moonbit-shell: $(MOON)
	@$(MAKE) shell

endif
