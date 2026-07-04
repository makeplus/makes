EIGHTH-VERSION ?= manual
# https://8th-dev.com/manual.html

ifndef EIGHTH-LOADED
EIGHTH-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

ifeq ($(OS-NAME),windows)
  EIGHTH-EXE := 8th.exe
else
  EIGHTH-EXE := 8th
endif

EIGHTH-ZIP ?= $(LOCAL-CACHE)/8th-$(EIGHTH-VERSION).zip
EIGHTH-LOCAL := $(LOCAL-ROOT)/8th-$(EIGHTH-VERSION)
EIGHTH := $(EIGHTH-LOCAL)/bin/$(EIGHTH-EXE)

SHELL-DEPS += $(EIGHTH)

override PATH := $(EIGHTH-LOCAL)/bin:$(PATH)
export PATH


$(EIGHTH): $(EIGHTH-ZIP)
	$Q rm -rf $(EIGHTH-LOCAL) $(LOCAL-TMP)/8th-$(EIGHTH-VERSION)
	$Q mkdir -p $(EIGHTH-LOCAL)/bin $(LOCAL-TMP)/8th-$(EIGHTH-VERSION)
	$Q unzip -q $< -d $(LOCAL-TMP)/8th-$(EIGHTH-VERSION)
	$Q cp $$(find $(LOCAL-TMP)/8th-$(EIGHTH-VERSION) -name $(EIGHTH-EXE) -type f | head -1) $@
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/8th-$(EIGHTH-VERSION).zip:
	@$(ECHO) "8th downloads are licensed per user."
	@$(ECHO) "Set EIGHTH-ZIP=/path/to/your/8th.zip or copy it to $@."
	@exit 1

endif
