DEFANG-VERSION ?= 2.1.13

ifndef DEFANG-LOADED
DEFANG-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux_arm64
OA-linux-int64 := linux_amd64
OA-macos-arm64 := macOS
OA-macos-int64 := macOS

DEFANG-NAME := defang_$(DEFANG-VERSION)_$(OA-$(OS-ARCH))
DEFANG-TAR := $(DEFANG-NAME).$(if $(IS-MACOS),zip,tar.gz)
DEFANG-DOWN := https://github.com/defanglabs/defang/releases/download
DEFANG-DOWN := $(DEFANG-DOWN)/v$(DEFANG-VERSION)/$(DEFANG-TAR)

DEFANG := $(LOCAL-BIN)/defang

SHELL-DEPS += $(DEFANG)


$(DEFANG): $(LOCAL-CACHE)/$(DEFANG-TAR)
ifdef IS-MACOS
	cd $(LOCAL-BIN) && unzip $< defang
else
	tar -C $(LOCAL-BIN) -xf $< defang
endif
	[[ -e $@ ]]
	@touch $@
	@echo

$(LOCAL-CACHE)/$(DEFANG-TAR):
	@echo "* Installing 'defang' locally"
	curl+ $(DEFANG-DOWN) > $@
	@touch $@

endif
