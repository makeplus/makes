ELIXIR-VERSION ?= 1.18.4
ELIXIR-OTP-VERSION ?= 27

ifndef ELIXIR-LOADED
ELIXIR-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/erlang.mk

ELIXIR-DIR := elixir-$(ELIXIR-VERSION)-otp-$(ELIXIR-OTP-VERSION)
ELIXIR-ZIP := v$(ELIXIR-VERSION)-otp-$(ELIXIR-OTP-VERSION).zip
ELIXIR-DOWN := https://builds.hex.pm/builds/elixir/$(ELIXIR-ZIP)

ELIXIR-LOCAL := $(LOCAL-ROOT)/$(ELIXIR-DIR)
ELIXIR-BIN := $(ELIXIR-LOCAL)/bin
override PATH := $(ELIXIR-BIN):$(PATH)

ELIXIR := $(ELIXIR-BIN)/elixir
MIX := $(ELIXIR-BIN)/mix
IEX := $(ELIXIR-BIN)/iex

SHELL-DEPS += $(ELIXIR)


$(ELIXIR): $(LOCAL-CACHE)/$(ELIXIR-ZIP)
	cd $(LOCAL-CACHE) && unzip -q $< -d $(basename $(ELIXIR-ZIP))
	mv $(LOCAL-CACHE)/$(basename $(ELIXIR-ZIP)) $(ELIXIR-LOCAL)
	touch $@
	@echo

$(LOCAL-CACHE)/$(ELIXIR-ZIP):
	@echo "Installing 'elixir' locally"
	curl+ $(ELIXIR-DOWN) > $@

endif
