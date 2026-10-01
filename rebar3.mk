REBAR3-VERSION ?= 3.27.1
# https://github.com/erlang/rebar3

ifndef REBAR3-LOADED
REBAR3-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

include $(MAKES)/erlang.mk

REBAR3-LOCAL := $(LOCAL-ROOT)/rebar3-$(REBAR3-VERSION)
REBAR3-BIN := $(REBAR3-LOCAL)/bin
REBAR3 := $(REBAR3-BIN)/rebar3
REBAR3-DOWN := https://github.com/erlang/rebar3/releases/download
REBAR3-DOWN := $(REBAR3-DOWN)/$(REBAR3-VERSION)/rebar3
REBAR3-COMP-BASH := $(LOCAL-SHARE)/bash-completion/completions/rebar3
REBAR3-COMP-ZSH := $(LOCAL-SHARE)/zsh/site-functions/_rebar3
REBAR3-COMP-FISH := $(LOCAL-SHARE)/fish/vendor_completions.d/rebar3.fish
REBAR3-COMP := \
  $(REBAR3-COMP-BASH) \
  $(REBAR3-COMP-ZSH) \
  $(REBAR3-COMP-FISH)
REBAR3-COMP-DOWN := https://raw.githubusercontent.com/erlang/rebar3
REBAR3-COMP-DOWN := \
  $(REBAR3-COMP-DOWN)/$(REBAR3-VERSION)/apps/rebar/priv/shell-completion

SHELL-DEPS += $(REBAR3) $(REBAR3-COMP)

override PATH := $(REBAR3-BIN):$(PATH)
export PATH


$(REBAR3): $(LOCAL-CACHE)/rebar3-$(REBAR3-VERSION) $(ERL)
	$Q rm -rf $(REBAR3-LOCAL)
	$Q mkdir -p $(REBAR3-BIN)
	$Q cp $< $@
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/rebar3-$(REBAR3-VERSION):
	@$(ECHO) "* Installing 'rebar3' locally"
	$Q curl+ $(REBAR3-DOWN) > $@

$(REBAR3-COMP-BASH):
	$Q mkdir -p $(@D)
	$Q curl+ $(REBAR3-COMP-DOWN)/bash/rebar3 > $@

$(REBAR3-COMP-ZSH):
	$Q mkdir -p $(@D)
	$Q curl+ $(REBAR3-COMP-DOWN)/zsh/_rebar3 > $@

$(REBAR3-COMP-FISH):
	$Q mkdir -p $(@D)
	$Q curl+ $(REBAR3-COMP-DOWN)/fish/rebar3.fish > $@

endif
