ROC-VERSION ?= alpha4-rolling
# https://github.com/roc-lang/roc

ifndef ROC-LOADED
ROC-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := linux_arm64
OA-linux-int64 := linux_x86_64
OA-macos-arm64 := macos_apple_silicon
OA-macos-int64 := macos_x86_64

ROC-TAR := roc-$(OA-$(OS-ARCH))-$(ROC-VERSION).tar.gz
ROC-DOWN := https://github.com/roc-lang/roc/releases/download/$(ROC-VERSION)/$(ROC-TAR)
ROC-LOCAL := $(LOCAL-ROOT)/roc-$(ROC-VERSION)
ROC := $(ROC-LOCAL)/bin/roc

SHELL-DEPS += $(ROC)

override PATH := $(ROC-LOCAL)/bin:$(PATH)
export PATH


$(ROC): $(LOCAL-CACHE)/$(ROC-TAR)
	$Q rm -rf $(ROC-LOCAL) $(LOCAL-TMP)/roc-$(ROC-VERSION)
	$Q mkdir -p $(ROC-LOCAL)/bin $(LOCAL-TMP)/roc-$(ROC-VERSION)
	$Q tar -C $(LOCAL-TMP)/roc-$(ROC-VERSION) -xzf $<
	$Q cp $$(find $(LOCAL-TMP)/roc-$(ROC-VERSION) -name roc -type f | head -1) $@
	$Q chmod +x $@
	@$(ECHO)

$(LOCAL-CACHE)/$(ROC-TAR):
	@$(ECHO) "* Installing 'roc' locally"
	$Q curl+ $(ROC-DOWN) > $@

endif
