PROCESSING-VERSION ?= 4.5.5
# https://github.com/processing/processing4

ifndef PROCESSING-LOADED
PROCESSING-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-x64
OA-windows-int64 := windows-x64

$(if $(OA-$(OS-ARCH)),,$(error processing.mk does not support $(OS-ARCH)))

PROCESSING-TAG := processing-1433-$(PROCESSING-VERSION)
PROCESSING-ZIP := processing-$(PROCESSING-VERSION)-$(OA-$(OS-ARCH))-portable.zip
PROCESSING-DOWN := https://github.com/processing/processing4/releases/download/$(PROCESSING-TAG)/$(PROCESSING-ZIP)
PROCESSING-LOCAL := $(LOCAL-ROOT)/processing-$(PROCESSING-VERSION)
ifeq ($(OS-NAME),windows)
PROCESSING := $(PROCESSING-LOCAL)/processing.exe
else ifeq ($(OS-NAME),macos)
PROCESSING := $(PROCESSING-LOCAL)/Processing.app/Contents/MacOS/Processing
else
PROCESSING := $(PROCESSING-LOCAL)/bin/Processing
endif

SHELL-DEPS += $(PROCESSING)

override PATH := $(PROCESSING-LOCAL)/bin:$(PROCESSING-LOCAL):$(PATH)
export PATH

$(PROCESSING): $(LOCAL-CACHE)/$(PROCESSING-ZIP)
	@$(ECHO) "* Installing 'processing' locally"
	$Q rm -rf $(PROCESSING-LOCAL) $(LOCAL-TMP)/processing-$(PROCESSING-VERSION)
	$Q mkdir -p $(LOCAL-TMP)/processing-$(PROCESSING-VERSION)
	$Q unzip -q -d $(LOCAL-TMP)/processing-$(PROCESSING-VERSION) $<
	$Q mv $$(find $(LOCAL-TMP)/processing-$(PROCESSING-VERSION) -mindepth 1 -maxdepth 1 -type d | head -1) $(PROCESSING-LOCAL)
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(PROCESSING-ZIP):
	@$(ECHO) "* Downloading 'processing' archive"
	$Q curl+ $(PROCESSING-DOWN) > $@

endif
