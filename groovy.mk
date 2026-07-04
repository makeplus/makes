GROOVY-VERSION ?= 5.0.7
# https://downloads.apache.org/groovy/

ifndef GROOVY-LOADED
GROOVY-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/java.mk

GROOVY-ZIP := apache-groovy-binary-$(GROOVY-VERSION).zip
GROOVY-DOWN := https://downloads.apache.org/groovy/$(GROOVY-VERSION)/distribution/$(GROOVY-ZIP)
GROOVY-LOCAL := $(LOCAL-ROOT)/groovy-$(GROOVY-VERSION)
GROOVY := $(GROOVY-LOCAL)/bin/groovy

SHELL-DEPS += $(GROOVY)

override PATH := $(GROOVY-LOCAL)/bin:$(PATH)
export PATH


$(GROOVY): $(LOCAL-CACHE)/$(GROOVY-ZIP) $(JAVA)
	$Q rm -rf $(GROOVY-LOCAL) $(LOCAL-TMP)/groovy-$(GROOVY-VERSION)
	$Q mkdir -p $(LOCAL-TMP)/groovy-$(GROOVY-VERSION)
	$Q unzip -q $< -d $(LOCAL-TMP)/groovy-$(GROOVY-VERSION)
	$Q dir=$$(find $(LOCAL-TMP)/groovy-$(GROOVY-VERSION) -path '*/bin/groovy' -type f | head -1); \
	  [[ -n "$$dir" ]]; \
	  mv "$${dir%/bin/groovy}" $(GROOVY-LOCAL)
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(GROOVY-ZIP):
	@$(ECHO) "* Installing 'groovy' locally"
	$Q curl+ $(GROOVY-DOWN) > $@

endif
