BALLERINA-VERSION ?= 2201.12.12
# https://github.com/ballerina-platform/ballerina-distribution

ifndef BALLERINA-LOADED
BALLERINA-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))
include $(MAKES)/java.mk

OA-linux-arm64 := linux-arm
OA-linux-int64 := linux
OA-macos-arm64 := macos-arm
OA-macos-int64 := macos
OA-windows-int64 := windows

BALLERINA-DIR := ballerina-$(BALLERINA-VERSION)-swan-lake
BALLERINA-ZIP := $(BALLERINA-DIR)-$(OA-$(OS-ARCH)).zip
BALLERINA-DOWN := https://github.com/ballerina-platform/ballerina-distribution
BALLERINA-DOWN := $(BALLERINA-DOWN)/releases/download/v$(BALLERINA-VERSION)/$(BALLERINA-ZIP)

BALLERINA-LOCAL := $(LOCAL-ROOT)/ballerina-$(BALLERINA-VERSION)
BAL := $(BALLERINA-LOCAL)/bin/bal

SHELL-DEPS += $(BAL)

override PATH := $(BALLERINA-LOCAL)/bin:$(PATH)
export PATH


$(BAL): $(LOCAL-CACHE)/$(BALLERINA-ZIP) $(JAVA)
	$Q rm -rf $(BALLERINA-LOCAL) $(LOCAL-TMP)/ballerina-$(BALLERINA-VERSION)
	$Q mkdir -p $(LOCAL-TMP)/ballerina-$(BALLERINA-VERSION)
	$Q unzip -q $< -d $(LOCAL-TMP)/ballerina-$(BALLERINA-VERSION)
	$Q dir=$$(find $(LOCAL-TMP)/ballerina-$(BALLERINA-VERSION) -path '*/bin/bal' -type f | head -1); \
	  [[ -n "$$dir" ]]; \
	  mv "$${dir%/bin/bal}" $(BALLERINA-LOCAL)
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(BALLERINA-ZIP):
	@$(ECHO) "* Installing 'ballerina' locally"
	$Q curl+ $(BALLERINA-DOWN) > $@

endif
