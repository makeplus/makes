MIPS-VERSION ?= 4.5.1
# https://github.com/dpetersanderson/MARS

ifndef MIPS-LOADED
MIPS-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/java.mk

MIPS-JAR := Mars4_5.jar
MIPS-DOWN := https://github.com/dpetersanderson/MARS/releases/download/v.$(MIPS-VERSION)/$(MIPS-JAR)
MIPS-LOCAL := $(LOCAL-ROOT)/mips-$(MIPS-VERSION)
MARS := $(MIPS-LOCAL)/$(MIPS-JAR)
MIPS := $(LOCAL-BIN)/mips

SHELL-DEPS += $(MIPS)


$(MIPS): $(MARS) $(JAVA)
	$Q mkdir -p $(LOCAL-BIN)
	$Q printf '#!/usr/bin/env bash\nmkdir -p %s\nexec %s -Djava.util.prefs.userRoot=%s -jar %s "$$@"\n' \
	  '$(MIPS-LOCAL)/prefs' '$(JAVA)' '$(MIPS-LOCAL)/prefs' '$(MARS)' > $@
	$Q chmod +x $@
	@$(ECHO)

$(MARS): $(LOCAL-CACHE)/$(MIPS-JAR)
	$Q rm -rf $(MIPS-LOCAL)
	$Q mkdir -p $(MIPS-LOCAL)
	$Q cp $< $@
	@$(ECHO)

$(LOCAL-CACHE)/$(MIPS-JAR):
	@$(ECHO) "* Installing 'mips' locally"
	$Q curl+ $(MIPS-DOWN) > $@

endif
