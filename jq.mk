JQ-VERSION ?= 1.8.2
# https://github.com/jqlang/jq

ifndef JQ-LOADED
JQ-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := macos-arm64
OA-macos-int64 := macos-amd64
OA-windows-int64 := windows-amd64

ifeq ($(OS-NAME),windows)
JQ-NAME := jq-$(OA-$(OS-ARCH)).exe
JQ := $(LOCAL-BIN)/jq.exe
else
JQ-NAME := jq-$(OA-$(OS-ARCH))
JQ := $(LOCAL-BIN)/jq
endif
JQ-DOWN := https://github.com/jqlang/jq
JQ-DOWN := $(JQ-DOWN)/releases/download/jq-$(JQ-VERSION)/$(JQ-NAME)

SHELL-DEPS += $(JQ)


$(JQ): $(LOCAL-CACHE)/$(JQ-NAME)
	cp $< $@
	chmod +x $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(JQ-NAME):
	@echo "* Installing 'jq' locally"
	curl+ $(JQ-DOWN) > $@

endif
