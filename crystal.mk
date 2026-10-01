CRYSTAL-VERSION ?= 1.21.1

ifndef CRYSTAL-LOADED
CRYSTAL-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := XXX
OA-linux-int64 := linux-x86_64-bundled
OA-macos-arm64 := darwin-universal
OA-macos-int64 := darwin-universal
OA-windows-arm64 := windows-aarch64-gnu-unsupported
OA-windows-int64 := windows-x86_64-gnu-unsupported

CRYSTAL-DIR := crystal-$(CRYSTAL-VERSION)-1
ifeq ($(OS-NAME),windows)
CRYSTAL-TAR := crystal-$(CRYSTAL-VERSION)-$(OA-$(OS-ARCH)).zip
else
CRYSTAL-TAR := $(CRYSTAL-DIR)-$(OA-$(OS-ARCH)).tar.gz
endif
CRYSTAL-DOWN := https://github.com/crystal-lang/crystal/releases/download
CRYSTAL-DOWN := $(CRYSTAL-DOWN)/$(CRYSTAL-VERSION)/$(CRYSTAL-TAR)

CRYSTAL-LOCAL := $(LOCAL-ROOT)/$(CRYSTAL-DIR)
CRYSTAL-BIN := $(CRYSTAL-LOCAL)/bin
override PATH := $(CRYSTAL-BIN):$(PATH)
export PATH

ifeq ($(OS-NAME),windows)
CRYSTAL := $(CRYSTAL-BIN)/crystal.exe
else
CRYSTAL := $(CRYSTAL-BIN)/crystal
endif
CRYSTAL-COMP-BASH := \
  $(LOCAL-SHARE)/bash-completion/completions/crystal
CRYSTAL-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_crystal
CRYSTAL-COMP-FISH := \
  $(LOCAL-SHARE)/fish/vendor_completions.d/crystal.fish
CRYSTAL-COMP := \
  $(CRYSTAL-COMP-BASH) \
  $(CRYSTAL-COMP-ZSH) \
  $(CRYSTAL-COMP-FISH)
CRYSTAL-COMP-ZSH-CACHE := \
  $(LOCAL-CACHE)/crystal-$(CRYSTAL-VERSION)-completion.zsh
CRYSTAL-COMP-ZSH-DOWN := https://raw.githubusercontent.com
CRYSTAL-COMP-ZSH-DOWN := \
  $(CRYSTAL-COMP-ZSH-DOWN)/crystal-lang/crystal/$(CRYSTAL-VERSION)
CRYSTAL-COMP-ZSH-DOWN := $(CRYSTAL-COMP-ZSH-DOWN)/etc/completion.zsh
CRYSTAL-MAN := $(LOCAL-MAN)/man1/crystal.1.gz

SHELL-DEPS += $(CRYSTAL) $(CRYSTAL-COMP) $(CRYSTAL-MAN)


ifeq ($(OS-NAME),windows)
$(CRYSTAL): $(LOCAL-CACHE)/$(CRYSTAL-TAR)
	mkdir -p $(CRYSTAL-LOCAL)
	cd $(CRYSTAL-LOCAL) && unzip -q $(LOCAL-CACHE)/$(CRYSTAL-TAR)
	touch $@
	@echo
else
$(CRYSTAL): $(LOCAL-CACHE)/$(CRYSTAL-TAR)
	tar -C $(LOCAL-CACHE) -xzf $<
	mv $(LOCAL-CACHE)/$(CRYSTAL-DIR) $(CRYSTAL-LOCAL)
	touch $@
	@echo
endif

$(LOCAL-CACHE)/$(CRYSTAL-TAR):
	@echo "* Installing 'crystal' locally"
	curl+ $(CRYSTAL-DOWN) > $@

$(CRYSTAL-COMP-BASH): $(CRYSTAL)
	$Q mkdir -p $(@D)
	$Q cp $(CRYSTAL-LOCAL)/share/bash-completion/completions/crystal $@

$(CRYSTAL-COMP-ZSH): $(CRYSTAL-COMP-ZSH-CACHE)
	$Q mkdir -p $(@D)
	$Q cp $< $@

$(CRYSTAL-COMP-FISH): $(CRYSTAL)
	$Q mkdir -p $(@D)
	$Q cp \
	  $(CRYSTAL-LOCAL)/share/fish/vendor_completions.d/crystal.fish $@

$(CRYSTAL-COMP-ZSH-CACHE):
	$Q curl+ $(CRYSTAL-COMP-ZSH-DOWN) > $@

$(CRYSTAL-MAN): $(CRYSTAL)
	$Q mkdir -p $(LOCAL-MAN)/man1 $(LOCAL-MAN)/man5
	$Q cp $(CRYSTAL-LOCAL)/share/man/man1/*.1.gz $(LOCAL-MAN)/man1/
	$Q cp $(CRYSTAL-LOCAL)/share/man/man5/*.5.gz $(LOCAL-MAN)/man5/

endif
