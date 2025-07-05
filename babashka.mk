BB-VERSION ?= 1.12.204

ifndef BB-LOADED
BB-LOADED := true

$(if $(MAKES),,$(error Please 'include .makes/init.mk'))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64
OA-linux-int64 := linux-amd64-static
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-amd64

BB-NAME := babashka-$(BB-VERSION)-$(OA-$(OS-ARCH))
BB-TARBALL := $(BB-NAME).tar.gz
BB-REPO-URL := https://github.com/babashka/babashka
BB-DOWNLOAD := $(BB-REPO-URL)/releases/download/v$(BB-VERSION)/$(BB-TARBALL)

BB := $(LOCAL-BIN)/bb

SHELL-DEPS += $(BB)


$(BB): $(LOCAL-CACHE)/$(BB-TARBALL)
	tar -C $(LOCAL-CACHE) -xf $< -- bb
	[[ -e $(LOCAL-CACHE)/bb ]]
	mv $(LOCAL-CACHE)/bb $@
	touch $@
	@echo

$(LOCAL-CACHE)/$(BB-TARBALL):
	@echo "Installing 'bb' locally"
	curl+ $(BB-DOWNLOAD) > $@

endif
