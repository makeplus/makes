CAIRO-VERSION ?= 2.21.0
# https://github.com/software-mansion/scarb

ifndef CAIRO-LOADED
CAIRO-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-unknown-linux-gnu
OA-linux-int64 := x86_64-unknown-linux-gnu
OA-macos-arm64 := aarch64-apple-darwin
OA-macos-int64 := x86_64-apple-darwin
OA-windows-int64 := x86_64-pc-windows-msvc

ifeq (windows,$(OS-NAME))
  CAIRO-EXT := zip
  SCARB-EXE := scarb.exe
else
  CAIRO-EXT := tar.gz
  SCARB-EXE := scarb
endif

CAIRO-DIR := scarb-v$(CAIRO-VERSION)-$(OA-$(OS-ARCH))
CAIRO-ARC := $(CAIRO-DIR).$(CAIRO-EXT)
CAIRO-DOWN := https://github.com/software-mansion/scarb/releases/download/v$(CAIRO-VERSION)/$(CAIRO-ARC)
CAIRO-LOCAL := $(LOCAL-ROOT)/cairo-$(CAIRO-VERSION)
SCARB := $(CAIRO-LOCAL)/bin/$(SCARB-EXE)
CAIRO-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/scarb
CAIRO-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_scarb
CAIRO-COMP-FISH := $(LOCAL-SHARE)/fish/vendor_completions.d/scarb.fish
CAIRO-COMP := $(CAIRO-COMP-BASH) $(CAIRO-COMP-ZSH) $(CAIRO-COMP-FISH)

SHELL-DEPS += $(SCARB) $(CAIRO-COMP)

override PATH := $(CAIRO-LOCAL)/bin:$(PATH)
export PATH


$(SCARB): $(LOCAL-CACHE)/$(CAIRO-ARC)
	$Q rm -rf $(CAIRO-LOCAL) $(LOCAL-TMP)/cairo-$(CAIRO-VERSION)
	$Q mkdir -p $(CAIRO-LOCAL) $(LOCAL-TMP)/cairo-$(CAIRO-VERSION)
ifeq (windows,$(OS-NAME))
	$Q unzip -q $< -d $(LOCAL-TMP)/cairo-$(CAIRO-VERSION)
else
	$Q tar -C $(LOCAL-TMP)/cairo-$(CAIRO-VERSION) -xzf $<
endif
	$Q mv $(LOCAL-TMP)/cairo-$(CAIRO-VERSION)/$(CAIRO-DIR)/* $(CAIRO-LOCAL)/
	$Q chmod +x $(SCARB)
	@$(ECHO)

$(LOCAL-CACHE)/$(CAIRO-ARC):
	@$(ECHO) "* Installing 'cairo' locally"
	$Q curl+ $(CAIRO-DOWN) > $@

$(CAIRO-COMP-BASH): $(SCARB)
	$Q mkdir -p $(@D)
	$Q $(SCARB) completions bash > $@

$(CAIRO-COMP-ZSH): $(SCARB)
	$Q mkdir -p $(@D)
	$Q $(SCARB) completions zsh > $@

$(CAIRO-COMP-FISH): $(SCARB)
	$Q mkdir -p $(@D)
	$Q $(SCARB) completions fish > $@

endif
