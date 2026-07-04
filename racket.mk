RACKET-VERSION ?= 9.2
# https://download.racket-lang.org/

ifndef RACKET-LOADED
RACKET-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64-linux-buster-cs
OA-linux-int64 := x86_64-linux-buster-cs
OA-macos-arm64 := aarch64-macosx-cs
OA-macos-int64 := x86_64-macosx-cs

RACKET-LOCAL := $(LOCAL-ROOT)/racket-$(RACKET-VERSION)
RACKET := $(RACKET-LOCAL)/bin/racket

SHELL-DEPS += $(RACKET)

override PATH := $(RACKET-LOCAL)/bin:$(PATH)
export PATH

ifeq (linux,$(OS-NAME))
RACKET-INS := racket-$(RACKET-VERSION)-$(OA-$(OS-ARCH)).sh
RACKET-DOWN := https://download.racket-lang.org/releases/$(RACKET-VERSION)/installers/$(RACKET-INS)

$(RACKET): $(LOCAL-CACHE)/$(RACKET-INS)
	$Q rm -rf $(RACKET-LOCAL)
	$Q sh $< --unix-style --create-dir --dest $(RACKET-LOCAL)
	$Q touch $@
	@$(ECHO)
else ifeq (macos,$(OS-NAME))
RACKET-INS := racket-$(RACKET-VERSION)-$(OA-$(OS-ARCH)).dmg
RACKET-DOWN := https://download.racket-lang.org/releases/$(RACKET-VERSION)/installers/$(RACKET-INS)

$(RACKET): $(LOCAL-CACHE)/$(RACKET-INS)
	$Q rm -rf $(RACKET-LOCAL)
	$Q mkdir -p $(RACKET-LOCAL)
	$Q hdiutil attach $< -mountpoint $(LOCAL-TMP)/racket-$(RACKET-VERSION)
	$Q cp -R $(LOCAL-TMP)/racket-$(RACKET-VERSION)/Racket\ v$(RACKET-VERSION)/* $(RACKET-LOCAL)/
	$Q hdiutil detach $(LOCAL-TMP)/racket-$(RACKET-VERSION)
	$Q touch $@
	@$(ECHO)
endif

$(LOCAL-CACHE)/$(RACKET-INS):
	@$(ECHO) "* Installing 'racket' locally"
	$Q curl+ $(RACKET-DOWN) > $@

endif
