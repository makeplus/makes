IN-1-VERSION ?= 0.1.0
# https://github.com/in-1-cc/in-1

ifndef IN-1-LOADED
IN-1-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

IN-1-REPO ?= https://github.com/in-1-cc/in-1
# The git ref to clone; set it to a branch or commit to try one out
IN-1-REF ?= v$(IN-1-VERSION)
IN-1-DIR ?= $(LOCAL-CACHE)/in-1-$(IN-1-VERSION)
IN-1-BIN := $(IN-1-DIR)/bin

override PATH := $(IN-1-BIN):$(PATH)
export PATH

IN-1 := $(IN-1-BIN)/in-1

SHELL-DEPS += $(IN-1)


$(IN-1): $(IN-1-DIR)
	$Q in-1 --version $O
	$Q touch $@
	@$(ECHO)

$(IN-1-DIR):
	@$(ECHO) "* Cloning 'in-1' locally (v$(IN-1-VERSION))"
	$Q git clone$(if $Q, -q) --depth=1 --branch $(IN-1-REF) \
	  --config advice.detachedHead=false \
	  $(IN-1-REPO) $@
	@$(ECHO)

endif
