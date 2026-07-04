UNISON-VERSION ?= 1.3.0
# https://github.com/unisonweb/unison

ifndef UNISON-LOADED
UNISON-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-x64
OA-macos-arm64 := macos-arm64
OA-macos-int64 := macos-x64
OA-windows-int64 := windows-x64

ifeq (windows,$(OS-NAME))
  UNISON-EXT := zip
  UCM-EXE := ucm.exe
else
  UNISON-EXT := tar.gz
  UCM-EXE := ucm
endif

UNISON-ARC := ucm-$(OA-$(OS-ARCH)).$(UNISON-EXT)
UNISON-DOWN := https://github.com/unisonweb/unison/releases/download/release%2F$(UNISON-VERSION)/$(UNISON-ARC)
UNISON-LOCAL := $(LOCAL-ROOT)/unison-$(UNISON-VERSION)
UCM := $(UNISON-LOCAL)/bin/$(UCM-EXE)

SHELL-DEPS += $(UCM)

override PATH := $(UNISON-LOCAL)/bin:$(PATH)
export PATH


$(UCM): $(LOCAL-CACHE)/unison-$(UNISON-VERSION)-$(UNISON-ARC)
	$Q rm -rf $(UNISON-LOCAL) $(LOCAL-TMP)/unison-$(UNISON-VERSION)
	$Q mkdir -p $(UNISON-LOCAL)/bin $(LOCAL-TMP)/unison-$(UNISON-VERSION)
ifeq (windows,$(OS-NAME))
	$Q unzip -q $< -d $(LOCAL-TMP)/unison-$(UNISON-VERSION)
else
	$Q tar -C $(LOCAL-TMP)/unison-$(UNISON-VERSION) -xzf $<
endif
	$Q cp $(LOCAL-TMP)/unison-$(UNISON-VERSION)/$(UCM-EXE) $@
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/unison-$(UNISON-VERSION)-$(UNISON-ARC):
	@$(ECHO) "* Installing 'unison' locally"
	$Q curl+ $(UNISON-DOWN) > $@

endif
