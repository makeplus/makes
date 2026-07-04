SWIFT-VERSION ?= latest
# https://www.swift.org/install/

ifndef SWIFT-LOADED
SWIFT-LOADED := true
$(if $(MAKES),,$(error Please 'include init.mk' first))
$(eval $(call include-local))

OA-linux-arm64 := aarch64
OA-linux-int64 := x86_64

SWIFTLY-HOME := $(LOCAL-ROOT)/swiftly
SWIFTLY := $(SWIFTLY-HOME)/bin/swiftly
SWIFT := $(SWIFTLY-HOME)/bin/swift
SWIFTLY-TAR := swiftly-$(OA-$(OS-ARCH)).tar.gz
SWIFTLY-DOWN := https://download.swift.org/swiftly/linux/$(SWIFTLY-TAR)

SHELL-DEPS += $(SWIFT)

override PATH := $(SWIFTLY-HOME)/bin:$(PATH)
export PATH
export SWIFTLY_HOME_DIR := $(SWIFTLY-HOME)


$(SWIFT): $(LOCAL-CACHE)/$(SWIFTLY-TAR)
	$Q rm -rf $(SWIFTLY-HOME) $(LOCAL-TMP)/swiftly
	$Q mkdir -p $(SWIFTLY-HOME)/bin $(LOCAL-TMP)/swiftly
	$Q tar -C $(LOCAL-TMP)/swiftly -xzf $<
	$Q cp $(LOCAL-TMP)/swiftly/swiftly $(SWIFTLY)
	$Q chmod +x $(SWIFTLY)
	$Q $(SWIFTLY) init --assume-yes --no-modify-profile --skip-install --quiet-shell-followup
	$Q . $(SWIFTLY-HOME)/env.sh && $(SWIFTLY) install --use $(SWIFT-VERSION)
	$Q touch $@
	@$(ECHO)

$(LOCAL-CACHE)/$(SWIFTLY-TAR):
	@$(ECHO) "* Installing 'swift' locally"
	$Q curl+ $(SWIFTLY-DOWN) > $@

endif
