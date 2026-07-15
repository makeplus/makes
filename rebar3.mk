REBAR3-VERSION ?= 3.25.1
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

SHELL-DEPS += $(REBAR3)

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

endif
