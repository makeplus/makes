JSONSCHEMA-VERSION ?= 16.2.0
# https://github.com/sourcemeta/jsonschema

ifndef JSONSCHEMA-LOADED
JSONSCHEMA-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-x86_64
OA-macos-arm64 := darwin-arm64
OA-macos-int64 := darwin-x86_64
OA-windows-int64 := windows-x86_64

JSONSCHEMA-NAME := jsonschema-$(JSONSCHEMA-VERSION)-$(OA-$(OS-ARCH))
JSONSCHEMA-ZIP := $(JSONSCHEMA-NAME).zip
JSONSCHEMA-DOWN := https://github.com/sourcemeta/jsonschema
JSONSCHEMA-DOWN := $(JSONSCHEMA-DOWN)/releases/download/v$(JSONSCHEMA-VERSION)/$(JSONSCHEMA-ZIP)

ifeq ($(OS-NAME),windows)
JSONSCHEMA := $(LOCAL-BIN)/jsonschema.exe
else
JSONSCHEMA := $(LOCAL-BIN)/jsonschema
endif

SHELL-DEPS += $(JSONSCHEMA)


$(JSONSCHEMA): $(LOCAL-CACHE)/$(JSONSCHEMA-ZIP)
	$Q cd $(LOCAL-CACHE) && unzip -q $< -d jsonschema-$(JSONSCHEMA-VERSION)-tmp
	$Q cp $(LOCAL-CACHE)/jsonschema-$(JSONSCHEMA-VERSION)-tmp/$(JSONSCHEMA-NAME)/bin/jsonschema* $@
	$Q rm -rf $(LOCAL-CACHE)/jsonschema-$(JSONSCHEMA-VERSION)-tmp
	$Q chmod +x $@
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(JSONSCHEMA-ZIP):
	@$(ECHO) "* Installing 'jsonschema' locally"
	$Q curl+ $(JSONSCHEMA-DOWN) > $@

endif
