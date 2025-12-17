JQ-VERSION ?= 1.8.1
# https://github.com/jqlang/jq

ifndef JQ-LOADED
JQ-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-arm64
OA-linux-int64 := linux-amd64
OA-macos-arm64 := macos-arm64
OA-macos-int64 := macos-amd64

JQ-NAME := jq-$(OA-$(OS-ARCH))
JQ-DOWN := https://github.com/jqlang/jq
JQ-DOWN := $(JQ-DOWN)/releases/download/jq-$(JQ-VERSION)/$(JQ-NAME)

JQ := $(LOCAL-BIN)/jq

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
