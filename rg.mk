RG-VERSION ?= 15.2.0
# https://github.com/BurntSushi/ripgrep

ifndef RG-LOADED
RG-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-unknown-linux-gnu
OA-linux-int64 := x86_64-unknown-linux-musl
OA-macos-arm64 := aarch64-apple-darwin
OA-macos-int64 := x86_64-apple-darwin

RG-NAME := ripgrep-$(RG-VERSION)-$(OA-$(OS-ARCH))
RG-TAR := $(RG-NAME).tar.gz
RG-DOWN := https://github.com/BurntSushi/ripgrep
RG-DOWN := $(RG-DOWN)/releases/download/$(RG-VERSION)/$(RG-TAR)

RG := $(LOCAL-BIN)/rg
RG-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/rg
RG-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_rg
RG-COMP-FISH := $(LOCAL-SHARE)/fish/vendor_completions.d/rg.fish
RG-COMP := $(RG-COMP-BASH) $(RG-COMP-ZSH) $(RG-COMP-FISH)
RG-MAN := $(LOCAL-MAN)/man1/rg.1

SHELL-DEPS += $(RG) $(RG-COMP) $(RG-MAN)


$(RG): $(LOCAL-CACHE)/$(RG-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	[[ -e $(LOCAL-CACHE)/$(RG-NAME)/rg ]]
	mv $(LOCAL-CACHE)/$(RG-NAME)/rg $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(RG-TAR):
	@echo "* Installing 'rg' locally"
	curl+ $(RG-DOWN) > $@

$(RG-COMP-BASH): $(RG)
	$Q mkdir -p $(@D)
	$Q cp $(LOCAL-CACHE)/$(RG-NAME)/complete/rg.bash $@

$(RG-COMP-ZSH): $(RG)
	$Q mkdir -p $(@D)
	$Q cp $(LOCAL-CACHE)/$(RG-NAME)/complete/_rg $@

$(RG-COMP-FISH): $(RG)
	$Q mkdir -p $(@D)
	$Q cp $(LOCAL-CACHE)/$(RG-NAME)/complete/rg.fish $@

$(RG-MAN): $(RG)
	$Q mkdir -p $(@D)
	$Q cp $(LOCAL-CACHE)/$(RG-NAME)/doc/rg.1 $@

endif
