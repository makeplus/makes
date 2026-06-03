PHEL-VERSION ?= 0.39.0
# https://github.com/phel-lang/phel-lang

ifndef PHEL-LOADED
PHEL-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
include $(MAKES)/php.mk

PHEL-PHAR := phel.phar
PHEL-DOWN := https://github.com/phel-lang/phel-lang
PHEL-DOWN := $(PHEL-DOWN)/releases/download/v$(PHEL-VERSION)/$(PHEL-PHAR)

PHEL-LOCAL := $(LOCAL-ROOT)/phel-$(PHEL-VERSION)
PHEL := $(PHEL-LOCAL)/bin/phel

SHELL-DEPS += $(PHEL)

override PATH := $(PHEL-LOCAL)/bin:$(PATH)
export PATH


$(PHEL): $(LOCAL-CACHE)/phel-$(PHEL-VERSION).phar $(PHP)
	$Q mkdir -p $(PHEL-LOCAL)/bin
	$Q cp $< $@
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/phel-$(PHEL-VERSION).phar:
	@$(ECHO) "* Installing 'phel' locally"
	$Q curl+ $(PHEL-DOWN) > $@

endif
