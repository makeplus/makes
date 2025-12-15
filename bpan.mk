BPAN-VERSION ?= main
# https://github.com/bpan-org/bpan

ifndef BPAN-LOADED
BPAN-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

export BPAN_ROOT := $(LOCAL-ROOT)/bpan
BPAN-BIN := $(BPAN_ROOT)/bin
override PATH := $(BPAN-BIN):$(PATH)

BPAN := $(BPAN-BIN)/bpan

SHELL-DEPS += $(BPAN)

$(BPAN):
ifeq (,$(wildcard $(BPAN_ROOT)))
	@$(ECHO) "Installing 'bpan' locally"
	$Q git clone -q --branch $(BPAN-VERSION) https://github.com/bpan-org/bpan $(BPAN_ROOT)
else
	$Q git -C $(BPAN_ROOT) fetch -q
	$Q git -C $(BPAN_ROOT) checkout -q $(BPAN-VERSION)
	$Q git -C $(BPAN_ROOT) pull -q
endif
	$Q touch $@

endif
