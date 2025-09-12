BABASHKA-VERSION ?= 1.12.208

ifndef BABASHKA-LOADED
BABASHKA-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux-aarch64-static
OA-linux-int64 := linux-amd64-static
OA-macos-arm64 := macos-aarch64
OA-macos-int64 := macos-amd64

BABASHKA-DIR := babashka-$(BABASHKA-VERSION)-$(OA-$(OS-ARCH))
BABASHKA-TAR := $(BABASHKA-DIR).tar.gz
BABASHKA-DOWN := https://github.com/babashka/babashka
BABASHKA-DOWN := $(BABASHKA-DOWN)/releases/download/v$(BABASHKA-VERSION)/$(BABASHKA-TAR)

BB := $(LOCAL-BIN)/bb

SHELL-DEPS += $(BB)


$(BB): $(LOCAL-CACHE)/$(BABASHKA-TAR)
	tar -C $(LOCAL-CACHE) -xf $<
	[[ -e $(LOCAL-CACHE)/bb ]]
	mv $(LOCAL-CACHE)/bb $(LOCAL-BIN)
	touch $@
	@echo

$(LOCAL-CACHE)/$(BABASHKA-TAR):
	@echo "Installing 'bb' locally"
	curl+ $(BABASHKA-DOWN) > $@

endif
