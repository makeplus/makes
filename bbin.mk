BBIN-VERSION ?= 0.2.5
# https://github.com/babashka/bbin

ifndef BBIN-LOADED
BBIN-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/babashka.mk
ifndef JAVA-LOADED
ifndef GRAALVM-LOADED
include $(MAKES)/java.mk
endif
endif

ifeq (,$(filter linux macos,$(OS-NAME)))
$(error 'bbin' currently supports Linux and macOS in Makes)
endif

BBIN-LOCAL := $(LOCAL-ROOT)/bbin-$(BBIN-VERSION)
BBIN := $(BBIN-LOCAL)/bin/bbin
BBIN-CACHE := bbin-$(BBIN-VERSION)
BBIN-DOWN := https://raw.githubusercontent.com/babashka/bbin
BBIN-DOWN := $(BBIN-DOWN)/v$(BBIN-VERSION)/bbin

# Keep legacy home installations from taking precedence over these paths.
export BABASHKA_BBIN_DIR := $(LOCAL-CACHE)/bbin-legacy
export BABASHKA_BBIN_BIN_DIR := $(LOCAL-BIN)
export BABASHKA_BBIN_JARS_DIR := $(LOCAL-CACHE)/bbin-jars

SHELL-DEPS += $(BBIN)

override PATH := $(BBIN-LOCAL)/bin:$(PATH)
export PATH


$(BBIN): $(LOCAL-CACHE)/$(BBIN-CACHE) $(BB) $(JAVA)
	$Q mkdir -p $(BBIN-LOCAL)/bin
	$Q cp $< $@
	$Q chmod +x $@
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(BBIN-CACHE):
	@$(ECHO) "* Installing 'bbin' locally"
	$Q curl+ $(BBIN-DOWN) > $@

endif
