JUS-VERSION ?= 0.2.0
# https://github.com/paintparty/jus

ifndef JUS-LOADED
JUS-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/bbin.mk
include $(MAKES)/clojure.mk

JUS-LOCAL := $(LOCAL-ROOT)/jus-$(JUS-VERSION)
JUS := $(JUS-LOCAL)/bin/jus

SHELL-DEPS += $(JUS)

override PATH := $(JUS-LOCAL)/bin:$(PATH)
export PATH


$(JUS): $(BBIN) $(CLOJURE)
	@$(ECHO) "* Installing 'jus' locally"
	$Q BABASHKA_BBIN_BIN_DIR=$(JUS-LOCAL)/bin \
	  $(BBIN) install io.github.paintparty/jus --git/tag v$(JUS-VERSION)
	$Q test -x $@
	$Q touch $@
	@$(ECHO)

endif
