SCRATCH-VERSION ?= 3.32.0
# https://github.com/scratchfoundation/scratch-desktop

ifndef SCRATCH-LOADED
SCRATCH-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

$(if $(filter macos-int64 windows-int64,$(OS-ARCH)),,$(error scratch.mk does not support $(OS-ARCH)))

ifeq ($(OS-NAME),windows)
SCRATCH-ARCHIVE := Scratch-Desktop-Setup-$(SCRATCH-VERSION).exe
SCRATCH-DOWN := https://downloads.scratch.mit.edu/desktop/Scratch%20Desktop%20Setup%20$(SCRATCH-VERSION).exe
SCRATCH := $(SCRATCH-LOCAL)/scratch.exe
else
SCRATCH-ARCHIVE := Scratch-Desktop-$(SCRATCH-VERSION).dmg
SCRATCH-DOWN := https://downloads.scratch.mit.edu/desktop/Scratch%20Desktop-$(SCRATCH-VERSION).dmg
SCRATCH := $(SCRATCH-LOCAL)/scratch
endif
SCRATCH-LOCAL := $(LOCAL-ROOT)/scratch-$(SCRATCH-VERSION)

SHELL-DEPS += $(SCRATCH)

override PATH := $(SCRATCH-LOCAL):$(PATH)
export PATH

ifeq ($(OS-NAME),windows)
$(SCRATCH): $(LOCAL-CACHE)/$(SCRATCH-ARCHIVE)
	@$(ECHO) "* Installing 'scratch' locally"
	$Q rm -rf $(SCRATCH-LOCAL)
	$Q mkdir -p $(SCRATCH-LOCAL)
	$Q cp $< "$@"
	$Q chmod +x "$@"
	@$(ECHO)
else
$(SCRATCH): $(LOCAL-CACHE)/$(SCRATCH-ARCHIVE)
	@$(ECHO) "* Installing 'scratch' locally"
	$Q rm -rf $(SCRATCH-LOCAL) $(LOCAL-TMP)/scratch-$(SCRATCH-VERSION)
	$Q mkdir -p $(SCRATCH-LOCAL) $(LOCAL-TMP)/scratch-$(SCRATCH-VERSION)
	$Q hdiutil attach $< -mountpoint $(LOCAL-TMP)/scratch-$(SCRATCH-VERSION)
	$Q cp -R "$(LOCAL-TMP)/scratch-$(SCRATCH-VERSION)/Scratch Desktop.app" $(SCRATCH-LOCAL)/
	$Q hdiutil detach $(LOCAL-TMP)/scratch-$(SCRATCH-VERSION)
	$Q ln -sf "$(SCRATCH-LOCAL)/Scratch Desktop.app/Contents/MacOS/Scratch Desktop" "$@"
	@$(ECHO)
endif

$(LOCAL-CACHE)/$(SCRATCH-ARCHIVE):
	@$(ECHO) "* Downloading 'scratch' archive"
	$Q curl+ "$(SCRATCH-DOWN)" > $@

endif
