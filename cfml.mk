COMMANDBOX-VERSION ?= 6.3.3
# https://www.ortussolutions.com/products/commandbox

ifndef CFML-LOADED
CFML-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/java.mk

ifeq ($(OS-NAME),windows)
  BOX-EXE := box.exe
else
  BOX-EXE := box
endif

COMMANDBOX-ZIP := commandbox-bin-$(COMMANDBOX-VERSION).zip
COMMANDBOX-DOWN := https://downloads.ortussolutions.com/ortussolutions/commandbox/$(COMMANDBOX-VERSION)/$(COMMANDBOX-ZIP)
COMMANDBOX-LOCAL := $(LOCAL-ROOT)/commandbox-$(COMMANDBOX-VERSION)
BOX := $(COMMANDBOX-LOCAL)/bin/$(BOX-EXE)

SHELL-DEPS += $(BOX)

override PATH := $(COMMANDBOX-LOCAL)/bin:$(PATH)
export PATH


$(BOX): $(LOCAL-CACHE)/$(COMMANDBOX-ZIP) $(JAVA)
	$Q rm -rf $(COMMANDBOX-LOCAL) $(LOCAL-TMP)/commandbox-$(COMMANDBOX-VERSION)
	$Q mkdir -p $(COMMANDBOX-LOCAL)/bin $(LOCAL-TMP)/commandbox-$(COMMANDBOX-VERSION)
	$Q unzip -q $< -d $(LOCAL-TMP)/commandbox-$(COMMANDBOX-VERSION)
	$Q cp $$(find $(LOCAL-TMP)/commandbox-$(COMMANDBOX-VERSION) -name $(BOX-EXE) -type f | head -1) $@
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/$(COMMANDBOX-ZIP):
	@$(ECHO) "* Installing 'commandbox' locally"
	$Q curl+ $(COMMANDBOX-DOWN) > $@

endif
