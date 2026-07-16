GLOAT-VERSION ?= 0.1.59
# https://github.com/gloathub/gloat

ifndef GLOAT-LOADED
GLOAT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

GLOAT-REPO ?= https://github.com/gloathub/gloat
GLOAT-DIR ?= $(LOCAL-CACHE)/gloat-$(GLOAT-VERSION)
GLOAT-BIN := $(GLOAT-DIR)/bin

override PATH := $(GLOAT-BIN):$(PATH)
export PATH

GLOAT := $(GLOAT-BIN)/gloat

SHELL-DEPS += $(GLOAT)


$(GLOAT): $(GLOAT-DIR)
	$Q gloat --version $O
	$Q touch $@
	@$(ECHO)

$(GLOAT-DIR):
	@$(ECHO) "* Cloning 'gloat' locally (v$(GLOAT-VERSION))"
	$Q git clone$(if $Q, -q) --depth=1 --branch v$(GLOAT-VERSION) \
	  --config advice.detachedHead=false \
	  $(GLOAT-REPO) $@
	@$(ECHO)

endif
