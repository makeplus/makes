KOTLIN-VERSION ?= 2.4.0
# https://github.com/JetBrains/kotlin

ifndef KOTLIN-LOADED
KOTLIN-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/java.mk

KOTLIN-ZIP := kotlin-compiler-$(KOTLIN-VERSION).zip
KOTLIN-DOWN := https://github.com/JetBrains/kotlin/releases/download/v$(KOTLIN-VERSION)/$(KOTLIN-ZIP)
KOTLIN-LOCAL := $(LOCAL-ROOT)/kotlin-$(KOTLIN-VERSION)
KOTLINC := $(KOTLIN-LOCAL)/kotlinc/bin/kotlinc

SHELL-DEPS += $(KOTLINC)

override PATH := $(KOTLIN-LOCAL)/kotlinc/bin:$(PATH)
export PATH


$(KOTLINC): $(LOCAL-CACHE)/$(KOTLIN-ZIP) $(JAVA)
	$Q rm -rf $(KOTLIN-LOCAL)
	$Q mkdir -p $(KOTLIN-LOCAL)
	$Q unzip -q $< -d $(KOTLIN-LOCAL)
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(KOTLIN-ZIP):
	@$(ECHO) "* Installing 'kotlin' locally"
	$Q curl+ $(KOTLIN-DOWN) > $@

endif
