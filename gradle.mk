GRADLE-VERSION ?= 9.8.2
# https://github.com/gradle/gradle

ifndef GRADLE-LOADED
GRADLE-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

ifndef JAVA-LOADED
ifndef GRAALVM-LOADED
include $(MAKES)/java.mk
endif
endif

GRADLE-ARC := gradle-$(GRADLE-VERSION)-bin.zip
GRADLE-DOWN := https://services.gradle.org/distributions/$(GRADLE-ARC)
GRADLE-LOCAL := $(LOCAL-ROOT)/gradle-$(GRADLE-VERSION)
GRADLE-TMP := $(LOCAL-TMP)/gradle-$(GRADLE-VERSION)

ifeq (windows,$(OS-NAME))
GRADLE := $(GRADLE-LOCAL)/bin/gradle.bat
else
GRADLE := $(GRADLE-LOCAL)/bin/gradle
endif

export GRADLE_USER_HOME ?= $(LOCAL-CACHE)/gradle

SHELL-DEPS += $(GRADLE)

override PATH := $(GRADLE-LOCAL)/bin:$(PATH)
export PATH


$(GRADLE): $(LOCAL-CACHE)/$(GRADLE-ARC) $(JAVA)
	$Q rm -rf $(GRADLE-TMP)
	$Q mkdir -p $(GRADLE-TMP)
	$Q unzip -q $< -d $(GRADLE-TMP)
	$Q rm -rf $(GRADLE-LOCAL)
	$Q mv $(GRADLE-TMP)/gradle-$(GRADLE-VERSION) $(GRADLE-LOCAL)
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(GRADLE-ARC):
	@$(ECHO) "* Installing 'gradle' locally"
	$Q curl+ $(GRADLE-DOWN) > $@.tmp
	$Q mv $@.tmp $@

endif
